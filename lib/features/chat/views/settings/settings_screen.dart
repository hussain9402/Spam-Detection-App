import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/language_controller.dart';
import '../../../../core/utils/theme_controller.dart';
import '../../../authentication/controllers/auth_controller.dart';
import '../profile/user_profile_screen.dart';
import 'language_selection_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final LanguageController languageController =
        Get.find<LanguageController>();
    final ThemeController themeController = Get.find<ThemeController>();
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.headerDarkGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppColors.headerDarkGreen,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.search, color: AppColors.textWhite),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Text(
                      localizations.settings,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppColors.textWhite,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Settings Content
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    // User Profile Section
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.headerDarkGreen,
                              ),
                              child:
                                  authController.currentUser.value?.photoUrl !=
                                      null
                                  ? ClipOval(
                                      child: Image.network(
                                        authController
                                            .currentUser
                                            .value!
                                            .photoUrl!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      color: AppColors.textWhite,
                                      size: 32,
                                    ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    authController.currentUser.value?.name ??
                                        'User',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    localizations.neverGiveUp,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textLightGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.qr_code_2,
                                color: AppColors.textLightGray,
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Divider(height: 1),

                    // Settings Options
                    Expanded(
                      child: ListView(
                        children: [
                          _buildSettingsItem(
                            context: context,
                            icon: Icons.lock_outline,
                            title: localizations.account,
                            subtitle: localizations.accountSubtitle,
                            onTap: () {
                              if (authController.currentUser.value != null) {
                                Get.to(
                                  () => UserProfileScreen(
                                    // This ensures the actual user object (including phone) is passed
                                    user: authController.currentUser.value!,
                                  ),
                                );
                              }
                            },
                          ),
                          Obx(
                            () => _buildSettingsItem(
                              context: context,
                              icon: Icons.language,
                              title: localizations.appLanguage,
                              subtitle: languageController
                                  .getCurrentLanguageName(),
                              onTap: () {
                                Get.to(() => const LanguageSelectionScreen());
                              },
                            ),
                          ),
                          _buildSettingsItem(
                            context: context,
                            icon: Icons.notifications_outlined,
                            title: localizations.notifications,
                            subtitle: localizations.notificationsSubtitle,
                            onTap: () {},
                          ),
                          _buildSettingsItem(
                            context: context,
                            icon: Icons.help_outline,
                            title: localizations.help,
                            subtitle: localizations.helpSubtitle,
                            onTap: () {},
                          ),
                          Obx(
                            () => _buildSettingsItem(
                              context: context,
                              icon: Icons.palette_outlined,
                              title: localizations.appTheme,
                              subtitle: themeController.getCurrentThemeName(
                                localizations.lightTheme,
                                localizations.darkTheme,
                                localizations.systemTheme,
                              ),
                              onTap: () {
                                _showThemeDialog(
                                  context,
                                  themeController,
                                  localizations,
                                );
                              },
                            ),
                          ),
                          _buildSettingsItem(
                            context: context,
                            icon: Icons.person_add_outlined,
                            title: localizations.inviteAFriend,
                            subtitle: null,
                            onTap: () {},
                          ),
                          const SizedBox(height: 16),
                          // Logout button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ElevatedButton(
                              onPressed: () {
                                authController.logout();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.errorRed,
                                foregroundColor: AppColors.textBlack,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                localizations.logout,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textLightGray, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textLightGray,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textLightGray),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(
    BuildContext context,
    ThemeController themeController,
    AppLocalizations localizations,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Obx(
          () => AlertDialog(
            backgroundColor: Theme.of(context).dialogBackgroundColor,
            title: Text(
              localizations.appTheme,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildThemeOption(
                  context: context,
                  themeController: themeController,
                  themeMode: 'light',
                  themeName: localizations.lightTheme,
                  icon: Icons.light_mode,
                  currentMode: themeController.themeMode.value,
                ),
                const SizedBox(height: 8),
                _buildThemeOption(
                  context: context,
                  themeController: themeController,
                  themeMode: 'dark',
                  themeName: localizations.darkTheme,
                  icon: Icons.dark_mode,
                  currentMode: themeController.themeMode.value,
                ),
                const SizedBox(height: 8),
                _buildThemeOption(
                  context: context,
                  themeController: themeController,
                  themeMode: 'system',
                  themeName: localizations.systemTheme,
                  icon: Icons.brightness_auto,
                  currentMode: themeController.themeMode.value,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeController themeController,
    required String themeMode,
    required String themeName,
    required IconData icon,
    required String currentMode,
  }) {
    final isSelected = currentMode == themeMode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Use blue for selection in dark theme, primary color in light theme
    final selectionColor = isDark
        ? AppColors.selectionBlue
        : AppColors.primaryTeal;

    return InkWell(
      onTap: () {
        themeController.setThemeMode(themeMode);
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? AppColors.selectionBlue.withOpacity(0.2)
                    : AppColors.primaryTeal.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: selectionColor, width: 2)
              : Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.dividerGray,
                  width: 1,
                ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? selectionColor
                  : (isDark
                        ? AppColors.textLightGray
                        : AppColors.textLightGray),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                themeName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? selectionColor
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check, color: selectionColor, size: 20),
          ],
        ),
      ),
    );
  }
}
