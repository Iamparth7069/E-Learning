import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shaktihub/module/home/controller/homeScreenController.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      init: HomeScreenController(),
      builder: (controller) {
        return Scaffold(
          appBar:  AppBar(title: Text("Home"),),

        );
      },
    );
  }
}
