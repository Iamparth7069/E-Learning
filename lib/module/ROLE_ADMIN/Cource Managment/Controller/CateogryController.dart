import 'dart:convert';

import 'package:get/get.dart';
import 'package:shaktihub/api/url/api_url.dart';

import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../../api/listing/api_listing.dart';
import '../Model/CourceModel.dart';

class CourseManagment extends GetxController{

  bool isLoading = false;
  bool isEmpty = false;
  bool isLoadingUsers = false;
  bool isEmptyUsers = false;

  SharedPrefHelper sh1 = SharedPrefHelper();

  List<Course> getAllCouceData = [];
  List<Enrollment> enrollments = [];
  List<User> enrolledUsers = [];
  Course? selectedCourse;
  
  // Progress tracking
  bool isLoadingProgress = false;
  double enrollmentProgress = 0.0;

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
      isEmpty = false;
      update();
      
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
        List<dynamic> responseData = response["response"] as List;
        getAllCouceData = responseData.map((data) => Course.fromJson(data)).toList();
        
        // Check if data is empty
        isEmpty = getAllCouceData.isEmpty;
        isLoading = false;
        update();
      }else{
        isLoading = false;
        isEmpty = true;
        update();
        Get.snackbar('Error', 'Failed to load courses. ${response["response"]}');
      }
      }catch(e){
        print("Error is " + e.toString());
        isLoading = false;
        isEmpty = true;
        update();
        Get.snackbar('Error', 'Something went wrong while loading courses');
    }
  }

  void selectCourse(Course course) {
    selectedCourse = course;
    update();
    getEnrolledUsers(course.courseId);
  }

  Future<void> getEnrolledUsers(int courseId) async {
    try {
      isLoadingUsers = true;
      isEmptyUsers = false;
      update();

      String? token = sh1.getString(SharedPrefHelper.token);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      final response = await NetworkService.makeGetRequest(
        url: '${ApiUrl.getUserByCourse}$courseId',
        headers: headers
      );

      print("Enrollments Response: " + response.toString());

      if (response["statusCode"] == 200) {
        List<dynamic> enrollmentData = response["response"] as List;
        enrollments = enrollmentData.map((data) => Enrollment.fromJson(data)).toList();
        
        // Fetch user details for each enrollment
        await fetchUserDetails();
        
        isEmptyUsers = enrolledUsers.isEmpty;
        isLoadingUsers = false;
        update();
      } else {
        isLoadingUsers = false;
        isEmptyUsers = true;
        update();
        Get.snackbar('Error', 'Failed to load enrolled users. ${response["response"]}');
      }
    } catch (e) {
      print("Error fetching enrollments: " + e.toString());
      isLoadingUsers = false;
      isEmptyUsers = true;
      update();
      Get.snackbar('Error', 'Something went wrong while loading enrolled users');
    }
  }

  Future<void> fetchUserDetails() async {
    enrolledUsers.clear();
    
    for (Enrollment enrollment in enrollments) {
      try {
        String? token = sh1.getString(SharedPrefHelper.token);
        Map<String, String> headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        };

        final response = await NetworkService.makeGetRequest(
          url: '${ApiUrl.getUserById}${enrollment.userId}',
          headers: headers
        );

        if (response["statusCode"] == 200) {
          User user = User.fromJson(response["response"]);
          enrolledUsers.add(user);
        }
      } catch (e) {
        print("Error fetching user ${enrollment.userId}: " + e.toString());
      }
    }
  }

  Future<void> getEnrollmentProgress(int enrollmentId) async {
    try {
      isLoadingProgress = true;
      update();

      String? token = sh1.getString(SharedPrefHelper.token);
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      final response = await NetworkService.makeGetRequest(
        url: '${ApiUrl.getEnrollmentProgress}$enrollmentId',
        headers: headers
      );

      print("Progress Response: " + response.toString());

      if (response["statusCode"] == 200) {
        // The API returns a double value (0.0 to 1.0)
        enrollmentProgress = (response["response"] as num).toDouble();
        isLoadingProgress = false;
        update();
      } else {
        isLoadingProgress = false;
        update();
        Get.snackbar('Error', 'Failed to load progress. ${response["response"]}');
      }
    } catch (e) {
      print("Error fetching progress: " + e.toString());
      isLoadingProgress = false;
      update();
      Get.snackbar('Error', 'Something went wrong while loading progress');
    }
  }
}