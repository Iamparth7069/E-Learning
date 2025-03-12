import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../../../Constraint/appString.dart';
import '../../../../Constraint/app_color.dart';
import '../../../../Constraint/extension.dart';
import '../Controller/OnBoddingScreenController.dart';

class OnBordingScreen extends StatefulWidget {
  const OnBordingScreen({super.key});

  @override
  State<OnBordingScreen> createState() => _OnBordingScreenState();
}

class _OnBordingScreenState extends State<OnBordingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBackColor,
      body: GetBuilder<Onboddingscreencontroller>(
        init: Onboddingscreencontroller(),
        builder: (controller) {
          return Stack(
            children: [
              Positioned(
                top: -70,
                left: -20,
                child: Image.asset("assets/images/img_1.png",scale:2,),
              ),
              Column(
                children: [
                  SizedBox(
                    height: 80.h,
                    child: PageView(
                      controller: controller.pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (value) {
                        controller.changePageIndex(value);
                      },
                      children: [
                        _page1(),
                        _page2(),
                        _page3(),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                          (index) {
                        return Container(
                          width: controller.currentPageIndex == index ? 10.w : 2.w,
                          height: 1.h,
                          decoration: BoxDecoration(
                            color: controller.currentPageIndex == index
                                ? AppColor.ButtonColor
                                : AppColor.ButtonColor,
                            borderRadius: BorderRadius.circular(controller.currentPageIndex == index ? 10 : 15),
                          ),
                        ).paddingSymmetric(horizontal: 1.w);
                      },
                    ),
                  ),
                  8.h.addHSpace(),
                  appButton(
                    fontSize: 20,
                    color: AppColor.ButtonColor,
                    text: controller.currentPageIndex == 2 ? "Get Started" : "Next",
                    onTap: () {
                      controller.navigateToPage();
                    },
                  ),
                ],
              ),
            ],
          );
        },),
    );
  }

  Widget _page1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 50.h,
            width: 65.w,
            child: assetImage("assets/images/onBodding1.png", fit: BoxFit.fitWidth),
          ),
          AppString.onBording1title.boldReadex(
              fontColor: AppColor.blackColor, fontSize: 17.sp, textAlign: TextAlign.start),
          AppString.description.boldRoboto(
              fontColor: AppColor.blackColor, fontSize: 15.sp, textAlign: TextAlign.start)
        ],
      ),
    );
  }

  Widget _page2() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 50.h,
            width: 65.w,
            child: assetImage("assets/images/onBodding1.png", fit: BoxFit.fitWidth),
          ),
          AppString.onBording2.boldReadex(
              fontColor: AppColor.blackColor, fontSize: 17.sp, textAlign: TextAlign.start),
          AppString.onBording2description.boldRoboto(
              fontColor: AppColor.blackColor, fontSize: 15.sp, textAlign: TextAlign.start)
        ],
      ),
    );
  }

  Widget _page3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 50.h,
            width: 65.w,
            child: assetImage("assets/images/onBodding1.png", fit: BoxFit.fitWidth),
          ),
          AppString.onBording3.boldReadex(
              fontColor: AppColor.blackColor, fontSize: 17.sp, textAlign: TextAlign.start),
          AppString.onBording3description.boldRoboto(
              fontColor: AppColor.blackColor, fontSize: 15.sp, textAlign: TextAlign.start)
        ],
      ),
    );
  }

}
