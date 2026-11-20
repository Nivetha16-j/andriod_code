import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneReauthService {
  static String? _verificationId;
  static int? _resendToken;

  /// The logged-in user's own phone number, or null if none.
  static String? get phoneNumber {
    final p = FirebaseAuth.instance.currentUser?.phoneNumber;
    return (p == null || p.isEmpty) ? null : p;
  }

  static bool get isAvailable => phoneNumber != null;

  /// Sends the SMS to the logged-in user's own number.
  static Future<void> sendCode() async {
    final phone = phoneNumber;
    if (phone == null) {
      throw Exception("No verified phone number on this account");
    }

    final completer = Completer<void>();

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      forceResendingToken: _resendToken,
      verificationCompleted: (_) {}, // user types the code
      verificationFailed: (e) {
        log("PAYMENT OTP SEND FAILED -> ${e.code} ${e.message}");
        if (!completer.isCompleted) {
          completer.completeError(
            Exception(e.message ?? "Could not send the code"),
          );
        }
      },
      codeSent: (id, token) {
        _verificationId = id;
        _resendToken = token;
        if (!completer.isCompleted) completer.complete();
      },
      codeAutoRetrievalTimeout: (id) => _verificationId = id,
    );

    await completer.future;
  }

  /// Re-authenticates with the SMS code. Throws if wrong.
  static Future<void> verifyCode(String code) async {
    final user = FirebaseAuth.instance.currentUser;
    final id = _verificationId;
    if (user == null || id == null) {
      throw Exception("Please request a new code");
    }

    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: id,
        smsCode: code,
      );
      await user.reauthenticateWithCredential(cred);
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

  static void reset() {
    _verificationId = null;
    _resendToken = null;
  }
}
