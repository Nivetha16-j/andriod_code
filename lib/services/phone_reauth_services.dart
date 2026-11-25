import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:junubullion/services/session_manager.dart';

class PhoneReauthService {
  static String? _verificationId;
  static int? _resendToken;
  static int _attempt = 0;
  static String? _phoneOverride;
  static bool _signedInByFlow = false;
  String? sessionPhone;

  /// Call with the session phone (e.g. "+916381305957") before sending.
  // static void setPhone(String? phone) => _phoneOverride =
  //     (phone == null || phone.trim().isEmpty) ? null : phone.trim();

  /// Session phone first, then the Firebase user's phone.
  Future<String?> get phoneNumber async {
    // final p = _phoneOverride ?? FirebaseAuth.instance.currentUser?.phoneNumber;
    final dynamic sessionUser = await SessionManager.getUser();
    sessionPhone = sessionUser is Map
        ? sessionUser['phone_number']?.toString()
        : sessionUser?.phone?.toString();
    return (sessionPhone == null || sessionPhone!.isEmpty)
        ? null
        : sessionPhone;
  }

  bool get isAvailable =>
      sessionPhone == null || sessionPhone!.isEmpty ? false : true;

  /// Sends the SMS. Throws with a readable message on failure.
  Future<void> sendCode(String sessionPhone) async {
    final phone = sessionPhone;
    log("phonee $phone");
    if (phone.isEmpty) {
      throw Exception("No phone number available for this account");
    }

    final int attempt = ++_attempt;
    final completer = Completer<void>();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendToken,
      verificationCompleted: (_) {}, // the user types the code
      verificationFailed: (e) {
        log("PAYMENT OTP SEND FAILED -> ${e.code} ${e.message}");
        if (!completer.isCompleted) {
          completer.completeError(
            Exception(e.message ?? "Could not send the code (${e.code})"),
          );
        }
      },
      codeSent: (id, token) {
        if (attempt == _attempt) {
          _verificationId = id;
          _resendToken = token;
        }
        if (!completer.isCompleted) completer.complete();
      },
      codeAutoRetrievalTimeout: (id) {
        // only the latest send may update the id
        if (attempt == _attempt) _verificationId = id;
      },
    );

    await completer.future;
  }

  /// Verifies the SMS code. Re-authenticates if a Firebase user exists,
  /// otherwise signs in (temporary session, cleared by [finish]).
  static Future<void> verifyCode(String code) async {
    final id = _verificationId;
    if (id == null) throw Exception("Please request a new code");

    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: id,
        smsCode: code,
      );
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.reauthenticateWithCredential(cred);
      } else {
        await FirebaseAuth.instance.signInWithCredential(cred);
        _signedInByFlow = true;
      }
    } on FirebaseAuthException catch (e) {
      log("PAYMENT OTP VERIFY FAILED -> ${e.code}");
      throw Exception(
        e.code == 'invalid-verification-code'
            ? "Invalid code"
            : (e.message ?? "Verification failed"),
      );
    }
  }

  /// Fresh ID token (auth_time = now) for the backend to check.
  static Future<String> freshIdToken() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
    if (token == null || token.isEmpty) {
      throw Exception("Could not get phone verification proof");
    }
    return token;
  }

  /// Call when the OTP step ends. Signs out only if this flow signed in.
  static Future<void> finish() async {
    if (_signedInByFlow) {
      _signedInByFlow = false;
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        log("PHONE SIGNOUT ERROR -> $e");
      }
    }
    _verificationId = null;
    _resendToken = null;
  }
}
