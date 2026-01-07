import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum SocialProvider {
  facebook,
  google,
  apple,
}

class SocialLoginButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback? onPressed;
  
  const SocialLoginButton({
    super.key,
    required this.provider,
    this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _getBackgroundColor(),
          border: Border.all(
            color: AppColors.borderGray,
            width: 1,
          ),
        ),
        child: Center(
          child: _getIcon(),
        ),
      ),
    );
  }
  
  Color _getBackgroundColor() {
    switch (provider) {
      case SocialProvider.facebook:
        return AppColors.facebookBlue;
      case SocialProvider.google:
        return AppColors.googleBackground;
      case SocialProvider.apple:
        return AppColors.appleBlack;
    }
  }
  
  Widget _getIcon() {
    switch (provider) {
      case SocialProvider.facebook:
        return const Text(
          'f',
          style: TextStyle(
            color: AppColors.textWhite,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        );
      case SocialProvider.google:
        return const Text(
          'G',
          style: TextStyle(
            color: AppColors.textBlack,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Arial',
          ),
        );
      case SocialProvider.apple:
        return Icon(
          Icons.apple,
          color: AppColors.textWhite,
          size: 24,
        );
    }
  }
}

