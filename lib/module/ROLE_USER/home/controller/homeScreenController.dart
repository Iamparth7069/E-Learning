import 'dart:convert';

import 'package:get/get.dart';
import 'package:shaktihub/api/listing/api_listing.dart';
import 'package:shaktihub/api/url/api_url.dart';
import 'package:shaktihub/module/ROLE_USER/home/Model/StudentCourse.dart';

import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../Model/PopularCourse.dart';

class HomeScreenController extends GetxController{

  List<StudentCourse> allCourses = <StudentCourse>[];
  List<PopularCourse> allPopularCourse = <PopularCourse>[];
  bool isLoading = true;



  @override
  void onInit() {
    super.onInit();
    loadData();

  }


  Future<void> loadData() async {
    isLoading = true;
    update(); // show loading UI

    try {
      await Future.wait([
        loadPopularCourses(),
        loadCourse(),
      ]);
    } catch (e) {
      print("Error loading data: $e");
    }

    isLoading = false;
    update(); // hide loading UI
  }



  SharedPrefHelper sh1 = SharedPrefHelper();



  Future<void> loadCourse() async {
    try{
      final token = sh1.getString(SharedPrefHelper.token);

      String uri = ApiUrl.getAllCourse;
      Map<String,String> header = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      final response  = await NetworkService.makeGetRequest(url: uri,headers: header);

      print("Response is ${response['statusCode']}");
      if(response['statusCode'] == 200){
        List<dynamic> dataGet = response["response"];
        allCourses =
            dataGet.map((json) => StudentCourse.fromJson(json)).toList();

          update();

      }else{
        print("Error is " + response['statusCode'].toString());
      }
    }catch(e){
      print("Error is ${e.toString()}");
    }
  }

  Future<void> loadPopularCourses() async{

    try{
      final token = sh1.getString(SharedPrefHelper.token);
      String uri = ApiUrl.getAllPopularCourse;
      Map<String,String> header = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };
      final response  = await NetworkService.makeGetRequest(url: uri,headers: header);
      print("Response is ${response['statusCode']}");


      if(response['statusCode'] == 200){
        List<dynamic> dataGet = response["response"];
        allPopularCourse = dataGet.map((json) => PopularCourse.fromJson(json)).toList();
        update();

      }else{
        print("Error is " + response['statusCode'].toString());
      }
    }catch(e){
      print("Error is " + e.toString());


    }
  }

}