import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:junubullion/theme/app_colors.dart';
import 'package:junubullion/widgets/custom_translated_text.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final String? helperText;
  final String? hintText;
  final String? Function(String?)? validator;
  final int? maxLength;
  final String? prefixText;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.helperText,
    this.hintText,
    this.validator,
    this.maxLength,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    log("CustomTextField: Building widget with label: $prefixText");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
            children: const [
              TextSpan(
                text: " *",
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          obscureText: obscureText,
          cursorColor: AppColors.white,
          maxLength: maxLength,
          style: const TextStyle(fontSize: 13, color: AppColors.white),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.white),

            prefixIcon: prefixText != null && prefixText!.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(left: 13, right: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TranslatedText(
                          prefixText!,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(height: 22, width: 1, color: Colors.white54),
                      ],
                    ),
                  )
                : null,

            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),

            filled: true,
            fillColor: AppColors.lightRed,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 13,
            ),
            suffixIcon: suffixIcon,

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.lightRed),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.lightRed),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.lightRed),
            ),
          ),
        ),
      ],
    );
  }
}
