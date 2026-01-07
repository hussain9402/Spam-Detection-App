import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
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
                icon: Icons.message_rounded,
                label: localizations.message,
                index: 0,
                isSelected: currentIndex == 0,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.phone_rounded,
                label: localizations.calls,
                index: 1,
                isSelected: currentIndex == 1,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person_rounded,
                label: localizations.contacts,
                index: 2,
                isSelected: currentIndex == 2,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.settings_rounded,
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
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? AppColors.primaryTeal 
                  : (Theme.of(context).brightness == Brightness.dark 
                      ? AppColors.textLightGray 
                      : AppColors.textLightGray),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected 
                    ? AppColors.primaryTeal 
                    : (Theme.of(context).brightness == Brightness.dark 
                        ? AppColors.textLightGray 
                        : AppColors.textLightGray),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

