

import 'package:get/get.dart';
import 'package:shaktihub/SharedPrefrance/SharedPrefrance_helper.dart';
import 'package:shaktihub/api/url/api_url.dart';
import '../../../../api/listing/api_listing.dart';
import '../../../ROLE_ADMIN/Home/model/subCategoryModel.dart';
import '../Model/CourseModel.dart';

class HomeScreenInstructorController extends GetxController {
  var selectedSubCategoryId = 0.obs;

  RxList<CourseModel> courseList = <CourseModel>[].obs;
  RxList<SubCategoryModel> subCategory = <SubCategoryModel>[].obs;
  RxString userName = ''.obs;
  RxBool isLoading = false.obs;

  SharedPrefHelper sharedPrefHelper = SharedPrefHelper();

  @override
  void onInit() {
    super.onInit();
    loadData();
    getAllSubCategory();
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
      if (token == null) return;

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      String url = ApiUrl.getAllCourse;
      final response = await NetworkService.makeGetRequest(
        url: url,
        headers: headers,
      );

      print("Response is $response");

      List<dynamic> dataGet = response["response"];
      courseList.value =
          dataGet.map((json) => CourseModel.fromJson(json)).toList();
    } catch (e) {
      print("Error is $e");
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

  Future<bool> courseManage(bool value, int courseId) async {
    try {
      String? token = sharedPrefHelper.getString(SharedPrefHelper.token);
      if (token == null) return false;

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      String url = ApiUrl.CourseEnableApi;
      final response = await NetworkService.makePatchRequest(
        url: url + courseId.toString() + "/toggle-status",
        headers: headers,
      );

      if (response["statusCode"] == 200) {
        bool val  = response['response'];
        return val;

      } else {
        print('Error loading Categories: ${response['response']}');
        return false;
      }
    } catch (e) {
      print("Error loading subcategories: $e");
    }
    return false;

  }

}
