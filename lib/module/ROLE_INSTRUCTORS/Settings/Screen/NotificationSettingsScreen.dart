import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/SettingsControllerInstructor.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingControllerInstructor>(
      init: SettingControllerInstructor(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Notification Settings"),
            actions: [
              TextButton(
                onPressed: () => controller.updateNotificationSettings(),
                child: const Text("Save", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Email Notifications Section
              _buildSectionCard(
                title: "Email Notifications",
                icon: Icons.email,
                children: [
                  _buildSwitchTile(
                    title: "Email Notifications",
                    subtitle: "Receive notifications via email",
                    value: controller.emailNotifications.value,
                    onChanged: (value) {
                      controller.emailNotifications.value = value;
                    },
                  ),
                  _buildSwitchTile(
                    title: "Course Updates",
                    subtitle: "Get notified about course changes and new content",
                    value: controller.courseUpdates.value,
                    onChanged: (value) {
                      controller.courseUpdates.value = value;
                    },
                  ),
                  _buildSwitchTile(
                    title: "Marketing Emails",
                    subtitle: "Receive promotional content and app updates",
                    value: controller.marketingEmails.value,
                    onChanged: (value) {
                      controller.marketingEmails.value = value;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Push Notifications Section
              _buildSectionCard(
                title: "Push Notifications",
                icon: Icons.notifications,
                children: [
                  _buildSwitchTile(
                    title: "Push Notifications",
                    subtitle: "Receive push notifications on your device",
                    value: controller.pushNotifications.value,
                    onChanged: (value) {
                      controller.pushNotifications.value = value;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Notification Preferences
              _buildSectionCard(
                title: "Notification Preferences",
                icon: Icons.settings,
                children: [
                  _buildInfoTile(
                    title: "Quiet Hours",
                    subtitle: "Set specific times when you don't want to receive notifications",
                    icon: Icons.schedule,
                    onTap: () {
                      Get.snackbar("Info", "Quiet hours feature coming soon");
                    },
                  ),
                  _buildInfoTile(
                    title: "Notification Sound",
                    subtitle: "Customize notification sounds",
                    icon: Icons.volume_up,
                    onTap: () {
                      Get.snackbar("Info", "Sound settings coming soon");
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Test Notifications
              _buildSectionCard(
                title: "Test Notifications",
                icon: Icons.bug_report,
                children: [
                  _buildInfoTile(
                    title: "Send Test Notification",
                    subtitle: "Test if notifications are working properly",
                    icon: Icons.send,
                    onTap: () {
                      Get.snackbar(
                        "Test Notification",
                        "This is a test notification to verify your settings are working!",
                        backgroundColor: Colors.blue,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 3),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Obx(() => SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    ));
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
