import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../../api/listing/api_listing.dart';
import '../../../../api/url/api_url.dart';
import '../../../login/Model/UserModel.dart';
import '../model/UserProfileModel.dart';
import '../../../../core/theme/theme_controller.dart';

class ProfileScreenController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var isLoggingOut = false.obs;
  var isLoadingProfile = false.obs;
  var hasProfileError = false.obs;
  var profileErrorMessage = ''.obs;
  
  // User profile data
  var userProfile = Rxn<UserProfileModel>();
  var userImage = ''.obs;
  
  // Settings
  var notificationsEnabled = true.obs;
  var autoPlayVideos = true.obs;
  var downloadOverWifiOnly = true.obs;
  
  // Shared preferences helper
  SharedPrefHelper sharedPrefHelper = SharedPrefHelper();
  
  // Theme controller
  late ThemeController themeController;
  
  // User information (fallback from shared preferences)
  var userName = ''.obs;
  var userEmail = ''.obs;
  var userRole = ''.obs;
  var userId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    themeController = Get.find<ThemeController>();
    loadUserData();
    loadUserSettings();
    fetchUserProfile();
  }

  // Fetch user profile from API
  Future<void> fetchUserProfile() async {
    try {
      isLoadingProfile.value = true;
      hasProfileError.value = false;
      profileErrorMessage.value = '';
      
      String? token = sharedPrefHelper.getString(SharedPrefHelper.token);
      
      if (token == null || token.isEmpty) {
        hasProfileError.value = true;
        profileErrorMessage.value = 'User not authenticated';
        isLoadingProfile.value = false;
        return;
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      print('🔍 Fetching user profile from API...');
      
      final response = await NetworkService.makeGetRequest(
        url: ApiUrl.getUserProfile,
        headers: headers,
      );

      isLoadingProfile.value = false;

      if (response["statusCode"] == 200) {
        userProfile.value = UserProfileModel.fromJson(response['response']);
        
        // Update local variables with API data
        userName.value = userProfile.value?.displayName ?? '';
        userEmail.value = userProfile.value?.email ?? '';
        userRole.value = userProfile.value?.roleDisplayName ?? 'Student';
        userId.value = userProfile.value?.userId ?? 0;
        userImage.value = userProfile.value?.image?.imageUrl ?? '';
        
        print('✅ User profile loaded successfully: ${userProfile.value?.displayName}');
        print('📧 Email: ${userProfile.value?.email}');
        print('👤 Role: ${userProfile.value?.roleDisplayName}');
        print('🖼️ Image URL: ${userProfile.value?.image?.imageUrl}');
        
      } else {
        hasProfileError.value = true;
        profileErrorMessage.value = response["response"]?.toString() ?? 'Failed to load profile';
        print('❌ Profile API error: ${profileErrorMessage.value}');
        
        // Fallback to shared preferences data
        loadUserData();
      }
    } catch (e) {
      isLoadingProfile.value = false;
      hasProfileError.value = true;
      profileErrorMessage.value = 'An unexpected error occurred: ${e.toString()}';
      print('❌ Profile fetch error: $e');
      
      // Fallback to shared preferences data
      loadUserData();
    }
  }

  // Load user data from shared preferences (fallback)
  void loadUserData() {
    try {
      userName.value = sharedPrefHelper.getString(SharedPrefHelper.userName) ?? '';
      userEmail.value = sharedPrefHelper.getString(SharedPrefHelper.userEmail) ?? '';
      userRole.value = 'Student'; // Default role for user
      
      print('👤 User data loaded from SharedPreferences: ${userName.value}');
    } catch (e) {
      print('❌ Error loading user data: $e');
    }
  }

  // Load user settings from shared preferences
  void loadUserSettings() {
    try {
      notificationsEnabled.value = sharedPrefHelper.getBool('notifications_enabled') ?? true;
      autoPlayVideos.value = sharedPrefHelper.getBool('autoplay_videos') ?? true;
      downloadOverWifiOnly.value = sharedPrefHelper.getBool('download_wifi_only') ?? true;
    } catch (e) {
      print('❌ Error loading user settings: $e');
    }
  }

  // Save user settings to shared preferences
  Future<void> saveUserSettings() async {
    try {
      await sharedPrefHelper.setBool('notifications_enabled', notificationsEnabled.value);
      await sharedPrefHelper.setBool('autoplay_videos', autoPlayVideos.value);
      await sharedPrefHelper.setBool('download_wifi_only', downloadOverWifiOnly.value);
      
      Get.snackbar(
        'Settings Saved',
        'Your preferences have been updated',
        backgroundColor: themeController.getSuccessColor(Get.context!),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      print('❌ Error saving user settings: $e');
      Get.snackbar(
        'Error',
        'Failed to save settings',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  // Toggle notification settings
  void toggleNotifications() {
    notificationsEnabled.value = !notificationsEnabled.value;
    saveUserSettings();
  }

  // Toggle dark mode
  void toggleDarkMode() {
    themeController.toggleTheme();
  }

  // Toggle auto play videos
  void toggleAutoPlayVideos() {
    autoPlayVideos.value = !autoPlayVideos.value;
    saveUserSettings();
  }

  // Toggle download over WiFi only
  void toggleDownloadOverWifiOnly() {
    downloadOverWifiOnly.value = !downloadOverWifiOnly.value;
    saveUserSettings();
  }

  // Logout functionality
  Future<void> logout() async {
    try {
      isLoggingOut.value = true;
      
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Logout'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Clear authentication data
        await sharedPrefHelper.clearAuthenticationData();
        
        // Show success message
        Get.snackbar(
          'Logged Out',
          'You have been successfully logged out',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          icon: const Icon(Icons.logout, color: Colors.white),
        );
        
        // Navigate to login screen
        Get.offAllNamed('/LoginScreen');
      }
    } catch (e) {
      print('❌ Error during logout: $e');
      Get.snackbar(
        'Error',
        'Failed to logout. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isLoggingOut.value = false;
    }
  }

  // Edit profile functionality
  void editProfile() {
    final firstNameController = TextEditingController(text: userProfile.value?.firstName ?? '');
    final lastNameController = TextEditingController(text: userProfile.value?.lastName ?? '');
    final emailController = TextEditingController(text: userProfile.value?.email ?? '');

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Update local data
              if (userProfile.value != null) {
                userProfile.value = UserProfileModel(
                  userId: userProfile.value!.userId,
                  firstName: firstNameController.text.trim(),
                  lastName: lastNameController.text.trim(),
                  email: emailController.text.trim(),
                  enabled: userProfile.value!.enabled,
                  role: userProfile.value!.role,
                  image: userProfile.value!.image,
                );
                
                // Update observable variables
                userName.value = userProfile.value!.displayName;
                userEmail.value = userProfile.value!.email;
                
                // Save to shared preferences as backup
                sharedPrefHelper.setString(SharedPrefHelper.userName, userName.value);
                sharedPrefHelper.setString(SharedPrefHelper.userEmail, userEmail.value);
              }
              
              Get.back();
              Get.snackbar(
                'Profile Updated',
                'Your profile has been updated successfully',
                backgroundColor: Colors.green,
                colorText: Colors.white,
                icon: const Icon(Icons.check_circle, color: Colors.white),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Change password functionality
  void changePassword() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    var isChangingPassword = false.obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Change Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
                enabled: !isChangingPassword.value,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                enabled: !isChangingPassword.value,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                enabled: !isChangingPassword.value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: isChangingPassword.value ? null : () => Get.back(),
            child: const Text('Cancel'),
          ),
          Obx(() => TextButton(
            onPressed: isChangingPassword.value ? null : () async {
              // Validate inputs
              if (oldPasswordController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter your current password',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  icon: const Icon(Icons.error, color: Colors.white),
                );
                return;
              }

              if (newPasswordController.text.isEmpty) {
                Get.snackbar(
                  'Error',
                  'Please enter a new password',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  icon: const Icon(Icons.error, color: Colors.white),
                );
                return;
              }

              if (newPasswordController.text.length < 6) {
                Get.snackbar(
                  'Error',
                  'New password must be at least 6 characters long',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  icon: const Icon(Icons.error, color: Colors.white),
                );
                return;
              }

              if (newPasswordController.text != confirmPasswordController.text) {
                Get.snackbar(
                  'Error',
                  'New passwords do not match',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  icon: const Icon(Icons.error, color: Colors.white),
                );
                return;
              }

              // Call API to change password
              isChangingPassword.value = true;
              final success = await _changePasswordAPI(
                oldPasswordController.text,
                newPasswordController.text,
              );
              isChangingPassword.value = false;

              if (success) {
                Get.back();
                Get.snackbar(
                  'Password Changed',
                  'Your password has been changed successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                );
              }
            },
            child: isChangingPassword.value 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Change'),
          )),
        ],
      ),
    );
  }

  // API call to change password
  Future<bool> _changePasswordAPI(String oldPassword, String newPassword) async {
    try {
      String? token = sharedPrefHelper.getString(SharedPrefHelper.token);
      
      if (token == null || token.isEmpty) {
        Get.snackbar(
          'Error',
          'User not authenticated',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
        return false;
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      Map<String, dynamic> body = {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      };

      print('🔐 Changing password via API...');
      print('📡 Endpoint: ${ApiUrl.changePassword}');
      
      final response = await NetworkService.makePostRequest(
        url: ApiUrl.changePassword,
        headers: headers,
        body: body,
      );

      print('📊 Change password response: ${response["statusCode"]}');

      if (response["statusCode"] == 200 || response["statusCode"] == 201) {
        print('✅ Password changed successfully');
        return true;
      } else {
        final errorMessage = response["response"]?.toString() ?? 'Failed to change password';
        print('❌ Password change failed: $errorMessage');
        
        Get.snackbar(
          'Error',
          errorMessage,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
        return false;
      }
    } catch (e) {
      print('❌ Password change error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return false;
    }
  }

  // View enrolled courses
  void viewEnrolledCourses() {
    // TODO: Navigate to enrolled courses screen
    Get.snackbar(
      'Coming Soon',
      'Enrolled courses feature will be available soon',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }

  // View learning progress
  void viewLearningProgress() {
    // TODO: Navigate to learning progress screen
    Get.snackbar(
      'Coming Soon',
      'Learning progress feature will be available soon',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: const Icon(Icons.info, color: Colors.white),
    );
  }

  // Contact support
  void contactSupport() {
    Get.dialog(
      AlertDialog(
        title: const Text('Contact Support'),
        content: const Text('For support, please email us at support@elearning.com or call +1-800-123-4567'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // About app
  void aboutApp() {
    Get.dialog(
      AlertDialog(
        title: const Text('About E-Learning App'),
        content: const Text('Version 1.0.0\n\nA comprehensive e-learning platform for students to access courses, lessons, and track their learning progress.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Privacy policy
  void privacyPolicy() {
    Get.dialog(
      AlertDialog(
        title: const Text('Privacy Policy'),
        content: const Text('Your privacy is important to us. We collect and use your personal information only to provide you with the best learning experience. We do not share your information with third parties.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Terms of service
  void termsOfService() {
    Get.dialog(
      AlertDialog(
        title: const Text('Terms of Service'),
        content: const Text('By using this app, you agree to our terms of service. Please use the app responsibly and respect the intellectual property of course creators.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}