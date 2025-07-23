import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';

class SettingControllerInstructor extends GetxController{


  String UserName = "";
  SharedPrefHelper sharedPrefHelper = new SharedPrefHelper();

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    UserName = sharedPrefHelper.getString(SharedPrefHelper.userName).toString();
  }



  void logout() {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Are you sure you want to logout?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back(); // Close dialog
        Get.snackbar("Logout", "Successfully logged out");
      },
      onCancel: () {

      },
    );
  }





}