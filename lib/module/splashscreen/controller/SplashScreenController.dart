import 'dart:async';

import 'package:get/get.dart';

import '../../../routes/app_pages.dart';



class SplashScreenController extends GetxController {
  String displayText = '';
  int index = 0;
  final String _fullText = 'Help Harbor';

  @override
  void onInit() {
    super.onInit();
    _navigate();
  }

  void _navigate() async {
    Future.delayed(const Duration(seconds: 2),(){
      Get.offAllNamed(Routes.ONBODDING);
      // Get.offAllNamed(Routes.DASHBOARD);
    });
  }

}
