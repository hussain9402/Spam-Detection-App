import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  
  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.errorText,
    this.onChanged,
    this.controller,
    this.focusNode,
  });
  
  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: hasError ? AppColors.errorRed : AppColors.primaryTeal,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: AppColors.textGray,
              fontSize: 16,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: hasError ? AppColors.errorRed : AppColors.borderGray,
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.primaryTeal,
                width: 2,
              ),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.errorRed,
              ),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.errorRed,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, right: 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                errorText!,
                style: const TextStyle(
                  color: AppColors.errorRed,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

