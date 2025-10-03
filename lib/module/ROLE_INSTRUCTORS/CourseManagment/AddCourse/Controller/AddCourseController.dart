import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shaktihub/routes/app_pages.dart';
import '../../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../../../api/listing/api_listing.dart';
import '../../../../../api/url/api_url.dart';
import '../../../../ROLE_ADMIN/Home/model/categoryAllModel.dart';
import '../../../../ROLE_ADMIN/Home/model/subCategoryModel.dart';
import '../../../BottomNavBar/Screen/bottomNavBarinInstructor.dart';
import '../../../Home/Model/CourseModel.dart';

class AddCourseController extends GetxController {
  final CourseModel? course;

  AddCourseController({this.course});

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

  final Rx<File?> selectedImage = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    getAllCategory();
    if (course != null) {
      courseName.text = course!.courseName!.toString();
      courseDescription.text = course!.courseDescription!.toString();
      selectSubCategoryId.value = course!.subCategoryId ?? 0;
    }
    // courseName.text = .isEmpty ? "" : cName;
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
        allCategory =
            jsonList.map((item) => CategoryModel.fromJson(item)).toList();

        /// ✅ If editing, find correct category from subcategory
        if (course != null) {
          await getAllSubCategoryForCourse(course!.subCategoryId!);
        } else if (allCategory.isNotEmpty) {
          // For new course, set default category and load its subcategories
          selectedCategoryId.value = allCategory[0].categoryId;
          await getAllSubCategory(selectedCategoryId.value);
        }

        update();
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
        subCategory =
            jsonList.map((item) => SubCategoryModel.fromJson(item)).toList();
        
        // Only set default subcategory if not in edit mode
        if (course == null && subCategory.isNotEmpty) {
          selectSubCategoryId.value = subCategory[0].subCategoryId;
        }
        
        update();
        print('✅ SubCategories loaded successfully: ${subCategory.length} items');
      } else {
        print('❌ Error loading subcategories: ${response['response']}');
        subCategory = []; // Clear subcategories on error
        selectSubCategoryId.value = 0;
        update();
      }
    } catch (e) {
      print("❌ Exception in getAllSubCategory: $e");
      subCategory = [];
      selectSubCategoryId.value = 0;
      update();
    }
  }

  Future<void> getAllSubCategoryForCourse(int subCategoryId) async {
    for (var category in allCategory) {
      final response = await NetworkService.makeGetRequest(
        url: "${ApiUrl.getAllSubCategoryById}${category.categoryId}",
        headers: {
          'Authorization': 'Bearer ${sh1.getString(SharedPrefHelper.token)}',
          'Accept': 'application/json',
        },
      );

      if (response["statusCode"] == 200) {
        List<dynamic> jsonList = response['response'];
        List<SubCategoryModel> tempSubCats =
            jsonList.map((item) => SubCategoryModel.fromJson(item)).toList();

        if (tempSubCats.any((sub) => sub.subCategoryId == subCategoryId)) {
          selectedCategoryId.value = category.categoryId;
          subCategory = tempSubCats;
          selectSubCategoryId.value = subCategoryId;
          break;
        }
      }
    }

    update();
  }

  Future<void> pickJpegFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg'],
    );

    if (result != null && result.files.single.path != null) {
      String localPath = result.files.single.path!;
      File imageFile = File(localPath);
      selectedImage.value = imageFile; // ✅ Set the image file
      update(); // ✅ Refresh UI
    } else {
      print("⚠️ No image selected");
    }
  }

  void clearImage() {
    selectedImage.value = null;
    update();
  }

  Future<void> ManageCourse() async {
    try {
      uploading.value = true;
      update();

      final token = sh1.getString(SharedPrefHelper.token);
      if (token == null) {
        print("❌ Missing token");
        Get.snackbar("Error", "Authentication token missing",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // Validate required fields
      if (selectedCategoryId.value == 0 || selectSubCategoryId.value == 0) {
        Get.snackbar("Error", "Please select category and subcategory",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      if (courseName.text.trim().isEmpty || courseDescription.text.trim().isEmpty) {
        Get.snackbar("Error", "Please fill all required fields",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      // Check if this is Add or Edit mode
      bool isEditMode = course != null;
      
      // Prepare course data
      Map<String, dynamic> courseData = {
        'courseName': courseName.text.trim(),
        'courseDescription': courseDescription.text.trim(),
        'subCategoryId': selectSubCategoryId.value,
      };

      // Add courseId only for edit mode
      if (isEditMode) {
        courseData['courseId'] = course!.courseId;
        // Keep existing image data if available
        if (course!.image != null) {
          courseData['image'] = course!.image!.toJson();
        }
      }

      // 🔁 File list
      List<Map<String, dynamic>> files = [];

      if (selectedImage.value != null) {
        print("📷 Processing selected image");
        final compressedFile = await compressImage(selectedImage.value!);

        files.add({
          'name': 'file',
          'filePath': compressedFile.path,
        });
      } else if (!isEditMode) {
        // For new courses, we need an image
        Get.snackbar("Error", "Please select an image for the course",
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      } else {
        // For edit mode without new image, create dummy file
        final tempDir = await getTemporaryDirectory();
        final dummyPath = '${tempDir.path}/empty.txt';
        final dummyFile = File(dummyPath);
        if (!dummyFile.existsSync()) {
          dummyFile.writeAsStringSync('');
        }
        files.add({
          'name': 'file',
          'filePath': dummyPath,
        });
      }

      // Choose appropriate API endpoint and method
      Map<String, dynamic> response;
      
      if (isEditMode) {
        // Edit existing course
        response = await NetworkService.makeMultipartPutRequest(
          url: ApiUrl.AddCourse + course!.courseId.toString(),
          headers: {
            'Authorization': 'Bearer $token',
          },
          fields: {
            'course': jsonEncode(courseData),
          },
          files: files,
        );
      } else {
        // Add new course
        response = await NetworkService.makeMultipartPostRequest(
          url: ApiUrl.AddCourse,
          headers: {
            'Authorization': 'Bearer $token',
          },
          fields: {
            'course': jsonEncode(courseData),
          },
          files: files,
        );
      }

      print("📤 API Response: ${response['statusCode']}");

      if (response['statusCode'] == 200 || response['statusCode'] == 201) {
        String successMessage = isEditMode ? "Course updated successfully" : "Course added successfully";
        
        Get.snackbar("Success", successMessage,
            backgroundColor: Colors.green,
            colorText: Colors.white);

        // Navigate back to instructor dashboard
        Get.offAll(() => BottomNavScreen());

      } else {
        print("❌ Response Error: ${response['response']}");
        Get.snackbar("Error", "Failed to ${isEditMode ? 'update' : 'add'} course: ${response['response']}",
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e, stack) {
      print("❌ Exception: $e");
      print("📌 Stacktrace:\n$stack");
      
      Get.snackbar("Error", "An error occurred: ${e.toString()}",
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      uploading.value = false;
      update();
    }
  }

  Future<File> compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = path.join(tempDir.path, 'compressed_${path.basename(file.path)}');

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      quality: 60,
    );

    if (compressedFile != null) {
      return File(compressedFile.path); // Safe return
    } else {
      return file; // Fall back to original file if compression fails
    }
  }

}
