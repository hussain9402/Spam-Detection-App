import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/language_controller.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LanguageController languageController = Get.find<LanguageController>();
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
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textWhite,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      localizations.appLanguage,
                      style: const TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Placeholder for symmetry
                ],
              ),
            ),
            
            // Language List
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Obx(() => ListView(
                  padding: const EdgeInsets.only(top: 16),
                  children: [
                    _buildLanguageItem(
                      context: context,
                      languageController: languageController,
                      languageCode: 'en',
                      languageName: 'English',
                      flag: '🇬🇧',
                    ),
                    _buildLanguageItem(
                      context: context,
                      languageController: languageController,
                      languageCode: 'ur',
                      languageName: 'اردو (Urdu)',
                      flag: '🇵🇰',
                    ),
                    _buildLanguageItem(
                      context: context,
                      languageController: languageController,
                      languageCode: 'zh',
                      languageName: '中文 (Mandarin Chinese)',
                      flag: '🇨🇳',
                    ),
                    _buildLanguageItem(
                      context: context,
                      languageController: languageController,
                      languageCode: 'es',
                      languageName: 'Español (Spanish)',
                      flag: '🇪🇸',
                    ),
                    _buildLanguageItem(
                      context: context,
                      languageController: languageController,
                      languageCode: 'ar',
                      languageName: 'العربية (Arabic)',
                      flag: '🇸🇦',
                    ),
                    _buildLanguageItem(
                      context: context,
                      languageController: languageController,
                      languageCode: 'de',
                      languageName: 'Deutsch (German)',
                      flag: '🇩🇪',
                    ),
                  ],
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageItem({
    required BuildContext context,
    required LanguageController languageController,
    required String languageCode,
    required String languageName,
    required String flag,
  }) {
    final isSelected = languageController.currentLocale.value.languageCode == languageCode;

    return InkWell(
      onTap: () {
        languageController.changeLanguage(languageCode);
        Navigator.of(context).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                languageName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                color: AppColors.primaryTeal,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}

