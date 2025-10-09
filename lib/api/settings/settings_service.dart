import '../listing/api_listing.dart';
import '../url/api_url.dart';

class SettingsService {
  // Get user profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await NetworkService.makeGetRequest(
        url: ApiUrl.getProfile,
      );
      return response;
    } catch (e) {
      return {'error': true, 'message': 'Failed to fetch profile: $e'};
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateUserProfile({
    required String name,
    String? email,
    String? phone,
    String? bio,
    String? profileImage,
  }) async {
    try {
      final body = {
        'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (bio != null) 'bio': bio,
        if (profileImage != null) 'profile_image': profileImage,
      };

      final response = await NetworkService.makePutRequest(
        url: ApiUrl.updateProfile,
        body: body,
      );
      return response;
    } catch (e) {
      return {'error': true, 'message': 'Failed to update profile: $e'};
    }
  }

  // Change password
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final body = {
        'current_password': currentPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      };

      final response = await NetworkService.makePostRequest(
        url: ApiUrl.changePassword,
        body: body,
      );
      return response;
    } catch (e) {
      return {'error': true, 'message': 'Failed to change password: $e'};
    }
  }

  // Get notification settings
  static Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final response = await NetworkService.makeGetRequest(
        url: ApiUrl.notificationSettings,
      );
      return response;
    } catch (e) {
      return {'error': true, 'message': 'Failed to fetch notification settings: $e'};
    }
  }

  // Update notification settings
  static Future<Map<String, dynamic>> updateNotificationSettings({
    required bool emailNotifications,
    required bool pushNotifications,
    required bool courseUpdates,
    required bool marketingEmails,
  }) async {
    try {
      final body = {
        'email_notifications': emailNotifications,
        'push_notifications': pushNotifications,
        'course_updates': courseUpdates,
        'marketing_emails': marketingEmails,
      };

      final response = await NetworkService.makePutRequest(
        url: ApiUrl.notificationSettings,
        body: body,
      );
      return response;
    } catch (e) {
      return {'error': true, 'message': 'Failed to update notification settings: $e'};
    }
  }

  // Get privacy settings
  static Future<Map<String, dynamic>> getPrivacySettings() async {
    try {
      final response = await NetworkService.makeGetRequest(
        url: ApiUrl.privacySettings,
      );
      return response;
    } catch (e) {
      return {'error': true, 'message': 'Failed to fetch privacy settings: $e'};
    }
  }

  // Update privacy settings
  static Future<Map<String, dynamic>> updatePrivacySettings({
    required bool profileVisibility,
    required bool showEmail,
    required bool showPhone,
    required bool allowMessages,
  }) async {
    try {
      final body = {
        'profile_visibility': profileVisibility,
        'show_email': showEmail,
        'show_phone': showPhone,
        'allow_messages': allowMessages,
      };

      final response = await NetworkService.makePutRequest(
        url: ApiUrl.privacySettings,
        body: body,
      );
      return response;
    } catch (e) {
      return {'error': true, 'message': 'Failed to update privacy settings: $e'};
    }
  }

  // Get app settings
  static Future<Map<String, dynamic>> getAppSettings() async {
    try {
      final response = await NetworkService.makeGetRequest(
        url: ApiUrl.appSettings,
      );
      return response;
    } catch (e) {
      return {'error': true, 'message': 'Failed to fetch app settings: $e'};
    }
  }

  // Update app settings
  static Future<Map<String, dynamic>> updateAppSettings({
    required String theme,
    required String language,
    required bool autoPlay,
    required bool downloadOverWifi,
  }) async {
    try {
      final body = {
        'theme': theme,
        'language': language,
        'auto_play': autoPlay,
        'download_over_wifi': downloadOverWifi,
      };

      final response = await NetworkService.makePutRequest(
        url: ApiUrl.appSettings,
        body: body,
      );
      return response;
    } catch (e) {
      return {'error': true, 'message': 'Failed to update app settings: $e'};
    }
  }

  // Clear cache
  static Future<Map<String, dynamic>> clearCache() async {
    try {
      final response = await NetworkService.makePostRequest(
        url: ApiUrl.clearCache,
      );
      return response;
    } catch (e) {
      return {'error': true, 'message': 'Failed to clear cache: $e'};
    }
  }

  // Contact support
  static Future<Map<String, dynamic>> contactSupport({
    required String subject,
    required String message,
    String? category,
  }) async {
    try {
      final body = {
        'subject': subject,
        'message': message,
        if (category != null) 'category': category,
      };

      final response = await NetworkService.makePostRequest(
        url: ApiUrl.contactSupport,
        body: body,
      );
      return response;
    } catch (e) {
      return {'error': true, 'message': 'Failed to send support message: $e'};
    }
  }
}
