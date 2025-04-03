import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shaktihub/module/ROLE_ADMIN/Home/screen/home_Admin.dart';
import 'package:shaktihub/module/ROLE_USER/Category/screen/CategoryScreen.dart';

import '../../../ROLE_USER/dashboard/model/NavigationModel.dart';
import '../../Search/Screen/Search.dart';




class AdminNavController extends GetxController{

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
      NavigationModel(name: "Home", icon: "assets/Icon/home.png", iconFilled: "assets/Icon/homeFilled.png", screen:  HomeAdmin()),
      NavigationModel(name: "Category", icon: "assets/Icon/category.png", iconFilled: "assets/Icon/categoryFilled.png", screen: const CategoryScreen()),
      NavigationModel(name: "Search", icon: "assets/Icon/search.png", iconFilled: "assets/Icon/searchFill.png", screen: const SearchScreen()),
    ];
  }

  void setPage(int index) {
    pageIndex = index;
    update();
  }


}