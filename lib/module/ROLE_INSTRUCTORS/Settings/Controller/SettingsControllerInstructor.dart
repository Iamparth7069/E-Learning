import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../../routes/app_pages.dart';
import '../../../../api/settings/settings_service.dart';

class SettingControllerInstructor extends GetxController {
  String UserName = "";
  String userEmail = "";
  String userPhone = "";
  String userBio = "";
  String profileImage = "";
  SharedPrefHelper sharedPrefHelper = SharedPrefHelper();
  
  // Loading states
  RxBool isLoggingOut = false.obs;
  RxBool isLoading = false.obs;
  RxBool isUpdatingProfile = false.obs;
  RxBool isChangingPassword = false.obs;
  
  // Notification settings
  RxBool emailNotifications = true.obs;
  RxBool pushNotifications = true.obs;
  RxBool courseUpdates = true.obs;
  RxBool marketingEmails = false.obs;
  
  // Privacy settings
  RxBool profileVisibility = true.obs;
  RxBool showEmail = false.obs;
  RxBool showPhone = false.obs;
  RxBool allowMessages = true.obs;
  
  // App settings
  RxString selectedTheme = 'system'.obs;
  RxString selectedLanguage = 'en'.obs;
  RxBool autoPlay = true.obs;
  RxBool downloadOverWifi = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _loadSettings();
  }

  void _loadUserData() {
    try {
      UserName = sharedPrefHelper.getString(SharedPrefHelper.userName) ?? "Instructor";
      userEmail = sharedPrefHelper.getString(SharedPrefHelper.userEmail) ?? "";
      update();
    } catch (e) {
      print("❌ Error loading user data: $e");
      UserName = "Instructor";
      update();
    }
  }

  Future<void> _loadSettings() async {
    try {
      isLoading.value = true;
      
      // Load profile data
      await _loadProfileData();
      
      // Load notification settings
      await _loadNotificationSettings();
      
      // Load privacy settings
      await _loadPrivacySettings();
      
      // Load app settings
      await _loadAppSettings();
      
    } catch (e) {
      print("❌ Error loading settings: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadProfileData() async {
    try {
      final response = await SettingsService.getUserProfile();
      if (response['statusCode'] == 200 && response['response'] != null) {
        final data = response['response'];
        UserName = data['name'] ?? UserName;
        userEmail = data['email'] ?? userEmail;
        userPhone = data['phone'] ?? "";
        userBio = data['bio'] ?? "";
        profileImage = data['profile_image'] ?? "";
        update();
      }
    } catch (e) {
      print("❌ Error loading profile data: $e");
    }
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final response = await SettingsService.getNotificationSettings();
      if (response['statusCode'] == 200 && response['response'] != null) {
        final data = response['response'];
        emailNotifications.value = data['email_notifications'] ?? true;
        pushNotifications.value = data['push_notifications'] ?? true;
        courseUpdates.value = data['course_updates'] ?? true;
        marketingEmails.value = data['marketing_emails'] ?? false;
      }
    } catch (e) {
      print("❌ Error loading notification settings: $e");
    }
  }

  Future<void> _loadPrivacySettings() async {
    try {
      final response = await SettingsService.getPrivacySettings();
      if (response['statusCode'] == 200 && response['response'] != null) {
        final data = response['response'];
        profileVisibility.value = data['profile_visibility'] ?? true;
        showEmail.value = data['show_email'] ?? false;
        showPhone.value = data['show_phone'] ?? false;
        allowMessages.value = data['allow_messages'] ?? true;
      }
    } catch (e) {
      print("❌ Error loading privacy settings: $e");
    }
  }

  Future<void> _loadAppSettings() async {
    try {
      final response = await SettingsService.getAppSettings();
      if (response['statusCode'] == 200 && response['response'] != null) {
        final data = response['response'];
        selectedTheme.value = data['theme'] ?? 'system';
        selectedLanguage.value = data['language'] ?? 'en';
        autoPlay.value = data['auto_play'] ?? true;
        downloadOverWifi.value = data['download_over_wifi'] ?? true;
      }
    } catch (e) {
      print("❌ Error loading app settings: $e");
    }
  }

  Future<void> logout() async {
    try {
      isLoggingOut.value = true;
      
      // Clear all authentication data from SharedPreferences
      await _clearAuthenticationData();
      
      // Show success message
      Get.snackbar(
        "Success",
        "You have been logged out successfully",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
      );
      
      // Navigate to login screen and clear navigation stack
      Get.offAllNamed(Routes.LETYOUINSCREEN);
      
    } catch (e) {
      print("❌ Error during logout: $e");
      Get.snackbar(
        "Error",
        "An error occurred during logout. Please try again.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoggingOut.value = false;
    }
  }

  Future<void> _clearAuthenticationData() async {
    try {
      // Use the new method from SharedPrefHelper
      await sharedPrefHelper.clearAuthenticationData();
      print("✅ Authentication data cleared successfully");
    } catch (e) {
      print("❌ Error clearing authentication data: $e");
      // If the specific method fails, try clearing all preferences
      await sharedPrefHelper.clear();
    }
  }

  // Profile Management Methods
  Future<void> updateProfile({
    required String name,
    String? email,
    String? phone,
    String? bio,
  }) async {
    try {
      isUpdatingProfile.value = true;
      
      final response = await SettingsService.updateUserProfile(
        name: name,
        email: email,
        phone: phone,
        bio: bio,
      );
      
      if (response['statusCode'] == 200) {
        UserName = name;
        if (email != null) userEmail = email;
        if (phone != null) userPhone = phone;
        if (bio != null) userBio = bio;
        
        // Update SharedPreferences
        await sharedPrefHelper.setString(SharedPrefHelper.userName, name);
        if (email != null) {
          await sharedPrefHelper.setString(SharedPrefHelper.userEmail, email);
        }
        
        update();
        
        Get.snackbar(
          "Success",
          "Profile updated successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          response['response']?['message'] ?? "Failed to update profile",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update profile: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isUpdatingProfile.value = false;
    }
  }

  // Password Change Method
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      isChangingPassword.value = true;
      
      final response = await SettingsService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      
      if (response['statusCode'] == 200) {
        Get.snackbar(
          "Success",
          "Password changed successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          response['response']?['message'] ?? "Failed to change password",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to change password: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isChangingPassword.value = false;
    }
  }

  // Notification Settings Methods
  Future<void> updateNotificationSettings() async {
    try {
      final response = await SettingsService.updateNotificationSettings(
        emailNotifications: emailNotifications.value,
        pushNotifications: pushNotifications.value,
        courseUpdates: courseUpdates.value,
        marketingEmails: marketingEmails.value,
      );
      
      if (response['statusCode'] == 200) {
        Get.snackbar(
          "Success",
          "Notification settings updated",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to update notification settings",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update notification settings: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Privacy Settings Methods
  Future<void> updatePrivacySettings() async {
    try {
      final response = await SettingsService.updatePrivacySettings(
        profileVisibility: profileVisibility.value,
        showEmail: showEmail.value,
        showPhone: showPhone.value,
        allowMessages: allowMessages.value,
      );
      
      if (response['statusCode'] == 200) {
        Get.snackbar(
          "Success",
          "Privacy settings updated",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to update privacy settings",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update privacy settings: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // App Settings Methods
  Future<void> updateAppSettings() async {
    try {
      final response = await SettingsService.updateAppSettings(
        theme: selectedTheme.value,
        language: selectedLanguage.value,
        autoPlay: autoPlay.value,
        downloadOverWifi: downloadOverWifi.value,
      );
      
      if (response['statusCode'] == 200) {
        Get.snackbar(
          "Success",
          "App settings updated",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to update app settings",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update app settings: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Clear Cache Method
  Future<void> clearAppCache() async {
    try {
      final response = await SettingsService.clearCache();
      
      if (response['statusCode'] == 200) {
        Get.snackbar(
          "Success",
          "Cache cleared successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to clear cache",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to clear cache: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Contact Support Method
  Future<void> contactSupport({
    required String subject,
    required String message,
    String? category,
  }) async {
    try {
      final response = await SettingsService.contactSupport(
        subject: subject,
        message: message,
        category: category,
      );
      
      if (response['statusCode'] == 200) {
        Get.snackbar(
          "Success",
          "Support message sent successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to send support message",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to send support message: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text("Logout"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to logout?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              "You will need to login again to access your account.",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel"),
          ),
          Obx(() => ElevatedButton(
            onPressed: isLoggingOut.value ? null : () async {
              Get.back(); // Close dialog
              await logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: isLoggingOut.value
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text("Logging out..."),
                    ],
                  )
                : Text("Logout"),
          )),
        ],
      ),
    );
  }





}