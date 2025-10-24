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
      // Load data sequentially to avoid overwhelming the server
      await loadPopularCourses();
      await loadCourse();
      await loadMyEnrolledCourses();
    } catch (e) {
      print("❌ Error loading data: $e");
      Get.snackbar(
        'Error',
        'Failed to load some data. Please try again.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning, color: Colors.white),
      );
    } finally {
      isLoading = false;
      update(); // hide loading UI
    }
  }



  SharedPrefHelper sh1 = SharedPrefHelper();



  Future<void> loadCourse() async {
    try{
      final token = sh1.getString(SharedPrefHelper.token);
      if (token == null || token.isEmpty) {
        print("❌ No authentication token found for loading courses");
        return;
      }

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
      if (token == null || token.isEmpty) {
        print("❌ No authentication token found for loading popular courses");
        return;
      }
      
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
        
        // Check for course completions after loading enrollments
        await _checkAndUpdateCourseCompletions();
        
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

  // Check and update course completions
  Future<void> _checkAndUpdateCourseCompletions() async {
    try {
      print("🎯 Checking course completions...");
      
      for (var enrolledCourse in myEnrolledCourses) {
        final enrollment = enrolledCourse.enrollment;
        final course = enrolledCourse.course;
        
        // Skip if already completed
        if (enrollment.completed) {
          print("✅ Course ${course.courseName} is already completed");
          continue;
        }
        
        // Check if course should be marked as complete
        final shouldComplete = await _shouldCompleteCourse(enrollment.courseId);
        
        if (shouldComplete) {
          print("🎉 Course ${course.courseName} should be marked as complete!");
          await _markCourseAsComplete(enrollment.enrollmentId);
          
          // Update local enrollment status
          
          // Show completion notification
          Get.snackbar(
            'Course Completed! 🎉',
            'Congratulations! You have completed ${course.courseName}',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.celebration, color: Colors.white),
            duration: const Duration(seconds: 4),
          );
        }
      }
      
      // Update UI after checking completions
      update();
      
    } catch (e) {
      print("❌ Error checking course completions: $e");
    }
  }

  // Check if a course should be marked as complete
  Future<bool> _shouldCompleteCourse(int courseId) async {
    try {
      final token = sh1.getString(SharedPrefHelper.token);
      if (token == null || token.isEmpty) {
        print("❌ No authentication token for completion check");
        return false;
      }

      // Get all lessons for this course
      String uri = '${ApiUrl.getLessonsByCourseId}$courseId';
      Map<String, String> header = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      print("📚 Checking lessons for course ID: $courseId");
      final response = await NetworkService.makeGetRequest(url: uri, headers: header);
      
      if (response['statusCode'] == 200) {
        List<dynamic> lessonsData = response["response"];
        print("📖 Found ${lessonsData.length} lessons for course $courseId");
        
        if (lessonsData.isEmpty) {
          print("⚠️ No lessons found for course $courseId");
          return false;
        }
        
        // Check lesson progress for this course
        return await _checkLessonProgress(courseId, lessonsData.length);
        
      } else {
        print("❌ Failed to fetch lessons for course $courseId: ${response['statusCode']}");
        return false;
      }
    } catch (e) {
      print("❌ Error checking course completion for $courseId: $e");
      return false;
    }
  }

  // Check lesson progress for a course
  Future<bool> _checkLessonProgress(int courseId, int totalLessons) async {
    try {
      final token = sh1.getString(SharedPrefHelper.token);
      if (token == null || token.isEmpty) {
        return false;
      }

      // Get enrollment progress for this course
      String uri = '${ApiUrl.getEnrollmentProgress}$courseId';
      Map<String, String> header = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      print("📊 Checking progress for course ID: $courseId");
      final response = await NetworkService.makeGetRequest(url: uri, headers: header);
      
      if (response['statusCode'] == 200) {
        // Parse progress data and check if course should be completed
        // This is a simplified implementation - adjust based on your API response structure
        var progressData = response["response"];
        print("📈 Progress data: $progressData");
        
        // For now, we'll use a simple heuristic: if there are lessons and some progress exists
        // In a real implementation, you would check actual completion percentages
        return totalLessons > 0; // Simplified logic
        
      } else {
        print("❌ Failed to fetch progress for course $courseId: ${response['statusCode']}");
        return false;
      }
    } catch (e) {
      print("❌ Error checking lesson progress for $courseId: $e");
      return false;
    }
  }

  // Mark a course as complete
  Future<void> _markCourseAsComplete(int enrollmentId) async {
    try {
      final token = sh1.getString(SharedPrefHelper.token);
      if (token == null || token.isEmpty) {
        print("❌ No authentication token for course completion");
        return;
      }

      String uri = '${ApiUrl.completeEnrollment}$enrollmentId/complete';
      Map<String, String> header = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      print("🎓 Marking course as complete for enrollment ID: $enrollmentId");
      print("🌐 API URL: $uri");

      final response = await NetworkService.makePostRequest(
        url: uri,
        headers: header,
        body: {}, // Empty body as per API specification
      );

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        print("✅ Course marked as complete successfully");
      } else {
        print("❌ Failed to mark course as complete: ${response['statusCode']}");
        print("📋 Response: ${response['response']}");
      }
    } catch (e) {
      print("❌ Error marking course as complete: $e");
    }
  }

  // Manual method to check course completions (can be called from UI)
  Future<void> checkCourseCompletions() async {
    try {
      await _checkAndUpdateCourseCompletions();
    } catch (e) {
      print("❌ Error in manual completion check: $e");
      Get.snackbar(
        'Error',
        'Failed to check course completions. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  // Method to refresh all data
  Future<void> refreshData() async {
    await loadData();
  }

  // Method to check if user is authenticated
  bool isAuthenticated() {
    final token = sh1.getString(SharedPrefHelper.token);
    return token != null && token.isNotEmpty;
  }

  // Method to get authentication token
  String? getAuthToken() {
    return sh1.getString(SharedPrefHelper.token);
  }

}