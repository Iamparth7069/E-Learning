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

  @override
  void onReady() {
    super.onReady();
    // Additional setup after the controller is ready
  }

  @override
  void onClose() {
    // Clean up resources if needed
    super.onClose();
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
      Get.snackbar('Error', 'Invalid course');
      return;
    }

    if (enrollingCourseIds.contains(courseId)) return;
    enrollingCourseIds.add(courseId);

    try {
      String? token = sharedPrefHelper.getString(SharedPrefHelper.token);
      if (token == null) {
        Get.snackbar('Error', 'User not authenticated');
        enrollingCourseIds.remove(courseId);
        return;
      }

      print("Course id $courseId");
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = {
        'courseId': courseId,
      };

      final response = await NetworkService.makePostRequest(
        url: ApiUrl.getUserByCourse,
        headers: headers,
        body: body,
      );

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        Get.snackbar('Enrolled', 'You are enrolled in ${course.courseName}');
      } else if (response['statusCode'] == 409) {
        Get.snackbar('Already enrolled', 'You are already enrolled in this course');
      } else {
        Get.snackbar('Error', 'Failed to enroll: ${response['response']}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Enrollment failed: $e');
    } finally {
      enrollingCourseIds.remove(courseId);
    }
  }
}
