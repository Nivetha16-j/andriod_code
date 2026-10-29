import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:junubullion/services/stripe_service.dart';
import 'package:junubullion/theme/app_colors.dart';

/// Returns the verified Stripe client_secret, or null if closed.
Future<String?> showStripeOtpDialog(
  BuildContext context, {
  required String paymentIntentId,
  required String email,
  String amountText = '',
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) =>
        _VerifyDialog(paymentIntentId: paymentIntentId, email: email),
  );
}

class _VerifyDialog extends StatefulWidget {
  final String paymentIntentId;
  final String email;
  const _VerifyDialog({required this.paymentIntentId, required this.email});

  @override
  State<_VerifyDialog> createState() => _VerifyDialogState();
}

class _VerifyDialogState extends State<_VerifyDialog> {
  final TextEditingController _c = TextEditingController();
  bool _verifying = false;
  bool _resending = false;
  String? _error;
  int _cooldown = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _timer?.cancel();
    setState(() => _cooldown = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _cooldown = _cooldown > 0 ? _cooldown - 1 : 0);
      if (_cooldown == 0) t.cancel();
    });
  }

  String get _masked {
    final p = widget.email.split('@');
    if (p.length != 2 || p[0].length < 3) return widget.email;
    return '${p[0].substring(0, 2)}********@${p[1]}';
  }

  Future<void> _verify() async {
    if (_c.text.trim().length != 6 || _verifying) {
      setState(() => _error = "Enter the 6-digit code");
      return;
    }
    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      final secret = await StripeService.verifyPaymentOtp(
        paymentIntentId: widget.paymentIntentId,
        otp: _c.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context, secret);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _verifying = false;
        _error = e.toString().replaceFirst("Exception: ", "");
      });
    }
  }

  Future<void> _resend() async {
    if (_resending || _cooldown > 0) return;
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      await StripeService.resendPaymentOtp(
        paymentIntentId: widget.paymentIntentId,
        email: widget.email,
      );
      if (!mounted) return;
      _c.clear();
      _startCooldown();
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst("Exception: ", ""));
      }
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Verify your payment",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _verifying ? null : () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Enter the 6-digit code we sent to $_masked to confirm this payment.",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              TextField(
                controller: _c,
                autofocus: true,
                enabled: !_verifying,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 22, letterSpacing: 8),
                onChanged: (_) => setState(() => _error = null),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '000000',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.black26,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _verifying ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _verifying
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Verify and confirm payment",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: GestureDetector(
                  onTap: (_cooldown > 0 || _resending) ? null : _resend,
                  child: Text(
                    _cooldown > 0
                        ? "Resend code (${_cooldown}s)"
                        : "Resend code",
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: _cooldown > 0 ? Colors.grey : AppColors.primaryRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
