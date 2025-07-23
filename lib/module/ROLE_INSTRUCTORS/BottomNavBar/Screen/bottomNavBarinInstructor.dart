import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shaktihub/module/ROLE_INSTRUCTORS/Settings/Screen/SettingInstructor.dart';
import 'package:shaktihub/module/ROLE_INSTRUCTORS/StudentScreen/Screen/StudentManagment.dart';

import '../../Home/screen/homeScreenInstractor.dart';
import '../Controller/BottomNavBarController.dart';

class BottomNavScreen extends StatelessWidget {
  final NavigationController navController = Get.put(NavigationController());

  final List<Widget> pages = const [
    HomeInstructor(),
    StudentManagment(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Scaffold(
        body: pages[navController.selectedIndex.value],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: navController.selectedIndex.value,
          onTap: navController.changeIndex,
          selectedItemColor: Colors.blue,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'Student',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}