import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Constraint/appTextStyle.dart';
import '../../../../Constraint/app_color.dart';

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

  List<Widget> _getBottomWidget(DeskBoardScreenController controller) {
    List<Widget> list = [];
    for(int index=0;index <controller.screens.length;index++){
      list.add(Expanded(child: CustomMenuItem(
        isSelected: controller.pageIndex == index,
        name: controller.screens[index].name,
        icon: controller.screens[index].icon,
        iconFilled: controller.screens[index].iconFilled,
        onTap: () => controller.setPage(index),
      )));
    }
    return list;
  }
}


class CustomMenuItem extends StatelessWidget {
  final bool isSelected;
  final String name;
  final String icon;
  final String iconFilled;
  final VoidCallback onTap;

  const CustomMenuItem({
    super.key, required this.isSelected, required this.name, required this.icon, required this.iconFilled, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onTap,
      child: Padding(padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Center(
                child: Image.asset(
                  isSelected ? iconFilled : icon,
                ),
              ),
            ),
            const SizedBox(height: 5,),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppStyle.textStyleOutfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColor.mainTextColor : AppColor.midTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

