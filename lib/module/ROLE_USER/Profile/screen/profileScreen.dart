import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controller/profileScreenController.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileScreenController controller = Get.put(ProfileScreenController());
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile & Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).appBarTheme.foregroundColor,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value || controller.isLoadingProfile.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading Profile...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.hasProfileError.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 80,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to Load Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.profileErrorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => controller.fetchUserProfile(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            controller.fetchUserProfile();
            controller.loadUserSettings();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Header Section
                _buildProfileHeader(controller),
                const SizedBox(height: 24),
                
                // Quick Actions Section
                _buildQuickActions(controller),
                const SizedBox(height: 24),
                
                // Settings Section
                _buildSettingsSection(controller),
                const SizedBox(height: 24),
                
                // Learning Section
                _buildLearningSection(controller),
                const SizedBox(height: 24),
                
                // Support Section
                _buildSupportSection(controller),
                const SizedBox(height: 24),
                
                // Legal Section
                _buildLegalSection(controller),
                const SizedBox(height: 24),
                
                // Logout Button
                _buildLogoutButton(controller),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(ProfileScreenController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getCardShadow(Get.context!),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Picture
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.blue[400]!, Colors.blue[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Obx(() {
              final imageUrl = controller.userImage.value;
              if (imageUrl.isNotEmpty) {
                return ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                );
              } else {
                return const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                );
              }
            }),
          ),
          const SizedBox(height: 16),
          
          // User Name
          Obx(() => Text(
            controller.userProfile.value?.displayName ?? 
            (controller.userName.value.isNotEmpty ? controller.userName.value : 'User'),
            style: Theme.of(Get.context!).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          )),
          const SizedBox(height: 4),
          
          // User Email
          Obx(() => Text(
            controller.userProfile.value?.email ?? 
            (controller.userEmail.value.isNotEmpty ? controller.userEmail.value : 'user@example.com'),
            style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
              color: AppTheme.getTextSecondaryColor(Get.context!),
            ),
          )),
          const SizedBox(height: 8),
          
          // User Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(() => Text(
              controller.userProfile.value?.roleDisplayName ?? 
              (controller.userRole.value.isNotEmpty ? controller.userRole.value : 'Student'),
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(Get.context!).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            )),
          ),
          const SizedBox(height: 16),
          
          // Edit Profile Button
          ElevatedButton.icon(
            onPressed: controller.editProfile,
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ProfileScreenController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.school,
                  title: 'My Courses',
                  subtitle: 'View enrolled courses',
                  onTap: controller.viewEnrolledCourses,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.trending_up,
                  title: 'Progress',
                  subtitle: 'Learning progress',
                  onTap: controller.viewLearningProgress,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(ProfileScreenController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.getCardShadow(Get.context!),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(Get.context!).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSettingItem(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Push notifications and alerts',
            trailing: Obx(() => Switch(
              value: controller.notificationsEnabled.value,
              onChanged: (_) => controller.toggleNotifications(),
              activeColor: Theme.of(Get.context!).colorScheme.primary,
            )),
          ),
          
          _buildSettingItem(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Switch to dark theme',
            trailing: Obx(() => Switch(
              value: Get.find<ThemeController>().isDarkMode.value,
              onChanged: (_) => controller.toggleDarkMode(),
              activeColor: Theme.of(Get.context!).colorScheme.primary,
            )),
          ),
          
          _buildSettingItem(
            icon: Icons.play_circle,
            title: 'Auto Play Videos',
            subtitle: 'Automatically play videos',
            trailing: Obx(() => Switch(
              value: controller.autoPlayVideos.value,
              onChanged: (_) => controller.toggleAutoPlayVideos(),
              activeColor: Theme.of(Get.context!).colorScheme.primary,
            )),
          ),
          
          _buildSettingItem(
            icon: Icons.wifi,
            title: 'Download over WiFi Only',
            subtitle: 'Save mobile data',
            trailing: Obx(() => Switch(
              value: controller.downloadOverWifiOnly.value,
              onChanged: (_) => controller.toggleDownloadOverWifiOnly(),
              activeColor: Theme.of(Get.context!).colorScheme.primary,
            )),
          ),
          
          _buildSettingItem(
            icon: Icons.lock,
            title: 'Change Password',
            subtitle: 'Update your password',
            trailing: Icon(
              Icons.arrow_forward_ios, 
              size: 16, 
              color: AppTheme.getIconColor(Get.context!),
            ),
            onTap: controller.changePassword,
          ),
        ],
      ),
    );
  }

  Widget _buildLearningSection(ProfileScreenController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Learning',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSettingItem(
            icon: Icons.bookmark,
            title: 'Bookmarked Lessons',
            subtitle: 'Your saved lessons',
            trailing: Icon(
              Icons.arrow_forward_ios, 
              size: 16, 
              color: AppTheme.getIconColor(Get.context!),
            ),
            onTap: () => Get.snackbar('Coming Soon', 'Bookmarked lessons feature will be available soon'),
          ),
          
          _buildSettingItem(
            icon: Icons.download,
            title: 'Downloaded Content',
            subtitle: 'Manage offline content',
            trailing: Icon(
              Icons.arrow_forward_ios, 
              size: 16, 
              color: AppTheme.getIconColor(Get.context!),
            ),
            onTap: () => Get.snackbar('Coming Soon', 'Downloaded content feature will be available soon'),
          ),
          
          _buildSettingItem(
            icon: Icons.quiz,
            title: 'Quiz History',
            subtitle: 'View your quiz results',
            trailing: Icon(
              Icons.arrow_forward_ios, 
              size: 16, 
              color: AppTheme.getIconColor(Get.context!),
            ),
            onTap: () => Get.snackbar('Coming Soon', 'Quiz history feature will be available soon'),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(ProfileScreenController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Support',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSettingItem(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            trailing: Icon(
              Icons.arrow_forward_ios, 
              size: 16, 
              color: AppTheme.getIconColor(Get.context!),
            ),
            onTap: controller.contactSupport,
          ),
          
          _buildSettingItem(
            icon: Icons.feedback,
            title: 'Send Feedback',
            subtitle: 'Share your thoughts',
            trailing: Icon(
              Icons.arrow_forward_ios, 
              size: 16, 
              color: AppTheme.getIconColor(Get.context!),
            ),
            onTap: () => Get.snackbar('Coming Soon', 'Feedback feature will be available soon'),
          ),
          
          _buildSettingItem(
            icon: Icons.star_rate,
            title: 'Rate App',
            subtitle: 'Rate us on the app store',
            trailing: Icon(
              Icons.arrow_forward_ios, 
              size: 16, 
              color: AppTheme.getIconColor(Get.context!),
            ),
            onTap: () => Get.snackbar('Coming Soon', 'Rate app feature will be available soon'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSection(ProfileScreenController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildSettingItem(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'How we protect your data',
            trailing: Icon(
              Icons.arrow_forward_ios, 
              size: 16, 
              color: AppTheme.getIconColor(Get.context!),
            ),
            onTap: controller.privacyPolicy,
          ),
          
          _buildSettingItem(
            icon: Icons.description,
            title: 'Terms of Service',
            subtitle: 'Terms and conditions',
            trailing: Icon(
              Icons.arrow_forward_ios, 
              size: 16, 
              color: AppTheme.getIconColor(Get.context!),
            ),
            onTap: controller.termsOfService,
          ),
          
          _buildSettingItem(
            icon: Icons.info,
            title: 'About App',
            subtitle: 'App version and information',
            trailing: Icon(
              Icons.arrow_forward_ios, 
              size: 16, 
              color: AppTheme.getIconColor(Get.context!),
            ),
            onTap: controller.aboutApp,
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(ProfileScreenController controller) {
    return Obx(() => SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: controller.isLoggingOut.value ? null : controller.logout,
        icon: controller.isLoggingOut.value 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.logout, size: 20),
        label: Text(
          controller.isLoggingOut.value ? 'Logging Out...' : 'Logout',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
    ));
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(Get.context!).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon, 
            color: Theme.of(Get.context!).colorScheme.primary, 
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
            color: AppTheme.getTextSecondaryColor(Get.context!),
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
