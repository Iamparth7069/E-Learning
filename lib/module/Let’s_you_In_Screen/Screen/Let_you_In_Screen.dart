import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shaktihub/Constraint/extension.dart';
import 'package:shaktihub/routes/app_pages.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../Constraint/app_color.dart';
import '../Controller/let_you_in_controller.dart';

class LetsYouInScreen extends StatelessWidget {
  LetsYouInScreen({super.key});
  final Lets_You_in_controller controllers = Get.put(Lets_You_in_controller());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBackColor,
      body: Stack(
        children: [
          Positioned(
            top: -70,
            left: -20,
            child: Image.asset("assets/images/img_1.png",scale:2,),
          ),

          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 8.h,
                ),
                Center(
                  child: SizedBox(
                    height: 250,
                    width: 250,
                    child: assetImage("assets/images/img.png", fit: BoxFit.fitWidth),
                  ),
                ),
                SizedBox(
                  height: 1.h,
                ),
                Center(
                    child: ReadexPro("Welcome to ShaktiHub")
                        .boldReadex(fontSize: 23, fontColor: Colors.black)),
                Center(
                    child: ReadexPro("Let's you in")
                        .boldReadex(fontSize: 23, fontColor: Colors.black)),
                SizedBox(
                  height: 4.h,
                ),

                createLoginButton(onPressed: () {

                }, text: "Continue with Google", imagePath: "assets/images/search.png", borderColor: Colors.white),

                SizedBox(
                  height: 2.h,
                ),

                createLoginButton(onPressed: () {

                }, text: "Continue with Facebook", imagePath: "assets/images/facebook.png", borderColor: Colors.white),


                SizedBox(
                  height: 2.h,
                ),
                SizedBox(height: 3.h),
                // Divider below Apple button
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 2,
                          color: Colors.grey,
                        ),
                        flex: 2,
                      ),
                      Expanded(flex: 1, child: Center(child: Text("Or"))),
                      Expanded(
                        flex: 2,
                        child: Divider(
                          thickness: 2,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
                // Or Row with Text widgets
                Obx(
                      () => controllers.isLoading.value
                      ? LoadingAnimationWidget.hexagonDots(
                      color: AppColor.appBackColor, size: 5.h)
                      : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: MaterialButton(
                      color: AppColor.ButtonColor,
                      onPressed: () {
                         Get.toNamed(Routes.LoginScreen);
                      },
                      height: 26,
                      padding: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      minWidth: double.infinity,
                      child: Center(
                          child: Text(
                            "Sign in with Email password",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          )),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    "Don't have an account?".mediumReadex(fontColor: Color(0xff6A8FA3)),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                        onTap: () {
                          Get.toNamed(Routes.REGISTERSCREEN);
                        },
                        child: "Sign up".mediumReadex(fontColor: AppColor.ButtonColor)),

                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
