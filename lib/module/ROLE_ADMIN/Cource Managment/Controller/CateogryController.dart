import 'dart:convert';

import 'package:get/get.dart';
import 'package:shaktihub/api/url/api_url.dart';

import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../../api/listing/api_listing.dart';
import '../Model/CourceModel.dart';

class CourseManagment extends GetxController{

  bool isLoading = false;


  SharedPrefHelper sh1 = SharedPrefHelper();

  List<Course> getAllCouceData = [];

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();
   await GetCourseDetails();
  }

  Future<void> GetCourseDetails() async {
    try{
      print("Call this Function");
      isLoading = true;
      String? token = sh1.getString(SharedPrefHelper.token);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

    final response = await NetworkService.makeGetRequest(url: ApiUrl.getAllCourse,
      headers: headers
      );

    print("Response Is " + response.toString());

      if (response["statusCode"] == 200) {
        getAllCouceData = (response["response"] as List).map((data) => Course.fromJson(data)).toList();
        isLoading = false;
        update();
      }else{
        Get.snackbar('Error', 'Failed to add. ${response["response"]}');
      }
      }catch(e){
        print("Error is " + e.toString());

    }
  }
}