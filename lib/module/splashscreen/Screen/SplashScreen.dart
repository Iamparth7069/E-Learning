import 'package:flutter/material.dart';
import '../../../../Constraint/app_color.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sizer/sizer.dart';
import 'package:get/get.dart';

import '../controller/SplashScreenController.dart';
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashScreenController>(
      init: SplashScreenController(),
      builder: (controller) {
      return Scaffold(
        backgroundColor: AppColor.appBackColor,
        body: Stack(
          children: [
            // Background Circles
            Positioned(
              top: -70,
              left: -20,
              child: Image.asset("assets/images/img_1.png",scale:2,),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    height: 250,
                    'assets/images/logoBBG.png', // Replace with your actual logo path
                    // Adjust size as needed
                  ),
                  const SizedBox(height: 30), // Space between logo and loader
                  LoadingAnimationWidget.hexagonDots(color: AppColor.loadingColor, size: 5.h),

                ],
              ),
            ),
          ],
        ),
      );
    },);
  }
}

// Widget for circles to avoid repetitive code

