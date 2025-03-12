import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shaktihub/routes/app_pages.dart';



class Onboddingscreencontroller extends GetxController{
  final PageController pageController = PageController(initialPage: 0);
  int currentPageIndex = 0;

  void changePageIndex(int value) {
    currentPageIndex = value;
    update();
  }


  navigateToPage() async {
    if (currentPageIndex < 2) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      update();
    } else {
      // await LocalStorage.setOndogging(bio: true);
       Get.offAllNamed(Routes.LETYOUINSCREEN);
    }
  }


}