import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Controller/SettingsControllerInstructor.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  void _logout() {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Are you sure you want to logout?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      onConfirm: () {
        // Perform logout logic here
        Get.back(); // Close dialog
        Get.snackbar("Logout", "Successfully logged out");
      },
    );
  }

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

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("Category", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(),

              ListTile(
                leading: const Icon(Icons.category),
                title: const Text("My Courses"),
                onTap: () {
                  Get.snackbar("Tapped", "Courses tapped");
                },
              ),

              ListTile(
                leading: const Icon(Icons.bookmark),
                title: const Text("Saved Items"),
                onTap: () {
                  Get.snackbar("Tapped", "Saved items tapped");
                },
              ),

              const SizedBox(height: 20),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text("More", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(),

              ListTile(
                leading: const Icon(Icons.share),
                title: const Text("Invite Friends"),
                onTap: () {
                  Get.snackbar("Invite", "Invite link copied");
                },
              ),

              ListTile(
                leading: const Icon(Icons.mobile_friendly),
                title: const Text("Share App"),
                onTap: () {
                  Get.snackbar("Share", "App shared!");
                },
              ),

              const SizedBox(height: 20),
              const Divider(),

              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout", style: TextStyle(color: Colors.red)),
                onTap: _logout,
              ),
            ],
          ),
        );
      },
    );
  }
}
