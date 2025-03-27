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
    Future.delayed(const Duration(seconds: 2),(){

      String key = SharedPrefHelper.OnboddingVisiting;
      String loginKey = SharedPrefHelper.loginStatus;

      bool val = sharedPrefHelper.getBool(key);
      bool log = sharedPrefHelper.getBool(loginKey);

      if(log){
        Get.offAllNamed(Routes.HomeScreen);
      }else {
        if (val) {
          Get.offAllNamed(Routes.LETYOUINSCREEN);
        } else {
          Get.offAllNamed(Routes.ONBODDING);
        }
      }

      // Get.offAllNamed(Routes.DASHBOARD);
    });
  }

}
