import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          // Header Section
          UserAccountsDrawerHeader(
            accountName: Text("Admin User", style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text("admin@example.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 40, color: Colors.blue),
            ),
            decoration: BoxDecoration(color: Colors.blue),
          ),

          // Home
          ListTile(
            leading: Icon(Icons.home, color: Colors.blue),
            title: Text("Home"),
            onTap: () => Get.back(),
          ),

          // Profile
          ListTile(
            leading: Icon(Icons.person, color: Colors.blue),
            title: Text("Profile"),
            onTap: () => Get.back(),
          ),

          // Expandable List for Categories
          ExpansionTile(
            leading: Icon(Icons.category, color: Colors.blue),
            title: Text("Manage Category"),
            children: [
              ListTile(
                leading: Icon(Icons.subdirectory_arrow_right, color: Colors.blue),
                title: Text("Add Category"),
                onTap: () {

                },
              ),
              ListTile(
                leading: Icon(Icons.subdirectory_arrow_right, color: Colors.blue),
                title: Text("Sub Category 2"),
                onTap: () {
                  Get.snackbar("Sub Category", "Clicked on Sub Category 2");
                },
              ),
            ],
          ),

          // Settings
          ListTile(
            leading: Icon(Icons.settings, color: Colors.blue),
            title: Text("Settings"),
            onTap: () => Get.back(),
          ),

          Divider(),

          // Logout
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red),
            title: Text("Logout"),
            onTap: () => Get.back(),
          ),
        ],
      ),
    );
  }
}
