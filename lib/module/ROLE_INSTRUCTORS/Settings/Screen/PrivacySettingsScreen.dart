import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/SettingsControllerInstructor.dart';
import 'ChangePasswordScreen.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingControllerInstructor>(
      init: SettingControllerInstructor(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Privacy & Security"),
            actions: [
              TextButton(
                onPressed: () => controller.updatePrivacySettings(),
                child: const Text("Save", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Privacy Section
              _buildSectionCard(
                title: "Profile Privacy",
                icon: Icons.person,
                children: [
                  _buildSwitchTile(
                    title: "Profile Visibility",
                    subtitle: "Make your profile visible to other users",
                    value: controller.profileVisibility.value,
                    onChanged: (value) {
                      controller.profileVisibility.value = value;
                    },
                  ),
                  _buildSwitchTile(
                    title: "Show Email",
                    subtitle: "Display your email address on your profile",
                    value: controller.showEmail.value,
                    onChanged: (value) {
                      controller.showEmail.value = value;
                    },
                  ),
                  _buildSwitchTile(
                    title: "Show Phone",
                    subtitle: "Display your phone number on your profile",
                    value: controller.showPhone.value,
                    onChanged: (value) {
                      controller.showPhone.value = value;
                    },
                  ),
                  _buildSwitchTile(
                    title: "Allow Messages",
                    subtitle: "Allow other users to send you messages",
                    value: controller.allowMessages.value,
                    onChanged: (value) {
                      controller.allowMessages.value = value;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Security Section
              _buildSectionCard(
                title: "Security",
                icon: Icons.security,
                children: [
                  _buildInfoTile(
                    title: "Change Password",
                    subtitle: "Update your account password",
                    icon: Icons.lock,
                    onTap: () {
                      Get.to(() => const ChangePasswordScreen());
                    },
                  ),
                  _buildInfoTile(
                    title: "Two-Factor Authentication",
                    subtitle: "Add an extra layer of security to your account",
                    icon: Icons.verified_user,
                    onTap: () {
                      Get.snackbar("Info", "Two-factor authentication coming soon");
                    },
                  ),
                  _buildInfoTile(
                    title: "Login Activity",
                    subtitle: "View recent login activity and devices",
                    icon: Icons.history,
                    onTap: () {
                      Get.snackbar("Info", "Login activity feature coming soon");
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Data & Privacy Section
              _buildSectionCard(
                title: "Data & Privacy",
                icon: Icons.privacy_tip,
                children: [
                  _buildInfoTile(
                    title: "Download Your Data",
                    subtitle: "Get a copy of your data",
                    icon: Icons.download,
                    onTap: () {
                      Get.snackbar("Info", "Data download feature coming soon");
                    },
                  ),
                  _buildInfoTile(
                    title: "Delete Account",
                    subtitle: "Permanently delete your account and all data",
                    icon: Icons.delete_forever,
                    onTap: () {
                      _showDeleteAccountDialog();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Privacy Policy & Terms
              _buildSectionCard(
                title: "Legal",
                icon: Icons.description,
                children: [
                  _buildInfoTile(
                    title: "Privacy Policy",
                    subtitle: "Read our privacy policy",
                    icon: Icons.privacy_tip,
                    onTap: () {
                      Get.snackbar("Info", "Privacy policy coming soon");
                    },
                  ),
                  _buildInfoTile(
                    title: "Terms of Service",
                    subtitle: "Read our terms of service",
                    icon: Icons.description,
                    onTap: () {
                      Get.snackbar("Info", "Terms of service coming soon");
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

  void _showDeleteAccountDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 8),
            const Text("Delete Account"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Are you sure you want to delete your account?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              "This action cannot be undone. All your data, courses, and progress will be permanently deleted.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Please contact support if you need help with your account.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                "Info",
                "Account deletion feature coming soon. Please contact support.",
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Delete Account"),
          ),
        ],
      ),
    );
  }
}
