import 'package:flutter/material.dart';
import 'package:junubullion/theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double height;
  final double fontSize;
  final FontWeight fontWeight;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool isLoading; // New property to indicate loading state

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 52,
    this.fontSize = 22,
    this.fontWeight = FontWeight.bold,
    this.borderRadius = 30,
    this.padding,
    this.isLoading = false, // Default value for loading state
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryRed,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
