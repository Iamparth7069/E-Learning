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
                        ).paddingSymmetric(horizontal: 0.5.w);
                      },
                    ),
                  ),
                  6.h.addHSpace(),
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
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 50.h,
            width: 65.w,
            child: assetImage("assets/images/onbodding1.png", fit: BoxFit.fitWidth),
          ),
          Text('Learn Anytime',
              style: TextStyle(
                color: AppColor.blackColor,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center),
          Text('Study at your own pace with flexible schedules and learn from anywhere.',
              style: TextStyle(
                color: AppColor.blackColor,
                fontSize: 16.8.sp,
              ),
              textAlign: TextAlign.center),
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
            child: assetImage("assets/images/onbodding2.png", fit: BoxFit.fitWidth),
          ),
          Text('Find Your Course',
              style: TextStyle(
                color: AppColor.blackColor,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center),
          Text('Choose from a range of subjects and find a course that suits you.',
              style: TextStyle(
                color: AppColor.blackColor,
                fontSize: 16.8.sp,
              ),
              textAlign: TextAlign.center),
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
            child: assetImage("assets/images/onbodding3.png", fit: BoxFit.fitWidth),
          ),
          Text('Achieve Your Goals',
              style: TextStyle(
                color: AppColor.blackColor,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center),
          Text('Boost your skills, earn certifications, and advance your career.',
              style: TextStyle(
                color: AppColor.blackColor,
                fontSize: 16.8.sp,
              ),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }


}
