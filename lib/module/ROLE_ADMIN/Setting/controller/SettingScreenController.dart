import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../../routes/app_pages.dart';

class SettingsControllers extends GetxController {
  var isLoading = false.obs;
  var isLoggingOut = false.obs;
  
  SharedPrefHelper sharedPrefHelper = SharedPrefHelper();
  
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    loadUserData();
  }

  void loadUserData() async {
    try{
      isLoading.value = true;
      // Load user data from SharedPreferences if needed
      isLoading.value = false;
    }catch(e){
      isLoading.value = false;
    }
  }

  /// Show logout confirmation dialog
  Future<void> showLogoutConfirmation() async {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 10),
            Text('Confirm Logout'),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?\nThis will clear all your local data.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close dialog
              signOut(); // Proceed with logout
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Logout'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// Complete logout process - Local Storage Only
  Future<void> signOut() async {
    try {
      isLoggingOut.value = true;
      
      // Show loading dialog
      Get.dialog(
        WillPopScope(
          onWillPop: () async => false, // Prevent back button during logout
          child: AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Logging out...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Clear all local data from SharedPreferences
      await clearAllLocalData();

      // Small delay to show the loading state
      await Future.delayed(Duration(milliseconds: 1500));

      // Close loading dialog
      Get.back();

      // Navigate to login screen and clear all previous routes
      Get.offAllNamed(Routes.LoginScreen);

      // Show success message
      Get.snackbar(
        'Success',
        'Logged out successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: Icon(Icons.check_circle, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
      );

    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      // Show error message
      Get.snackbar(
        'Error',
        'Failed to logout: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: Icon(Icons.error, color: Colors.white),
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
      
      print('Logout error: $e');
    } finally {
      isLoggingOut.value = false;
    }
  }

  /// Clear all local data from SharedPreferences
  Future<void> clearAllLocalData() async {
    try {
      // Clear specific user-related data
      await sharedPrefHelper.remove(SharedPrefHelper.token);
      await sharedPrefHelper.remove(SharedPrefHelper.userEmail);
      await sharedPrefHelper.remove(SharedPrefHelper.userPassword);
      await sharedPrefHelper.remove(SharedPrefHelper.loginStatus);
      await sharedPrefHelper.remove(SharedPrefHelper.IsAdmin);
      await sharedPrefHelper.remove(SharedPrefHelper.userName);
      await sharedPrefHelper.remove(SharedPrefHelper.instructorLoginStatus);
      
      // Alternatively, you can clear all data (uncomment if needed)
      // await sharedPrefHelper.clear();
      
      print('Local data cleared successfully');
    } catch (e) {
      print('Error clearing local data: $e');
      throw e;
    }
  }

  /// Check if user is logged in
  bool isUserLoggedIn() {
    return sharedPrefHelper.getBool(SharedPrefHelper.loginStatus) ||
           sharedPrefHelper.getBool(SharedPrefHelper.IsAdmin) ||
           sharedPrefHelper.getBool(SharedPrefHelper.instructorLoginStatus);
  }

  /// Get current user info
  Map<String, dynamic> getCurrentUserInfo() {
    return {
      'email': sharedPrefHelper.getString(SharedPrefHelper.userEmail) ?? 'admin@example.com',
      'name': sharedPrefHelper.getString(SharedPrefHelper.userName) ?? 'Admin',
      'isAdmin': sharedPrefHelper.getBool(SharedPrefHelper.IsAdmin),
      'isInstructor': sharedPrefHelper.getBool(SharedPrefHelper.instructorLoginStatus),
    };
  }
}