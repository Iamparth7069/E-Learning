import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shaktihub/module/ROLE_INSTRUCTORS/StudentScreen/Model/StudentModel.dart';
import 'package:shaktihub/module/ROLE_INSTRUCTORS/StudentScreen/Model/EnrollmentModel.dart';
import 'package:shaktihub/module/ROLE_INSTRUCTORS/StudentScreen/Model/UserModel.dart';
import '../../../../api/listing/api_listing.dart';
import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../../api/url/api_url.dart';

class StudentManagmentController extends GetxController {
  RxList<StudentModel> getAllCouceData = <StudentModel>[].obs;
  RxList<EnrollmentModel> enrollments = <EnrollmentModel>[].obs;
  RxList<UserModel> students = <UserModel>[].obs;
  RxInt selectedCourseId = 0.obs;
  RxBool isLoading = false.obs;
  RxBool isLoadingStudents = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCourse();
  }

  Future<void> loadCourse() async {
    try {
      String url = ApiUrl.getAllCourseByInstructor;
      String? token = SharedPrefHelper().getString(SharedPrefHelper.token);

      print("🔑 Token value: $token");

      if (token == null) {
        throw Exception("Token is null! Check SharedPreferences.");
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await NetworkService.makeGetRequest(
        url: url,
        headers: headers,
      );

      print("📥 Response: $response");

      if (response["statusCode"] == 200) {
        getAllCouceData.value = (response["response"] as List)
            .map((data) => StudentModel.fromJson(data))
            .toList();

        if (getAllCouceData.isNotEmpty) {
          selectedCourseId.value = getAllCouceData.first.courseId!;
        }
      } else {
        Get.snackbar('Error', 'Failed to load courses');
      }
    } catch (e, stack) {
      print("❌ Error: $e");
      print("📍 StackTrace: $stack");
    }
  }

  Future<void> getUser(int courseId) async {
    try {
      isLoadingStudents.value = true;
      errorMessage.value = '';
      
      String? token = SharedPrefHelper().getString(SharedPrefHelper.token);
      
      if (token == null || token.isEmpty) {
        throw Exception("Authentication token is missing. Please login again.");
      }

      print("🎓 Fetching students for course ID: $courseId");

      // First, get enrollments for the course
      await _fetchEnrollments(courseId, token);
      
      // Then, fetch user details for each enrollment
      await _fetchUserDetails(token);
      
    } catch (e) {
      print("❌ Error fetching students: $e");
      errorMessage.value = e.toString();
      Get.snackbar(
        "Error",
        "Failed to load students: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingStudents.value = false;
    }
  }

  Future<void> _fetchEnrollments(int courseId, String token) async {
    try {
      String url = "${ApiUrl.getUserByCourse}$courseId";
      
      final response = await NetworkService.makeGetRequest(
        url: url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📥 Enrollments Response: ${response['statusCode']}");

      if (response["statusCode"] == 200) {
        List<dynamic> enrollmentList = response["response"];
        enrollments.value = enrollmentList
            .map((data) => EnrollmentModel.fromJson(data))
            .toList();
        
        print("✅ Found ${enrollments.length} enrollments");
      } else {
        throw Exception("Failed to fetch enrollments: ${response['response']}");
      }
    } catch (e) {
      print("❌ Error fetching enrollments: $e");
      rethrow;
    }
  }

  Future<void> _fetchUserDetails(String token) async {
    try {
      students.clear();
      
      for (EnrollmentModel enrollment in enrollments) {
        try {
          String url = "${ApiUrl.getUserById}${enrollment.userId}";
          
          final response = await NetworkService.makeGetRequest(
            url: url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          );

          if (response["statusCode"] == 200) {
            UserModel user = UserModel.fromJson(response["response"]);
            students.add(user);
            print("✅ Loaded user: ${user.fullName}");
          } else {
            print("⚠️ Failed to load user ${enrollment.userId}: ${response['response']}");
          }
        } catch (e) {
          print("❌ Error loading user ${enrollment.userId}: $e");
        }
      }
      
      print("✅ Successfully loaded ${students.length} students");
    } catch (e) {
      print("❌ Error fetching user details: $e");
      rethrow;
    }
  }

  void clearStudents() {
    students.clear();
    enrollments.clear();
    errorMessage.value = '';
  }

}
