import 'package:get/get.dart';
import 'package:shaktihub/SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../../api/listing/api_listing.dart';
import '../../../../api/url/api_url.dart';
import '../../../ROLE_ADMIN/Home/model/subCategoryModel.dart';
import '../Model/CourseModel.dart';

class HomeScreenInstructorController extends GetxController {
  var selectedSubCategoryId = 0.obs;

  RxList<CourseModel> courseList = <CourseModel>[].obs;
  RxList<CourseModel> filteredCourseList = <CourseModel>[].obs;
  RxList<SubCategoryModel> subCategory = <SubCategoryModel>[].obs;
  RxString userName = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isRefreshing = false.obs;
  RxString searchQuery = ''.obs;

  SharedPrefHelper sharedPrefHelper = SharedPrefHelper();

  @override
  void onInit() {
    super.onInit();
    loadData();
    getAllSubCategory();
    
    // Listen to search query changes
    searchQuery.listen((query) {
      filterCourses();
    });
    
    // Listen to subcategory changes
    selectedSubCategoryId.listen((id) {
      filterCourses();
    });
  }

  void loadData() {
    isLoading.value = true;

    userName.value = sharedPrefHelper.getString(SharedPrefHelper.userName) ?? '';
    print("Token is ${sharedPrefHelper.getString(SharedPrefHelper.token)}");

    loadCourse().then((_) {
      isLoading.value = false;
    });
  }

  Future<void> loadCourse() async {
    try {
      String? token = sharedPrefHelper.getString(SharedPrefHelper.token);
      if (token == null) {
        print("❌ No authentication token found");
        return;
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      String url = ApiUrl.getAllCourseByInstructor;
      final response = await NetworkService.makeGetRequest(
        url: url,
        headers: headers,
      );

      print("📊 Course Response: $response");

      if (response["statusCode"] == 200) {
        List<dynamic> dataGet = response["response"];
        courseList.value = dataGet.map((json) => CourseModel.fromJson(json)).toList();
        filterCourses(); // Apply current filters
        print("✅ Loaded ${courseList.length} courses");
      } else {
        print("❌ Failed to load courses: ${response['response']}");
        courseList.clear();
        filteredCourseList.clear();
      }
    } catch (e) {
      print("❌ Error loading courses: $e");
      courseList.clear();
      filteredCourseList.clear();
    }
  }

  Future<void> getAllSubCategory() async {
    try {
      String? token = sharedPrefHelper.getString(SharedPrefHelper.token);
      if (token == null) return;

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      String url = ApiUrl.getAllSubCategory;
      final response = await NetworkService.makeGetRequest(
        url: url,
        headers: headers,
      );

      if (response["statusCode"] == 200) {
        List<dynamic> jsonList = response['response'];
        subCategory.value =
            jsonList.map((e) => SubCategoryModel.fromJson(e)).toList();
      } else {
        print('Error loading Categories: ${response['response']}');
      }
    } catch (e) {
      print("Error loading subcategories: $e");
    }
  }

  void setSelectedSubCategory(int id) {
    selectedSubCategoryId.value = id;
    update(); // Notify GetBuilder
  }

  /// Filter courses based on search query and subcategory
  void filterCourses() {
    List<CourseModel> filtered = courseList.toList();
    
    // Filter by subcategory
    if (selectedSubCategoryId.value != 0) {
      filtered = filtered.where((course) => 
        course.subCategoryId == selectedSubCategoryId.value).toList();
    }
    
    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      String query = searchQuery.value.toLowerCase();
      filtered = filtered.where((course) => 
        course.courseName!.toLowerCase().contains(query) ||
        course.courseDescription!.toLowerCase().contains(query)).toList();
    }
    
    filteredCourseList.value = filtered;
    print("🔍 Filtered courses: ${filteredCourseList.length}");
  }

  /// Update search query
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  /// Refresh all data
  Future<void> refreshData() async {
    isRefreshing.value = true;
    try {
      await Future.wait([
        loadCourse(),
        getAllSubCategory(),
      ]);
    } catch (e) {
      print("❌ Error refreshing data: $e");
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Get course statistics
  Map<String, int> getCourseStats() {
    int totalCourses = courseList.length;
    int enabledCourses = courseList.where((course) => course.enabled == true).length;
    int disabledCourses = totalCourses - enabledCourses;
    
    return {
      'total': totalCourses,
      'enabled': enabledCourses,
      'disabled': disabledCourses,
    };
  }

  Future<bool> courseManage(bool value, int courseId) async {
    try {
      String? token = sharedPrefHelper.getString(SharedPrefHelper.token);
      if (token == null) {
        print("❌ No authentication token");
        return false;
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      String url = ApiUrl.CourseEnableApi;
      final response = await NetworkService.makePatchRequest(
        url: url + courseId.toString() + "/toggle-status",
        headers: headers,
      );

      print("🔄 Toggle Response: $response");

      if (response["statusCode"] == 200) {
        bool newStatus = response['response'];
        
        // Update the course in the local list by creating a new object
        int courseIndex = courseList.indexWhere((course) => course.courseId == courseId);
        if (courseIndex != -1) {
          CourseModel oldCourse = courseList[courseIndex];
          CourseModel updatedCourse = CourseModel(
            courseId: oldCourse.courseId,
            courseName: oldCourse.courseName,
            courseDescription: oldCourse.courseDescription,
            enabled: newStatus, // Update the enabled status
            image: oldCourse.image,
            subCategoryId: oldCourse.subCategoryId,
          );
          
          courseList[courseIndex] = updatedCourse;
          filterCourses(); // Refresh filtered list
        }
        
        print("✅ Course $courseId status updated to: $newStatus");
        return newStatus;
      } else {
        print('❌ Error toggling course status: ${response['response']}');
        return !value; // Return original value on error
      }
    } catch (e) {
      print("❌ Exception in courseManage: $e");
      return !value; // Return original value on error
    }
  }

  /// Delete a course
  Future<bool> deleteCourse(int courseId) async {
    try {
      String? token = sharedPrefHelper.getString(SharedPrefHelper.token);
      if (token == null) return false;

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      // Assuming there's a delete endpoint
      final response = await NetworkService.makeDeleteRequest(
        url: "${ApiUrl.AddCourse}$courseId",
        headers: headers,
      );

      if (response["statusCode"] == 200) {
        // Remove from local list
        courseList.removeWhere((course) => course.courseId == courseId);
        filterCourses();
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Error deleting course: $e");
      return false;
    }
  }
}
