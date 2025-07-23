import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../../../api/listing/api_listing.dart';
import '../../../../../api/url/api_url.dart';
import '../../../../ROLE_ADMIN/Home/model/categoryAllModel.dart';
import '../../../../ROLE_ADMIN/Home/model/subCategoryModel.dart';

class AddCourseController extends GetxController {
  var isLoading = false.obs;
  var uploading = false.obs;

  TextEditingController courseName = TextEditingController();
  TextEditingController courseDescription = TextEditingController();

  SharedPrefHelper sh1 = SharedPrefHelper();

  var selectedCategoryId = 0.obs;
  var selectSubCategoryId = 0.obs;

  RxList<SubCategoryModel> filteredSubCategories = <SubCategoryModel>[].obs;
  List<CategoryModel> allCategory = [];
  List<SubCategoryModel> subCategory = [];

  var showNextPage = false.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    getAllCategory();
  }

  Future<void> getAllCategory() async {
    try {
      final token = sh1.getString(SharedPrefHelper.token);
      if (token == null) throw Exception("Token missing");

      final response = await NetworkService.makeGetRequest(
        url: ApiUrl.gatAllCategory,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response["statusCode"] == 200) {
        List<dynamic> jsonList = response['response'];
        allCategory = jsonList.map((item) => CategoryModel.fromJson(item)).toList();
        selectedCategoryId.value = allCategory[0].categoryId;
        update();
        print('✅ Categories loaded successfully');
      } else {
        print('❌ Error loading categories: ${response['response']}');
      }
    } catch (e) {
      print("❌ Exception in getAllCategory: $e");
    }
  }

  Future<void> getAllSubCategory(int categoryId) async {
    try {
      final token = sh1.getString(SharedPrefHelper.token);
      if (token == null) throw Exception("Token missing");

      final response = await NetworkService.makeGetRequest(
        url: "${ApiUrl.getAllSubCategoryById}$categoryId",
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response["statusCode"] == 200) {
        List<dynamic> jsonList = response['response'];
        subCategory = jsonList.map((item) => SubCategoryModel.fromJson(item)).toList();
        selectSubCategoryId.value = subCategory[0].subCategoryId;
        update();
        print('✅ SubCategories loaded successfully');
      } else {
        print('❌ Error loading subcategories: ${response['response']}');
      }
    } catch (e) {
      print("❌ Exception in getAllSubCategory: $e");
    }
  }

  Future<void> pickJpegFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      String localPath = result.files.single.path!;
      File imageFile = File(localPath);

      print("File Name is " + imageFile.path);
      selectedImage.value = imageFile; // ✅ Set the image file
      update(); // ✅ Refresh UI

      print("📍 Image selected: $localPath");
    } else {
      print("⚠️ No image selected");
    }
  }
  void clearImage() {
    selectedImage.value = null;
    update();
  }





  Future<void> uploadFile() async {
    try {
      uploading.value = true;
      update();

      final token =  sh1.getString(SharedPrefHelper.token);
      if (token == null) {
        print("❌ Missing token");
        return;
      }

      if (selectedImage.value == null) {
        print("❌ No image selected");
        return;
      }

      Map<String,dynamic> CourseData = {
        'courseName': courseName.text.toString().trim(),
        'courseDescription': courseDescription.text.toString().trim(),
        'subCategoryId': selectSubCategoryId.value,
      };

      final response = await NetworkService.makeMultipartPostRequest(
        url: ApiUrl.AddCourse,
        headers: {
          'Authorization': 'Bearer $token',
        },
        fields: {
          'course': jsonEncode(CourseData),
        },
        files: [
          {
            'name': 'file',
            'filePath': selectedImage.value!.path,
          },
        ],
      );

      print("Response is $response");

      if (response['statusCode'] == 200) {
        Get.snackbar("Success", "Course uploaded successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        uploading.value = false;
        update();

        Get.snackbar("Error", response['response'].toString(),
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e, stack) {
      uploading.value = false;
      update();
      print("Exception occurred: $e");
      print(" Stacktrace:\n$stack");
    }
  }






  void goToNextPage() {
    showNextPage.value = true;
    update();
  }

  void goBack() {
    showNextPage.value = false;
    update();
  }
}
