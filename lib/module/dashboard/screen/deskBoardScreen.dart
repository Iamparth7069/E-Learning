import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../Constraint/app_color.dart';
import '../controller/deshBoardController.dart';

class DeskBoardScreen extends StatelessWidget {
  const DeskBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.whiteColor,
      body: GetBuilder<DeskBoardScreenController>(
        init: DeskBoardScreenController(),
        builder: (controller) {
          return PageStorage(bucket: controller.bucket, child: controller.screens[controller.pageIndex].screen,);
      },),
      bottomNavigationBar: GetBuilder<DeskBoardScreenController>(
        init: DeskBoardScreenController(),
        builder: (controller) {
          return Container(

            height: 70,
            decoration: BoxDecoration(
              color: AppColor.whiteColor,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                  spreadRadius: 1,
                  color: Theme.of(context).primaryColor.withOpacity(.125),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _getBottomWidget(controller),
            ),
          );

      },),
    );
  }

  _getBottomWidget(DeskBoardScreenController controller) {}
}
