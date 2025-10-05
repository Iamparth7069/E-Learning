import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../../routes/app_pages.dart';

class SettingControllerInstructor extends GetxController {
  String UserName = "";
  SharedPrefHelper sharedPrefHelper = SharedPrefHelper();
  
  // Loading state for logout
  RxBool isLoggingOut = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    try {
      UserName = sharedPrefHelper.getString(SharedPrefHelper.userName) ?? "Instructor";
      update();
    } catch (e) {
      print("❌ Error loading user data: $e");
      UserName = "Instructor";
      update();
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