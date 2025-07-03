import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shaktihub/module/ROLE_ADMIN/CaregoryManage/screen/updateCategory.dart';
import 'package:shaktihub/module/ROLE_ADMIN/CaregoryManage/screen/updateSubCategory.dart';

import '../../../../routes/app_pages.dart';

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
                  Get.toNamed(Routes.AdminCategoryAdd);
                },
              ),
              ListTile(
                leading: Icon(Icons.subdirectory_arrow_right, color: Colors.blue),
                title: Text("Sub SubCategory"),
                onTap: () {
                  Get.toNamed(Routes.SubCategory);                },
              ),
              ListTile(
                leading: Icon(Icons.subdirectory_arrow_right, color: Colors.blue),
                title: Text("Update Category"),
                onTap: () {
                  Get.to(UpdateCategory());                },
              ),

              ListTile(
                leading: Icon(Icons.subdirectory_arrow_right, color: Colors.blue),
                title: Text("Update SubCategory"),
                onTap: () {
                  Get.to(UpdateSubCategory());

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
