import 'dart:async';

import 'package:get/get.dart';

import '../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../routes/app_pages.dart';



class SplashScreenController extends GetxController {
  String displayText = '';
  int index = 0;
  final String _fullText = 'Help Harbor';

  SharedPrefHelper sharedPrefHelper = SharedPrefHelper();

  @override
  void onInit() {
    super.onInit();
     _navigate();
  }

  void _navigate() async {
    await Future.delayed(const Duration(seconds: 2));

    String onboardingKey = SharedPrefHelper.OnboddingVisiting;
    String loginKey = SharedPrefHelper.loginStatus;
    String adminKey = SharedPrefHelper.IsAdmin;
    String instructorKey = SharedPrefHelper.instructorLoginStatus;

    bool isOnboarded = sharedPrefHelper.getBool(onboardingKey);
    bool isLoggedIn = sharedPrefHelper.getBool(loginKey);
    bool isAdmin = sharedPrefHelper.getBool(adminKey);
    bool isInstructor = sharedPrefHelper.getBool(instructorKey);

    if (isLoggedIn) {
      if (isAdmin) {
        Get.offAllNamed(Routes.AdminDeskBoard, arguments: 0);
      } else if (isInstructor) {
        Get.offAllNamed(Routes.InstructorScreen, arguments: 0);
      } else {
        Get.offAllNamed(Routes.DeskBord, arguments: 0);
      }
    } else {
      if (isOnboarded) {
        Get.offAllNamed(Routes.LETYOUINSCREEN);
      } else {
        Get.offAllNamed(Routes.ONBODDING);
      }
    }
  }


}
