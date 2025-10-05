import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shaktihub/api/listing/api_listing.dart';
import 'package:shaktihub/api/url/api_url.dart';
import 'package:shaktihub/module/ROLE_USER/home/Model/StudentCourse.dart';
import 'package:shaktihub/module/ROLE_USER/home/Model/EnrollmentModel.dart';
import 'package:shaktihub/module/ROLE_USER/home/Model/EnrolledCourseModel.dart';

import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../Model/PopularCourse.dart';

class HomeScreenController extends GetxController{

  List<StudentCourse> allCourses = <StudentCourse>[];
  List<PopularCourse> allPopularCourse = <PopularCourse>[];
  List<EnrolledCourseModel> myEnrolledCourses = <EnrolledCourseModel>[];
  bool isLoading = true;
  bool isLoadingEnrolledCourses = false;



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
        loadMyEnrolledCourses(),
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

  Future<void> loadMyEnrolledCourses() async {
    try {
      isLoadingEnrolledCourses = true;
      update();

      final token = sh1.getString(SharedPrefHelper.token);
      if (token == null || token.isEmpty) {
        print("❌ No authentication token found");
        return;
      }

      String uri = ApiUrl.getMyEnrollments;
      Map<String, String> header = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      print("🎓 Fetching my enrollments...");
      final response = await NetworkService.makeGetRequest(url: uri, headers: header);
      print("📥 Enrollments response: ${response['statusCode']}");

      if (response['statusCode'] == 200) {
        List<dynamic> enrollmentData = response["response"];
        print("✅ Found ${enrollmentData.length} enrollments");
        print("📋 Enrollment data: $enrollmentData");

        myEnrolledCourses.clear();

        for (var enrollmentJson in enrollmentData) {
          try {
            final enrollment = EnrollmentModel.fromJson(enrollmentJson);
            print("📚 Processing enrollment for course ID: ${enrollment.courseId}");
            print("📋 Enrollment details: ${enrollment.toJson()}");

            // Fetch course details
            final course = await _fetchCourseById(enrollment.courseId, token);
            if (course != null) {
              final enrolledCourse = EnrolledCourseModel(
                enrollment: enrollment,
                course: course,
              );
              myEnrolledCourses.add(enrolledCourse);
              print("✅ Added enrolled course: ${course.courseName}");
            } else {
              print("❌ Could not fetch course details for ID: ${enrollment.courseId}");
            }
          } catch (e) {
            print("❌ Error processing enrollment: $e");
            print("📋 Enrollment JSON that failed: $enrollmentJson");
          }
        }

        print("🎉 Successfully loaded ${myEnrolledCourses.length} enrolled courses");
        update();
      } else {
        print("❌ Failed to fetch enrollments: ${response['statusCode']}");
        Get.snackbar(
          'Error',
          'Failed to load enrolled courses',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("❌ Error loading enrolled courses: $e");
      Get.snackbar(
        'Error',
        'Error loading enrolled courses: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingEnrolledCourses = false;
      update();
    }
  }

  Future<StudentCourse?> _fetchCourseById(int courseId, String token) async {
    try {
      String uri = '${ApiUrl.getCourseById}$courseId';
      Map<String, String> header = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      print("🔍 Fetching course details for ID: $courseId");
      print("🌐 API URL: $uri");

      final response = await NetworkService.makeGetRequest(url: uri, headers: header);
      
      print("📊 Course fetch response: ${response['statusCode']}");
      
      if (response['statusCode'] == 200) {
        print("✅ Successfully fetched course: $courseId");
        return StudentCourse.fromJson(response["response"]);
      } else {
        print("❌ Failed to fetch course $courseId: ${response['statusCode']}");
        print("📋 Response: ${response['response']}");
        return null;
      }
    } catch (e) {
      print("❌ Error fetching course $courseId: $e");
      return null;
    }
  }

}