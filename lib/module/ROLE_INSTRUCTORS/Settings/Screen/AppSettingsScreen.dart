import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/SettingsControllerInstructor.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingControllerInstructor>(
      init: SettingControllerInstructor(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("App Settings"),
            actions: [
              TextButton(
                onPressed: () => controller.updateAppSettings(),
                child: const Text("Save", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Appearance Section
              _buildSectionCard(
                title: "Appearance",
                icon: Icons.palette,
                children: [
                  _buildDropdownTile(
                    title: "Theme",
                    subtitle: "Choose your preferred theme",
                    icon: Icons.brightness_6,
                    value: controller.selectedTheme.value,
                    items: const [
                      {'value': 'light', 'label': 'Light'},
                      {'value': 'dark', 'label': 'Dark'},
                      {'value': 'system', 'label': 'System Default'},
                    ],
                    onChanged: (value) {
                      controller.selectedTheme.value = value;
                    },
                  ),
                  _buildDropdownTile(
                    title: "Language",
                    subtitle: "Select your preferred language",
                    icon: Icons.language,
                    value: controller.selectedLanguage.value,
                    items: const [
                      {'value': 'en', 'label': 'English'},
                      {'value': 'es', 'label': 'Spanish'},
                      {'value': 'fr', 'label': 'French'},
                      {'value': 'de', 'label': 'German'},
                    ],
                    onChanged: (value) {
                      controller.selectedLanguage.value = value;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Media & Downloads Section
              _buildSectionCard(
                title: "Media & Downloads",
                icon: Icons.video_library,
                children: [
                  _buildSwitchTile(
                    title: "Auto Play Videos",
                    subtitle: "Automatically play videos when opened",
                    value: controller.autoPlay.value,
                    onChanged: (value) {
                      controller.autoPlay.value = value;
                    },
                  ),
                  _buildSwitchTile(
                    title: "Download Over WiFi Only",
                    subtitle: "Only download content when connected to WiFi",
                    value: controller.downloadOverWifi.value,
                    onChanged: (value) {
                      controller.downloadOverWifi.value = value;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Storage & Cache Section
              _buildSectionCard(
                title: "Storage & Cache",
                icon: Icons.storage,
                children: [
                  _buildInfoTile(
                    title: "Clear Cache",
                    subtitle: "Free up space by clearing app cache",
                    icon: Icons.cleaning_services,
                    onTap: () {
                      _showClearCacheDialog(controller);
                    },
                  ),
                  _buildInfoTile(
                    title: "Storage Usage",
                    subtitle: "View how much space the app is using",
                    icon: Icons.pie_chart,
                    onTap: () {
                      Get.snackbar("Info", "Storage usage feature coming soon");
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Accessibility Section
              _buildSectionCard(
                title: "Accessibility",
                icon: Icons.accessibility,
                children: [
                  _buildInfoTile(
                    title: "Font Size",
                    subtitle: "Adjust text size for better readability",
                    icon: Icons.text_fields,
                    onTap: () {
                      Get.snackbar("Info", "Font size settings coming soon");
                    },
                  ),
                  _buildInfoTile(
                    title: "High Contrast",
                    subtitle: "Enable high contrast mode",
                    icon: Icons.contrast,
                    onTap: () {
                      Get.snackbar("Info", "High contrast mode coming soon");
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Advanced Section
              _buildSectionCard(
                title: "Advanced",
                icon: Icons.settings,
                children: [
                  _buildInfoTile(
                    title: "Reset Settings",
                    subtitle: "Reset all settings to default values",
                    icon: Icons.restore,
                    onTap: () {
                      _showResetSettingsDialog(controller);
                    },
                  ),
                  _buildInfoTile(
                    title: "Debug Mode",
                    subtitle: "Enable debug mode for troubleshooting",
                    icon: Icons.bug_report,
                    onTap: () {
                      Get.snackbar("Info", "Debug mode feature coming soon");
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

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
    required List<Map<String, String>> items,
    required ValueChanged<String> onChanged,
  }) {
    return Obx(() => ListTile(
      leading: Icon(icon, color: Colors.grey[600]),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item['value'],
            child: Text(item['label']!),
          );
        }).toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
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

  void _showClearCacheDialog(SettingControllerInstructor controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.cleaning_services, color: Colors.blue),
            const SizedBox(width: 8),
            const Text("Clear Cache"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "This will clear all cached data including:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildCacheItem("Downloaded videos"),
            _buildCacheItem("Images and thumbnails"),
            _buildCacheItem("Temporary files"),
            _buildCacheItem("App data cache"),
            const SizedBox(height: 12),
            const Text(
              "This action cannot be undone. You may need to re-download some content.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
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
              controller.clearAppCache();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text("Clear Cache"),
          ),
        ],
      ),
    );
  }

  void _showResetSettingsDialog(SettingControllerInstructor controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.restore, color: Colors.orange),
            const SizedBox(width: 8),
            const Text("Reset Settings"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "This will reset all app settings to their default values:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildCacheItem("Theme settings"),
            _buildCacheItem("Notification preferences"),
            _buildCacheItem("Privacy settings"),
            _buildCacheItem("App preferences"),
            const SizedBox(height: 12),
            const Text(
              "Your account data and courses will not be affected.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
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
                "Reset settings feature coming soon",
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text("Reset Settings"),
          ),
        ],
      ),
    );
  }

  Widget _buildCacheItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
