import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../api/listing/api_listing.dart';
import '../../../../api/url/api_url.dart';
import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../ROLE_INSTRUCTORS/showAllLession/model/lesson_model.dart';

class LessonController extends GetxController {
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  
  List<Lesson> lessons = <Lesson>[].obs;
  var courseId = 0.obs;
  var courseName = ''.obs;
  
  SharedPrefHelper sharedPrefHelper = SharedPrefHelper();

  @override
  void onInit() {
    super.onInit();
    // Get courseId from arguments
    if (Get.arguments != null) {
      courseId.value = Get.arguments['courseId'] ?? 0;
      courseName.value = Get.arguments['courseName'] ?? '';
    }
    if (courseId.value > 0) {
      fetchLessons();
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

  Future<void> fetchLessons() async {
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
        url: '${ApiUrl.getAllLession}${courseId.value}',
        headers: headers,
      );

      isLoading.value = false;

      if (response["statusCode"] == 200) {
        List<dynamic> jsonList = response['response'];
        List<Lesson> lessonList = jsonList.map((item) => Lesson.fromJson(item)).toList();
        // Sort lessons by sequence number
        lessonList.sort((a, b) => (a.sequenceNumber ?? 0).compareTo(b.sequenceNumber ?? 0));
        lessons.assignAll(lessonList);
        print('Lessons loaded successfully: ${lessons.length}');
      } else {
        hasError.value = true;
        errorMessage.value = response["response"]?.toString() ?? 'Failed to load lessons';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = 'An unexpected error occurred: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
    }
  }

  Future<void> refreshLessons() async {
    await fetchLessons();
  }

  void onLessonTap(Lesson lesson) {
    // Navigate to LessonDetailScreen with lesson details
    Get.toNamed('/lesson-detail', arguments: {
      'lessonId': lesson.lessonId,
      'lessonName': lesson.lessonName,
      'courseName': courseName.value,
    });
  }

  void startLesson(Lesson lesson) {
    // TODO: Implement lesson start functionality
    Get.snackbar('Starting Lesson', 'Starting ${lesson.lessonName}');
  }

  Color getProcessingStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'pending':
        return Colors.amber;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getProcessingStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Ready';
      case 'processing':
        return 'Processing';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }
}
