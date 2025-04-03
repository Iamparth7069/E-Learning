import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../Category/screen/CategoryScreen.dart';
import '../../Profile/screen/profileScreen.dart';
import '../../home/screen/homeScreen.dart';
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

        NavigationModel(name: "Home", icon: "assets/Icon/home.png", iconFilled: "assets/Icon/homeFilled.png", screen: const HomeScreen()),
        NavigationModel(name: "Category", icon: "assets/Icon/category.png", iconFilled: "assets/Icon/categoryFilled.png", screen: const CategoryScreen()),
        NavigationModel(name: "Search", icon: "assets/Icon/search.png", iconFilled: "assets/Icon/searchFill.png", screen: const ProfileScreen()),
        NavigationModel(name: "Profile", icon: "assets/Icon/profile.png", iconFilled: "assets/Icon/profileFilled.png", screen: const ProfileScreen()),
        
      ];
  }

  void setPage(int index) {
    pageIndex = index;
    update();
  }


}