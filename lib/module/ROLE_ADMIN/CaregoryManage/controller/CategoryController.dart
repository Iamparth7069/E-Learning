import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shaktihub/module/ROLE_ADMIN/Home/model/categoryAllModel.dart';
import 'package:shaktihub/routes/app_pages.dart';

import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../../api/listing/api_listing.dart';
import '../../../../api/url/api_url.dart';
import '../../Home/model/subCategoryModel.dart';

class CategoryController extends GetxController{

  var isLoading = false.obs;
  TextEditingController catgoryController = TextEditingController();
  TextEditingController subCategoryController = TextEditingController();
  TextEditingController updateCategoryController  = TextEditingController();

  SharedPrefHelper sh1 = SharedPrefHelper();
  var selectedCategoryId = RxInt(0);
  var selectSubCategoryId = RxInt(0);
  RxList<SubCategoryModel> filteredSubCategories = <SubCategoryModel>[].obs;



  List<SubCategoryModel> subCategory = [];


  List<CategoryModel> allCategory = [];

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getAllCategory();
  }

  Future<void> addCategory(BuildContext context) async {
    if (catgoryController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a category name');
      return;
    }
    isLoading.value = true;
    String? token = sh1.getString(SharedPrefHelper.token);


    if (token == null) {
      Get.snackbar('Error', 'User not authenticated');
      isLoading.value = false;
      return;
    }
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    Map<String, dynamic> body = {"name": catgoryController.text.trim()};

    final response = await NetworkService.makePostRequest(
      url: ApiUrl.addCategory,
      headers: headers,
      body: body,
    );

    isLoading.value = false;

    if (response["statusCode"] == 200) {
      catgoryController.clear();
      Get.snackbar('Success', 'Category added successfully');
      if (Scaffold
          .of(context)
          .isDrawerOpen) {
        Navigator.of(context).pop();
        Get.back();
      }
      Get.offAllNamed('/home');
    } else {
      Get.snackbar('Error', 'Failed to add. ${response["response"]}');
    }
  }




  Future getAllCategory() async{
    String? token = sh1.getString(SharedPrefHelper.token);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final response = await NetworkService.makeGetRequest(
      url: ApiUrl.gatAllCategory,
      headers: headers,
    );

    print("statusCodestatusCodee " + response["statusCode"].toString());

    if (response["statusCode"] == 200) {
      List<dynamic> jsonList = response['response']; // parses the array
      allCategory = jsonList.map((item) => CategoryModel.fromJson(item)).toList();
      selectedCategoryId.value = allCategory[0].categoryId;
      update();
      print("Call Category " + allCategory.length.toString());

      print('Categories loaded successfully');
    } else {
      print('Error loading Categories: ${response['response']}');
    }
  }




  Future<void> addSubCategory(BuildContext context) async {
    String? token = sh1.getString(SharedPrefHelper.token);


    if(token != null){

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };


      Map<String, dynamic> body =
      {"name": subCategoryController.text.trim(),
      "categoryId" : selectedCategoryId.value
      };


      final response = await NetworkService.makePostRequest(
        url: ApiUrl.addSubCategoryId,
        headers: headers,
        body: body,
      );


      if (response["statusCode"] == 200) {
        subCategoryController.clear();
        Get.snackbar('Success', 'Category added successfully');
        dispose();
        Get.offAllNamed(Routes.AdminDeskBoard);


      } else {
        Get.snackbar('Error', 'Failed to add. ${response["response"]}');
      }

    }else{
      Get.snackbar('Token Error ', 'Invalid User Please Login First');
    }

  }


  Future<void> updateCategory() async {
    String? token = sh1.getString(SharedPrefHelper.token);

    if (token == null || token.isEmpty) {
      Get.snackbar('Token Error', 'Invalid user. Please login first.');
      return;
    }

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Map<String, dynamic> body = {
      "name": updateCategoryController.text.trim(),
      "categoryId": selectedCategoryId.value,
    };

    final String url = "${ApiUrl.updateCategory}${selectedCategoryId.value}";
    print("URL: $url");
    print("Headers: $headers");
    print("Body: $body");


    final response = await NetworkService.makePutRequest(
      url: url,
      headers: headers,
      body: body,
    );

    final int statusCode = response["statusCode"] ?? 0;
    final dynamic resBody = response["response"];

    if (statusCode == 200) {
      updateCategoryController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Success', 'Category updated successfully');
        Get.offAllNamed(Routes.AdminDeskBoard);
      });
    } else if (statusCode == 401) {
      Get.snackbar('Unauthorized', 'Session expired or invalid token.');
    } else {
      Get.snackbar('Error', 'Failed to update category: ${resBody ?? 'No response'}');
    }
  }


  Future<void> updateSubCategory() async {
    String? token = sh1.getString(SharedPrefHelper.token);

    if (token == null || token.isEmpty) {
      Get.snackbar('Token Error', 'Invalid user. Please login first.');
      return;
    }

    if (updateCategoryController.text.trim().isEmpty ||
        selectSubCategoryId.value == 0) {
      Get.snackbar('Validation Error', 'Please select and enter a name.');
      return;
    }

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    Map<String, dynamic> body = {
      "name": updateCategoryController.text.trim(),
      "categoryId": selectedCategoryId.value,
      "subCategoryId": selectSubCategoryId.value
    };

    final String url = "${ApiUrl.updateSubCategory}${selectSubCategoryId.value}";
    print("Updating SubCategory: $url");

    final response = await NetworkService.makePutRequest(
      url: url,
      headers: headers,
      body: body,
    );

    final int statusCode = response["statusCode"] ?? 0;
    final dynamic resBody = response["response"];

    if (statusCode == 200) {
      updateCategoryController.clear();
      Get.snackbar('Success', 'SubCategory updated successfully');
      Get.offAllNamed(Routes.AdminDeskBoard,arguments: 0);
    } else {
      Get.snackbar('Error', 'Failed to update: ${resBody ?? 'Unknown error'}');
    }
  }



   Future getAllSubCategory(int index) async{
    String? token = sh1.getString(SharedPrefHelper.token);
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final response = await NetworkService.makeGetRequest(
      url: ApiUrl.getAllSubCategoryById + index.toString(),
      headers: headers,
    );

    print("statusCodestatusCodee " + response["statusCode"].toString());

    if (response["statusCode"] == 200) {
      List<dynamic> jsonList = response['response']; // parses the array
      subCategory = jsonList.map((item) => SubCategoryModel.fromJson(item)).toList();
      selectSubCategoryId.value = subCategory[0].subCategoryId;

      print('Categories loaded successfully');
      update();
    } else {
      print('Error loading Categories: ${response['response']}');
    }
  }

  void filterSubCategoriesByCategory(int newId) {
    filteredSubCategories.value =
        subCategory.where((item) => item.categoryId == newId).toList();
  }
}
