import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../api/listing/api_listing.dart';
import '../../../../api/url/api_url.dart';
import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../home/Model/StudentCourse.dart';

class CourseController extends GetxController {
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  
  List<StudentCourse> courses = <StudentCourse>[].obs;
  var subCategoryId = 0.obs;
  var subCategoryName = ''.obs;
  final RxSet<int> enrollingCourseIds = <int>{}.obs;
  
  SharedPrefHelper sharedPrefHelper = SharedPrefHelper();

  @override
  void onInit() {
    super.onInit();
    // Get subCategoryId from arguments
    if (Get.arguments != null) {
      subCategoryId.value = Get.arguments['subCategoryId'] ?? 0;
      subCategoryName.value = Get.arguments['subCategoryName'] ?? '';
    }
    if (subCategoryId.value > 0) {
      fetchCourses();
    }
  }


  Future<void> fetchCourses() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      String? token = sharedPrefHelper.getString(SharedPrefHelper.token);
      
      if (token == null) {
        hasError.value = true;
        errorMessage.value = 'User not authenticated';
        isLoading.value = false;
        return;
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      final response = await NetworkService.makeGetRequest(
        url: '${ApiUrl.getCoursesBySubCategory}${subCategoryId.value}',
        headers: headers,
      );

      isLoading.value = false;

      if (response["statusCode"] == 200) {
        List<dynamic> jsonList = response['response'];
        courses.assignAll(jsonList.map((item) => StudentCourse.fromJson(item)).toList());
        print('Courses loaded successfully: ${courses.length}');
      } else {
        hasError.value = true;
        errorMessage.value = response["response"]?.toString() ?? 'Failed to load courses';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = 'An unexpected error occurred: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
    }
  }

  Future<void> refreshCourses() async {
    await fetchCourses();
  }

  void onCourseTap(StudentCourse course) {
    // Navigate to LessonScreen with course details
    Get.toNamed('/lesson', arguments: {
      'courseId': course.courseId,
      'courseName': course.courseName,
    });
  }

  Future<void> enrollInCourse(StudentCourse course) async {
    final int? courseId = course.courseId;
    if (courseId == null) {
      Get.snackbar(
        'Error', 
        'Invalid course',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (enrollingCourseIds.contains(courseId)) return;
    enrollingCourseIds.add(courseId);

    try {
      String? token = sharedPrefHelper.getString(SharedPrefHelper.token);
      if (token == null) {
        Get.snackbar(
          'Error', 
          'User not authenticated. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        enrollingCourseIds.remove(courseId);
        return;
      }

      print("🎓 Enrolling in course ID: $courseId");
      
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = {
        'courseId': courseId,
      };

      print("📤 Enrollment request body: $body");

      final response = await NetworkService.makePostRequest(
        url: ApiUrl.enrollInCourse,
        headers: headers,
        body: body,
      );

      print("📥 Enrollment response: ${response['statusCode']} - ${response['response']}");

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        // Parse the enrollment response
        final enrollmentData = response['response'];
        if (enrollmentData != null) {
          final enrollmentId = enrollmentData['enrollmentId'];
          final userId = enrollmentData['userId'];
          final completed = enrollmentData['completed'];
          
          print("✅ Enrollment successful - ID: $enrollmentId, User: $userId, Completed: $completed");
          
          Get.snackbar(
            'Success! 🎉', 
            'You are now enrolled in "${course.courseName}"',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );
        } else {
          Get.snackbar(
            'Success! 🎉', 
            'You are now enrolled in "${course.courseName}"',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );
        }
      } else if (response['statusCode'] == 409) {
        Get.snackbar(
          'Already Enrolled', 
          'You are already enrolled in this course',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: const Icon(Icons.info, color: Colors.white),
        );
      } else if (response['statusCode'] == 400) {
        Get.snackbar(
          'Invalid Request', 
          'Please check your course selection and try again',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      } else if (response['statusCode'] == 401) {
        Get.snackbar(
          'Authentication Error', 
          'Your session has expired. Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.lock, color: Colors.white),
        );
      } else {
        final errorMessage = response['response']?.toString() ?? 'Unknown error occurred';
        Get.snackbar(
          'Enrollment Failed', 
          'Failed to enroll: $errorMessage',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      print("❌ Enrollment error: $e");
      Get.snackbar(
        'Network Error', 
        'Enrollment failed: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.wifi_off, color: Colors.white),
      );
    } finally {
      enrollingCourseIds.remove(courseId);
    }
  }
}
