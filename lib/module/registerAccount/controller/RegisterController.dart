import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../api/listing/api_listing.dart';
import '../../../api/url/api_url.dart';



class RegisterController extends GetxController{
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController rePassword = TextEditingController();

  RxBool isLoading = false.obs;
  final formKey = GlobalKey<FormState>();


  @override
  void onInit() {
    super.onInit();
  }

  Future<void> register() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      update();

      Map<String, String> headers = {'Content-Type': 'application/json'};
      Map<String, dynamic> body = {
        'email': email.text.trim(),
        'password': password.text,
        'firstName': firstName.text.trim(),
        'lastName': lastName.text.trim(),
      };

      print("Request URL: ${ApiUrl.registerApi}");
      print("Request Body: $body");

      try {
        Map<String, dynamic> response = await NetworkService.makePostRequest(
          url: ApiUrl.registerApi,
          headers: headers,
          body: body,
        );

        debugPrint("Response: ${response.toString()}");

        if (response['statusCode'] == 200 || response['statusCode'] == 201) {
          // Handle success response
          print("Registration Successful: ${response['response']}");
          Get.defaultDialog(
            title: "Success",
            middleText: "Registration successful!",
            textConfirm: "OK",
            confirmTextColor: Colors.white,
            onConfirm: () {
              Get.back(); // Close dialog
              Get.back(); // Navigate back to the previous screen
            },
          );
        } else {
          // Handle error response
          print("Registration Failed: ${response['response']}");
        }
      } catch (e) {
        print("Error: $e");
      } finally {
        isLoading.value = false;
        update();
      }
    }
  }


}