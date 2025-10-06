import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../SharedPrefrance/SharedPrefrance_helper.dart';
import 'app_theme.dart';

class ThemeController extends GetxController {
  // Observable theme mode
  var isDarkMode = false.obs;
  
  // Shared preferences helper
  SharedPrefHelper sharedPrefHelper = SharedPrefHelper();
  
  // Theme mode getter
  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
  
  @override
  void onInit() {
    super.onInit();
    loadThemePreference();
  }

  // Load theme preference from SharedPreferences
  void loadThemePreference() {
    try {
      isDarkMode.value = sharedPrefHelper.getBool('dark_mode_enabled') ?? false;
      print('🎨 Theme loaded: ${isDarkMode.value ? "Dark" : "Light"} mode');
    } catch (e) {
      print('❌ Error loading theme preference: $e');
      isDarkMode.value = false; // Default to light mode
    }
  }

  // Toggle theme between light and dark
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    saveThemePreference();
    
    // Update GetX theme
    Get.changeThemeMode(themeMode);
    
    print('🎨 Theme toggled to: ${isDarkMode.value ? "Dark" : "Light"} mode');
    
    // Show feedback to user
    Get.snackbar(
      'Theme Changed',
      'Switched to ${isDarkMode.value ? "Dark" : "Light"} mode',
      backgroundColor: isDarkMode.value ? Colors.grey[800] : Colors.grey[200],
      colorText: isDarkMode.value ? Colors.white : Colors.black,
      icon: Icon(
        isDarkMode.value ? Icons.dark_mode : Icons.light_mode,
        color: isDarkMode.value ? Colors.white : Colors.black,
      ),
      duration: const Duration(seconds: 2),
    );
  }

  // Set specific theme mode
  void setThemeMode(bool isDark) {
    if (isDarkMode.value != isDark) {
      isDarkMode.value = isDark;
      saveThemePreference();
      Get.changeThemeMode(themeMode);
      
      print('🎨 Theme set to: ${isDark ? "Dark" : "Light"} mode');
    }
  }

  // Save theme preference to SharedPreferences
  Future<void> saveThemePreference() async {
    try {
      await sharedPrefHelper.setBool('dark_mode_enabled', isDarkMode.value);
      print('💾 Theme preference saved: ${isDarkMode.value}');
    } catch (e) {
      print('❌ Error saving theme preference: $e');
    }
  }

  // Get current theme data
  ThemeData get currentTheme {
    return isDarkMode.value ? AppTheme.darkTheme : AppTheme.lightTheme;
  }

  // Get theme-aware colors
  Color getCardBackground(BuildContext context) {
    return AppTheme.getCardBackground(context);
  }

  Color getCardShadow(BuildContext context) {
    return AppTheme.getCardShadow(context);
  }

  Color getDividerColor(BuildContext context) {
    return AppTheme.getDividerColor(context);
  }

  Color getIconColor(BuildContext context) {
    return AppTheme.getIconColor(context);
  }

  Color getTextSecondaryColor(BuildContext context) {
    return AppTheme.getTextSecondaryColor(context);
  }

  Color getSuccessColor(BuildContext context) {
    return AppTheme.getSuccessColor(context);
  }

  Color getWarningColor(BuildContext context) {
    return AppTheme.getWarningColor(context);
  }

  Color getInfoColor(BuildContext context) {
    return AppTheme.getInfoColor(context);
  }

  // Initialize theme for the app
  static void initializeTheme() {
    final themeController = Get.put(ThemeController());
    Get.changeThemeMode(themeController.themeMode);
  }
}
