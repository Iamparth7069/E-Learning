import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../api/listing/api_listing.dart';
import '../../../../api/url/api_url.dart';
import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../ROLE_ADMIN/Home/model/categoryAllModel.dart';

class CategoryController extends GetxController {
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  
  List<CategoryModel> categories = [];
  
  SharedPrefHelper sharedPrefHelper = SharedPrefHelper();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
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
        url: ApiUrl.gatAllCategory,
        headers: headers,
      );

      isLoading.value = false;

      if (response["statusCode"] == 200) {
        List<dynamic> jsonList = response['response'];
        categories = jsonList.map((item) => CategoryModel.fromJson(item)).toList();
        update();
        print('Categories loaded successfully: ${categories.length}');
      } else {
        hasError.value = true;
        errorMessage.value = response["response"]?.toString() ?? 'Failed to load categories';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = 'An unexpected error occurred: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
    }
  }

  Future<void> refreshCategories() async {
    await fetchCategories();
  }

  void onCategoryTap(CategoryModel category) {
    // Navigate to SubCategoryScreen with category details
    Get.toNamed('/sub-category', arguments: {
      'categoryId': category.categoryId,
      'categoryName': category.name,
    });
  }
}
