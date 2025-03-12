import 'package:flutter/material.dart';
import 'package:shaktihub/Constraint/app_color.dart';
import 'package:get/get.dart';
import 'package:shaktihub/Constraint/extension.dart';
import 'package:sizer/sizer.dart';
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.appBackColor,
      body: SingleChildScrollView(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -70,
              left: -20,
              child: Image.asset("assets/images/img_1.png",scale:2,),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 50,horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(onPressed: () {
                  Get.back();
                  }, icon: Icon(Icons.arrow_back,size: 3.h,)),
                  SizedBox(
                    height: 5.h,
                  ),
        
                  Center(
                      child: ReadexPro("Create Your Account")
                          .boldReadex(fontSize: 23, fontColor: Colors.black)),
                  SizedBox(
                    height: 3.h,
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        assetImage("assets/images/profile.png",height: 150,width: 150),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 6.h,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: customTextFormField(
                      prefix: Image.asset("assets/images/pro.png"),
                      hintText: "First Name",
                      validator: (p0) {
                        if (p0!.isEmpty) {
                          return "Please Enter First Name";
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
                      prefix: Image.asset("assets/images/pro.png"),
                      hintText: "Last Name",
                      validator: (p0) {
                        if (p0!.isEmpty) {
                          return "Please Enter Last Name";
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
                    height: 2.h,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: customTextFormField(
                      prefix: Image.asset("assets/images/lock.png"),
                      hintText: "Retype-Password",
                      validator: (p0) {
                        if (p0!.isEmpty) {
                          return "Password Miss Match";
                        }
                      },
                    ),
                  ),
                  SizedBox(
                    height: 2.h,
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: MaterialButton(
                      color: AppColor.ButtonColor,
                      onPressed: () {
                        // Get.toNamed(Routes.LOGIN);
                      },
                      height: 26,
                      padding: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      minWidth: double.infinity,
                      child: Center(
                          child: Text(
                            "Sign up",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          )),
                    ),
                  ),

                  SizedBox(
                    height: 2.h,
                  ),
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
                        Expanded(flex: 1, child: Center(child: Text("OR"))),
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
                  SizedBox(
                    height: 2.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      "Already have an account ?".mediumReadex(fontColor: Color(0xff6A8FA3)),
                      SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                          onTap: () {
                            // Get.toNamed(Routes.REGISTERSCREEN);
                          },
                          child: "Sign in".mediumReadex(fontColor: AppColor.ButtonColor)),

                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
