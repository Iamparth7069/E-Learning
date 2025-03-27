import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../model/NavigationModel.dart';

class DeskBoardScreenController extends GetxController{

  late List<NavigationModel> screens;
  int pageIndex = 0;

  final PageStorageBucket bucket = PageStorageBucket();


  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    pageIndex = Get.arguments as int;

    init();


  }

  void init() async{
      screens = [

      ];
  }
}