import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../models/contact_model.dart';

class ProfileScreen extends StatelessWidget {
  final ContactModel contact;

  const ProfileScreen({
    super.key,
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: AppColors.headerDarkGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Back Button
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
                  const Spacer(),
                ],
              ),
            ),
            
            // Profile Header Section
            Container(
              padding: const EdgeInsets.only(bottom: 40),
              color: AppColors.headerDarkGreen,
              child: Column(
                children: [
                  // Profile Picture
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.yellow[700],
                      border: Border.all(
                        color: AppColors.textWhite,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.textWhite,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Name and Username
                  Text(
                    contact.name,
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${contact.name.toLowerCase().replaceAll(' ', '')}',
                    style: TextStyle(
                      color: AppColors.textWhite.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(
                        icon: Icons.message,
                        onTap: () {},
                      ),
                      const SizedBox(width: 24),
                      _buildActionButton(
                        icon: Icons.videocam,
                        onTap: () {},
                      ),
                      const SizedBox(width: 24),
                      _buildActionButton(
                        icon: Icons.phone,
                        onTap: () {},
                      ),
                      const SizedBox(width: 24),
                      _buildActionButton(
                        icon: Icons.more_vert,
                        onTap: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Content Card
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
                    // Small drag indicator
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.borderGray,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    
                    // Profile Details
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildDetailItem(
                            context: context,
                            label: localizations.displayName,
                            value: contact.name,
                          ),
                          const SizedBox(height: 16),
                          _buildDetailItem(
                            context: context,
                            label: localizations.emailAddress,
                            value: contact.email ?? '${contact.name.toLowerCase().replaceAll(' ', '')}20@gmail.com',
                          ),
                          const SizedBox(height: 16),
                          _buildDetailItem(
                            context: context,
                            label: localizations.address,
                            value: contact.address ?? '33 street west subidbazar,sylhet',
                          ),
                          const SizedBox(height: 16),
                          _buildDetailItem(
                            context: context,
                            label: localizations.phoneNumber,
                            value: contact.phone ?? '(320) 555-0104',
                          ),
                          const SizedBox(height: 24),
                          
                          // Media Shared Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                localizations.mediaShared,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textLightGray,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  localizations.viewAll,
                                  style: const TextStyle(
                                    color: AppColors.primaryTeal,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Media Grid
                          Row(
                            children: [
                              Expanded(
                                child: _buildMediaThumbnail(
                                  color: Colors.blue[200]!,
                                  image: Icons.water_drop,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildMediaThumbnail(
                                  color: Colors.yellow[600]!,
                                  image: Icons.videocam,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildMediaThumbnail(
                                  color: Colors.grey[800]!,
                                  image: Icons.photo_library,
                                  count: '255+',
                                ),
                              ),
                            ],
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

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.textWhite.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.textWhite,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required BuildContext context,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textLightGray,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildMediaThumbnail({
    required Color color,
    IconData? image,
    String? count,
  }) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: image != null
            ? Icon(
                image,
                color: AppColors.textWhite,
                size: 32,
              )
            : Center(
                child: Text(
                  count ?? '',
                  style: const TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
    );
  }
}

