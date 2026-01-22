import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart'; // Import your new assets file
import '../../../core/localization/app_localizations.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.black.withOpacity(0.3)
                : AppColors.borderGray.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                iconPath: AppAssets.messages, // Updated to use AppAssets
                label: localizations.message,
                index: 0,
                isSelected: currentIndex == 0,
              ),
              _buildNavItem(
                context: context,
                iconPath: AppAssets.calls, // Updated to use AppAssets
                label: localizations.calls,
                index: 1,
                isSelected: currentIndex == 1,
              ),
              _buildNavItem(
                context: context,
                iconPath: AppAssets.spam, // Updated to use AppAssets
                label: 'Spam',
                index: 2,
                isSelected: currentIndex == 2,
              ),
              _buildNavItem(
                context: context,
                iconPath: AppAssets.settings, // Updated to use AppAssets
                label: localizations.settings,
                index: 3,
                isSelected: currentIndex == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required String iconPath,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    final Color activeColor = AppColors.primaryTeal;
    final Color inactiveColor = Theme.of(context).brightness == Brightness.dark 
        ? AppColors.textLightGray 
        : AppColors.textGray;

    final Color currentColor = isSelected ? activeColor : inactiveColor;

    return Expanded(
      child: InkResponse(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 24,
              height: 24,
              color: currentColor,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.image_not_supported, size: 24, color: currentColor);
              },
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: currentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}