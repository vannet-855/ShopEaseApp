import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_icon.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final String? prefixAsset;
  final IconData? suffixIcon;
  final String? suffixAsset;
  final VoidCallback? onSuffixTap;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.prefixAsset,
    this.suffixIcon,
    this.suffixAsset,
    this.onSuffixTap,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelMedium),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixAsset != null
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: AppIcon(prefixAsset!, size: 18, color: AppColors.textHint),
                  )
                : prefixIcon != null
                    ? Icon(prefixIcon, size: 20, color: AppColors.textHint)
                    : null,
            suffixIcon: suffixAsset != null
                ? GestureDetector(
                    onTap: onSuffixTap,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: AppIcon(suffixAsset!, size: 18, color: AppColors.textHint),
                    ),
                  )
                : suffixIcon != null
                    ? GestureDetector(
                        onTap: onSuffixTap,
                        child: Icon(suffixIcon, size: 20, color: AppColors.textHint),
                      )
                    : null,
          ),
        ),
      ],
    );
  }
}
