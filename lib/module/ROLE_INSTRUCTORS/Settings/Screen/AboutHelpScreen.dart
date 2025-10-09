import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../Controller/SettingsControllerInstructor.dart';

class AboutHelpScreen extends StatefulWidget {
  const AboutHelpScreen({super.key});

  @override
  State<AboutHelpScreen> createState() => _AboutHelpScreenState();
}

class _AboutHelpScreenState extends State<AboutHelpScreen> {
  String appVersion = "1.0.0";
  String buildNumber = "1";
  String packageName = "com.example.elearning";

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        appVersion = packageInfo.version;
        buildNumber = packageInfo.buildNumber;
        packageName = packageInfo.packageName;
      });
    } catch (e) {
      print("Error loading app info: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingControllerInstructor>(
      init: SettingControllerInstructor(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("About & Help"),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // App Info Section
              _buildSectionCard(
                title: "App Information",
                icon: Icons.info,
                children: [
                  _buildInfoRow("Version", appVersion),
                  _buildInfoRow("Build", buildNumber),
                  _buildInfoRow("Package", packageName),
                  _buildInfoRow("Platform", "Flutter"),
                ],
              ),
              const SizedBox(height: 16),

              // Help & Support Section
              _buildSectionCard(
                title: "Help & Support",
                icon: Icons.help,
                children: [
                  _buildInfoTile(
                    title: "FAQ",
                    subtitle: "Frequently asked questions",
                    icon: Icons.quiz,
                    onTap: () {
                      _showFAQDialog();
                    },
                  ),
                  _buildInfoTile(
                    title: "Contact Support",
                    subtitle: "Get help from our support team",
                    icon: Icons.support_agent,
                    onTap: () {
                      _showContactSupportDialog(controller);
                    },
                  ),
                  _buildInfoTile(
                    title: "Report a Bug",
                    subtitle: "Report issues or bugs",
                    icon: Icons.bug_report,
                    onTap: () {
                      _showReportBugDialog(controller);
                    },
                  ),
                  _buildInfoTile(
                    title: "Feature Request",
                    subtitle: "Suggest new features",
                    icon: Icons.lightbulb,
                    onTap: () {
                      _showFeatureRequestDialog(controller);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Legal Section
              _buildSectionCard(
                title: "Legal",
                icon: Icons.description,
                children: [
                  _buildInfoTile(
                    title: "Privacy Policy",
                    subtitle: "How we protect your data",
                    icon: Icons.privacy_tip,
                    onTap: () {
                      Get.snackbar("Info", "Privacy policy coming soon");
                    },
                  ),
                  _buildInfoTile(
                    title: "Terms of Service",
                    subtitle: "Terms and conditions",
                    icon: Icons.description,
                    onTap: () {
                      Get.snackbar("Info", "Terms of service coming soon");
                    },
                  ),
                  _buildInfoTile(
                    title: "Open Source Licenses",
                    subtitle: "Third-party libraries and licenses",
                    icon: Icons.code,
                    onTap: () {
                      _showLicensesDialog();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Social & Community Section
              _buildSectionCard(
                title: "Community",
                icon: Icons.people,
                children: [
                  _buildInfoTile(
                    title: "Rate the App",
                    subtitle: "Rate us on the app store",
                    icon: Icons.star,
                    onTap: () {
                      Get.snackbar("Info", "App store rating coming soon");
                    },
                  ),
                  _buildInfoTile(
                    title: "Share the App",
                    subtitle: "Tell your friends about us",
                    icon: Icons.share,
                    onTap: () {
                      Get.snackbar("Share", "App shared!");
                    },
                  ),
                  _buildInfoTile(
                    title: "Follow Us",
                    subtitle: "Stay updated on social media",
                    icon: Icons.public,
                    onTap: () {
                      Get.snackbar("Info", "Social media links coming soon");
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
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

  void _showFAQDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Frequently Asked Questions"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _buildFAQItem(
                "How do I create a course?",
                "Go to the Courses section and tap the '+' button to create a new course.",
              ),
              _buildFAQItem(
                "How do I upload videos?",
                "When creating a lesson, you can upload videos from your device or record new ones.",
              ),
              _buildFAQItem(
                "How do I manage students?",
                "Go to the Students section to view enrolled students and their progress.",
              ),
              _buildFAQItem(
                "How do I change my profile?",
                "Go to Settings > Profile to update your information.",
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  void _showContactSupportDialog(SettingControllerInstructor controller) {
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController messageController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Contact Support"),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: "Subject",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Message",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (subjectController.text.trim().isEmpty || 
                  messageController.text.trim().isEmpty) {
                Get.snackbar(
                  "Error",
                  "Please fill in all fields",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              controller.contactSupport(
                subject: subjectController.text.trim(),
                message: messageController.text.trim(),
                category: "support",
              );
              Get.back();
            },
            child: const Text("Send"),
          ),
        ],
      ),
    );
  }

  void _showReportBugDialog(SettingControllerInstructor controller) {
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController messageController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Report a Bug"),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: "Bug Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Describe the bug",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (subjectController.text.trim().isEmpty || 
                  messageController.text.trim().isEmpty) {
                Get.snackbar(
                  "Error",
                  "Please fill in all fields",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              controller.contactSupport(
                subject: subjectController.text.trim(),
                message: messageController.text.trim(),
                category: "bug_report",
              );
              Get.back();
            },
            child: const Text("Report"),
          ),
        ],
      ),
    );
  }

  void _showFeatureRequestDialog(SettingControllerInstructor controller) {
    final TextEditingController subjectController = TextEditingController();
    final TextEditingController messageController = TextEditingController();

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Feature Request"),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(
                  labelText: "Feature Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Describe the feature",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (subjectController.text.trim().isEmpty || 
                  messageController.text.trim().isEmpty) {
                Get.snackbar(
                  "Error",
                  "Please fill in all fields",
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              controller.contactSupport(
                subject: subjectController.text.trim(),
                message: messageController.text.trim(),
                category: "feature_request",
              );
              Get.back();
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  void _showLicensesDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Open Source Licenses"),
        content: const SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Text(
              "This app uses the following open source libraries:\n\n"
              "• Flutter - BSD 3-Clause License\n"
              "• GetX - MIT License\n"
              "• Dio - MIT License\n"
              "• Shared Preferences - BSD 3-Clause License\n"
              "• Package Info Plus - BSD 3-Clause License\n"
              "• Connectivity Plus - BSD 3-Clause License\n\n"
              "For full license details, please visit the respective project repositories.",
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
