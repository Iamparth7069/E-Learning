import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shaktihub/SharedPrefrance/SharedPrefrance_helper.dart';
import 'package:shaktihub/api/url/api_url.dart';
import 'package:shaktihub/module/login/Model/UserModel.dart';


import '../../../api/listing/api_listing.dart';
import '../../../routes/app_pages.dart';


class LoginController extends GetxController {



  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  RxBool isLoading = false.obs;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final key = GlobalKey<FormState>();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    // LocalStorage.sendBiometric(bio: false);
  }

  Future<void> login() async {
    if (key.currentState!.validate()) {
      isLoading.value = true;
      update();

      Map<String, String> headers = {'Content-Type': 'application/json'};
      Map<String, dynamic> body = {
        'email': emailController.text.trim(),
        'password': passwordController.text.trim()
      };

      print("Request URL: ${ApiUrl.loginApi}");
      print("Request Body: $body");

      try {
        Map<String, dynamic> response = await NetworkService.makePostRequest(
          url: ApiUrl.loginApi,
          headers: headers,
          body: body,
        );

        debugPrint("Response: ${response.toString()}");

        if (response.containsKey('statusCode') &&
            (response['statusCode'] == 200 || response['statusCode'] == 201)) {

          Map<String, dynamic> data = response['response'];

          UserModel userData = UserModel.fromJson(data);
          print("User Role is ${userData.token}");
          SharedPrefHelper sh1 = SharedPrefHelper();
          sh1.setString(SharedPrefHelper.token, userData.token);
          sh1.setBool(SharedPrefHelper.loginStatus, true);
          if (userData.user.role == "ROLE_ADMIN") {
            print("This is an Admin User");
            sh1.setBool(SharedPrefHelper.IsAdmin,true);

            Get.offAllNamed(Routes.AdminDeskBoard,arguments: 0);
          } else {
            print("This is a Normal User");
            Get.offAllNamed(Routes.DeskBord,arguments: 0);
          }
        } else {
          print("Error For Debugging");
          Get.snackbar("Error", response['response'] ?? "Login failed",
              snackPosition: SnackPosition.BOTTOM);
        }
      } catch (e) {
        print("Exception caught: $e");
        Get.snackbar("Error", "Something went wrong. Please try again later.",
            snackPosition: SnackPosition.BOTTOM);
      } finally {
        isLoading.value = false;
        update();
      }
    }
  }




  // Future signInWithGoogle() async {
  //   try {
  //     final GoogleSignIn googleSignIn = GoogleSignIn();
  //     final GoogleSignInAccount? googleSignInAccount =
  //     await googleSignIn.signIn();
  //
  //     if (googleSignInAccount != null) {
  //       final GoogleSignInAuthentication googleSignInAuthentication =
  //       await googleSignInAccount.authentication;
  //
  //       final OAuthCredential credential = GoogleAuthProvider.credential(
  //         accessToken: googleSignInAuthentication.accessToken,
  //         idToken: googleSignInAuthentication.idToken,
  //       );
  //
  //       final UserCredential authResult =
  //       await FirebaseAuth.instance.signInWithCredential(credential);
  //       final User? user = authResult.user;
  //
  //       if (user != null) {
  //         // Checking if user is logging in for the first time
  //         final userDoc = await FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(user.uid)
  //             .get();
  //         if (!userDoc.exists) {
  //           // New user. You can now navigate the user to your onboarding screen or create a new user document in Firestore.
  //           // For example, creating a user document:
  //           await FirebaseFirestore.instance
  //               .collection('users')
  //               .doc(user.uid)
  //               .set({
  //             'uid': user.uid,
  //             'email': user.email,
  //             // Add more fields as needed
  //           });
  //           print("New user created");
  //         } else {
  //           // Existing user. Navigate the user to your home screen or perform other actions.
  //           print("Welcome back!");
  //         }
  //       }
  //       return authResult;
  //     }
  //   } catch (error) {
  //     print('Error signing in with Google: $error');
  //     // Handle error further if needed
  //   }
  // }
}
