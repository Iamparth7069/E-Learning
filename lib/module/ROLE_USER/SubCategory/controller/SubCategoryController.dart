import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../api/listing/api_listing.dart';
import '../../../../api/url/api_url.dart';
import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../ROLE_ADMIN/Home/model/subCategoryModel.dart';

class SubCategoryController extends GetxController {
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  
  List<SubCategoryModel> subCategories = <SubCategoryModel>[].obs;
  var categoryId = 0.obs;
  var categoryName = ''.obs;
  
  SharedPrefHelper sharedPrefHelper = SharedPrefHelper();

  @override
  void onInit() {
    super.onInit();
    // Get categoryId from arguments
    if (Get.arguments != null) {
      categoryId.value = Get.arguments['categoryId'] ?? 0;
      categoryName.value = Get.arguments['categoryName'] ?? '';
    }
    if (categoryId.value > 0) {
      fetchSubCategories();
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

  Future<void> fetchSubCategories() async {
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
        url: '${ApiUrl.getAllSubCategoryById}${categoryId.value}',
        headers: headers,
      );

      isLoading.value = false;

      if (response["statusCode"] == 200) {
        List<dynamic> jsonList = response['response'];
        subCategories.assignAll(jsonList.map((item) => SubCategoryModel.fromJson(item)).toList());
        print('SubCategories loaded successfully: ${subCategories.length}');
      } else {
        hasError.value = true;
        errorMessage.value = response["response"]?.toString() ?? 'Failed to load subcategories';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = 'An unexpected error occurred: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
    }
  }

  Future<void> refreshSubCategories() async {
    await fetchSubCategories();
  }

  void onSubCategoryTap(SubCategoryModel subCategory) {
    // Navigate to CourseScreen with subcategory details
    Get.toNamed('/course', arguments: {
      'subCategoryId': subCategory.subCategoryId,
      'subCategoryName': subCategory.name,
    });
  }
}
