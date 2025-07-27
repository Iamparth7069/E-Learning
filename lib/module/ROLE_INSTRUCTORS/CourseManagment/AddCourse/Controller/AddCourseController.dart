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
        } else {
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
      }

      // Prepare course data
      Map<String, dynamic> courseUpdateData = {
        'courseId': course!.courseId,
        'courseName': courseName.text.trim(),
        'courseDescription': courseDescription.text.trim(),
        'subCategoryId': selectSubCategoryId.value,
        'image': course!.image?.toJson(), // if available
      };

      // 🔁 File list
      List<Map<String, dynamic>> files = [];

      if (selectedImage.value != null) {
        print("Pick the File in Database");
        final compressedFile = await compressImage(selectedImage.value!);

        // ✅ User picked new image
        files.add({
          'name': 'file',
          'filePath': compressedFile.path,
        });

      } else {

        final tempDir = await getTemporaryDirectory();
        final dummyPath = '${tempDir.path}/empty.txt';
        final dummyFile = File(dummyPath);
        if (!dummyFile.existsSync()) {
          dummyFile.writeAsStringSync(''); // create an empty file
        }
        files.add({
          'name': 'file',
          'filePath': dummyPath,
        });
      }

      final response = await NetworkService.makeMultipartPutRequest(
        url: ApiUrl.AddCourse + course!.courseId.toString(),
        headers: {
          'Authorization': 'Bearer $token',
        },
        fields: {
          'course': jsonEncode(courseUpdateData),
        },
        files: files,
      );

      if (response['statusCode'] == 200) {
        Get.snackbar("Success", "Lesson saved",
            backgroundColor: Colors.green,
            colorText: Colors.white);

        if (response['statusCode'] == 200) {
          Get.snackbar("Success", "Lesson saved",
              backgroundColor: Colors.green,
              colorText: Colors.white);

         Get.offAll(() => BottomNavScreen());

        }
      } else {
        print("❌ Response Error:");
        Get.snackbar("Error", "Something went wrong",
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e, stack) {
      print("❌ Exception: $e");
      print("📌 Stacktrace:\n$stack");
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
