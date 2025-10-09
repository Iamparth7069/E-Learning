import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Controller/SettingsControllerInstructor.dart';
import 'ProfileEditScreen.dart';
import 'ChangePasswordScreen.dart';
import 'NotificationSettingsScreen.dart';
import 'PrivacySettingsScreen.dart';
import 'AppSettingsScreen.dart';
import 'AboutHelpScreen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingControllerInstructor>(
      init: SettingControllerInstructor(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(title: const Text("Settings")),
          body: ListView(
            children: [
              // 👤 Name Title
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue[50],
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue,
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      controller.UserName, // ✅ Show name from controller
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Profile Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Profile", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(),

              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text("Edit Profile"),
                subtitle: const Text("Update your personal information"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Get.to(() =>  ProfileEditScreen());
                },
              ),

              const SizedBox(height: 20),

              // Account Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Account", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(),

              ListTile(
                leading: const Icon(Icons.notifications, color: Colors.orange),
                title: const Text("Notifications"),
                subtitle: const Text("Manage notification preferences"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Get.to(() => const NotificationSettingsScreen());
                },
              ),

              ListTile(
                leading: const Icon(Icons.security, color: Colors.green),
                title: const Text("Privacy & Security"),
                subtitle: const Text("Manage privacy and security settings"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Get.to(() => const PrivacySettingsScreen());
                },
              ),

              const SizedBox(height: 20),

              // App Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("App", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(),

              ListTile(
                leading: const Icon(Icons.settings, color: Colors.purple),
                title: const Text("App Settings"),
                subtitle: const Text("Customize app preferences"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Get.to(() => const AppSettingsScreen());
                },
              ),

              ListTile(
                leading: const Icon(Icons.help, color: Colors.teal),
                title: const Text("About & Help"),
                subtitle: const Text("Get help and app information"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Get.to(() => const AboutHelpScreen());
                },
              ),

              const SizedBox(height: 20),

              // Social Section
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Social", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(),

              ListTile(
                leading: const Icon(Icons.share, color: Colors.indigo),
                title: const Text("Share App"),
                subtitle: const Text("Tell your friends about this app"),
                onTap: () {
                  Get.snackbar("Share", "App shared!");
                },
              ),

              ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: const Text("Rate App"),
                subtitle: const Text("Rate us on the app store"),
                onTap: () {
                  Get.snackbar("Rate", "Thank you for rating!");
                },
              ),

              const SizedBox(height: 20),
              const Divider(),

              Obx(() => ListTile(
                leading: controller.isLoggingOut.value
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                      )
                    : const Icon(Icons.logout, color: Colors.red),
                title: Text(
                  controller.isLoggingOut.value ? "Logging out..." : "Logout",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: controller.isLoggingOut.value ? null : () {
                  controller.showLogoutConfirmation();
                },
              )),
            ],
          ),
        );
      },
    );
  }
}
