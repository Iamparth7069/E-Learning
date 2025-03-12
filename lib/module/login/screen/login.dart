import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shaktihub/Constraint/extension.dart';
import 'package:sizer/sizer.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../Constraint/appTextStyle.dart';
import '../../../Constraint/app_color.dart';
import '../../../routes/app_pages.dart';
import '../controller/login_controller.dart';


class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {


  final _globel = GlobalKey<FormState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(
      init: LoginController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: AppColor.appBackColor,
          body: Form(
            key: controller.key,
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Positioned(
                    top: -70,
                    left: -20,
                    child: Image.asset("assets/images/img_1.png",scale:2,),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 1.w,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(17),
                            child: Container(
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: InkWell(
                                onTap: () {
                                  Get.back();
                                },
                                child: Icon(
                                  Icons.arrow_back_outlined,
                                  size: 3.h,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 19),
                            child: Center(
                                child: ReadexPro("Login to your Account")
                                    .boldReadex(fontSize: 40, fontColor: Colors.black)),
                          ),

                          SizedBox(
                            height: 4.h,
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: customTextFormField(
                              prefix: Image.asset("assets/images/email.png"),
                              hintText: "Email Address",
                              validator: (p0) {
                                if (p0!.isEmpty) {
                                  return "Please Enter Email Address";
                                }
                              },
                            ),
                          ),

                          SizedBox(
                            height: 2.h,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: customTextFormField(
                              prefix: Image.asset("assets/images/lock.png"),
                              hintText: "Password",
                              validator: (p0) {
                                if (p0!.isEmpty) {
                                  return "Please Enter Password ";
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            height: 5.h,
                          ),

                          Obx(
                                () => controller.isLoading.value
                                ? LoadingAnimationWidget.hexagonDots(
                                color: AppColor.appBackColor, size: 5.h)
                                : Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: MaterialButton(
                                color: AppColor.ButtonColor,
                                onPressed: () {
                                  controller.login();
                                },
                                height: 26,
                                padding: EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                minWidth: double.infinity,
                                child: Center(
                                    child: Text(
                                      "Sign in",
                                      style: TextStyle(color: Colors.white, fontSize: 15),
                                    )),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 2.h,
                          ),


                          Center(
                            child: GestureDetector(
                                onTap: () {
                                  // Get.toNamed(Routes.REGISTERSCREEN);
                                },
                                child: "Forgot the password ?".mediumReadex(fontColor: AppColor.ButtonColor,fontSize: 12)),
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
                                Expanded(flex: 1, child: Center(child: Text("OR",style: TextStyle(fontSize: 23,color: Colors.grey),))),
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
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
