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

  // Loading states for different operations
  var isLoadingCategories = false.obs;
  var isLoadingSubCategories = false.obs;
  var isUploading = false.obs;
  var isProcessingImage = false.obs;
  
  // Error states
  var hasError = false.obs;
  var errorMessage = ''.obs;

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
    _initializeData();
  }

  void _initializeData() {
    try {
      if (course != null) {
        courseName.text = course!.courseName?.toString() ?? '';
        courseDescription.text = course!.courseDescription?.toString() ?? '';
        selectSubCategoryId.value = course!.subCategoryId ?? 0;
      }
      getAllCategory();
    } catch (e) {
      _handleError('Failed to initialize course data: $e');
    }
  }

  void _handleError(String message) {
    hasError.value = true;
    errorMessage.value = message;
    print('❌ Error: $message');
  }

  void _clearError() {
    hasError.value = false;
    errorMessage.value = '';
  }

  Future<void> getAllCategory() async {
    try {
      _clearError();
      isLoadingCategories.value = true;
      update();

      final token = sh1.getString(SharedPrefHelper.token);
      if (token == null || token.isEmpty) {
        throw Exception("Authentication token is missing. Please login again.");
      }

      final response = await NetworkService.makeGetRequest(
        url: ApiUrl.gatAllCategory,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response["statusCode"] == 200) {
        List<dynamic> jsonList = response['response'];
        if (jsonList.isEmpty) {
          throw Exception("No categories available. Please contact administrator.");
        }
        
        allCategory = jsonList.map((item) => CategoryModel.fromJson(item)).toList();
        print('✅ Categories loaded successfully: ${allCategory.length} items');

        // Handle course initialization
        if (course != null) {
          await getAllSubCategoryForCourse(course!.subCategoryId!);
        } else if (allCategory.isNotEmpty) {
          selectedCategoryId.value = allCategory[0].categoryId;
          await getAllSubCategory(selectedCategoryId.value);
        }
      } else {
        String errorMsg = response['response']?.toString() ?? 'Unknown error';
        throw Exception("Failed to load categories: $errorMsg");
      }
    } catch (e) {
      _handleError('Failed to load categories: ${e.toString()}');
      Get.snackbar(
        "Error", 
        "Failed to load categories. Please check your internet connection and try again.",
        backgroundColor: Colors.red, 
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isLoadingCategories.value = false;
      update();
    }
  }

  Future<void> getAllSubCategory(int categoryId) async {
    try {
      isLoadingSubCategories.value = true;
      update();

      final token = sh1.getString(SharedPrefHelper.token);
      if (token == null || token.isEmpty) {
        throw Exception("Authentication token is missing. Please login again.");
      }

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
        
        // Only set default subcategory if not in edit mode
        if (course == null && subCategory.isNotEmpty) {
          selectSubCategoryId.value = subCategory[0].subCategoryId;
        } else if (subCategory.isEmpty) {
          selectSubCategoryId.value = 0;
          Get.snackbar(
            "Info", 
            "No subcategories available for this category.",
            backgroundColor: Colors.orange, 
            colorText: Colors.white,
          );
        }
        
        print('✅ SubCategories loaded successfully: ${subCategory.length} items');
      } else {
        String errorMsg = response['response']?.toString() ?? 'Unknown error';
        throw Exception("Failed to load subcategories: $errorMsg");
      }
    } catch (e) {
      _handleError('Failed to load subcategories: ${e.toString()}');
      subCategory = [];
      selectSubCategoryId.value = 0;
      Get.snackbar(
        "Error", 
        "Failed to load subcategories. Please try again.",
        backgroundColor: Colors.red, 
        colorText: Colors.white,
      );
    } finally {
      isLoadingSubCategories.value = false;
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
    try {
      isProcessingImage.value = true;
      update();

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        String localPath = result.files.single.path!;
        File imageFile = File(localPath);
        
        // Validate file size (max 10MB)
        int fileSizeInBytes = await imageFile.length();
        double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
        
        if (fileSizeInMB > 10) {
          Get.snackbar(
            "Error", 
            "Image size should be less than 10MB. Current size: ${fileSizeInMB.toStringAsFixed(2)}MB",
            backgroundColor: Colors.red, 
            colorText: Colors.white,
          );
          return;
        }
        
        selectedImage.value = imageFile;
        _clearError();
        Get.snackbar(
          "Success", 
          "Image selected successfully",
          backgroundColor: Colors.green, 
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      } else {
        print("⚠️ No image selected");
      }
    } catch (e) {
      _handleError('Failed to select image: ${e.toString()}');
      Get.snackbar(
        "Error", 
        "Failed to select image. Please try again.",
        backgroundColor: Colors.red, 
        colorText: Colors.white,
      );
    } finally {
      isProcessingImage.value = false;
      update();
    }
  }

  void clearImage() {
    selectedImage.value = null;
    update();
  }

  // Validation methods
  bool _validateForm() {
    _clearError();
    
    // Validate course name
    if (courseName.text.trim().isEmpty) {
      _handleError('Course name is required');
      Get.snackbar("Validation Error", "Please enter a course name",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    
    if (courseName.text.trim().length < 3) {
      _handleError('Course name must be at least 3 characters');
      Get.snackbar("Validation Error", "Course name must be at least 3 characters",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    // Validate course description
    if (courseDescription.text.trim().isEmpty) {
      _handleError('Course description is required');
      Get.snackbar("Validation Error", "Please enter a course description",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
    
    if (courseDescription.text.trim().length < 10) {
      _handleError('Course description must be at least 10 characters');
      Get.snackbar("Validation Error", "Course description must be at least 10 characters",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    // Validate category selection
    if (selectedCategoryId.value == 0) {
      _handleError('Please select a category');
      Get.snackbar("Validation Error", "Please select a category",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    // Validate subcategory selection
    if (selectSubCategoryId.value == 0) {
      _handleError('Please select a subcategory');
      Get.snackbar("Validation Error", "Please select a subcategory",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    // Validate image for new courses
    if (course == null && selectedImage.value == null) {
      _handleError('Please select an image for the course');
      Get.snackbar("Validation Error", "Please select an image for the course",
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }

    return true;
  }

  Future<void> ManageCourse() async {
    try {
      // Validate form before proceeding
      if (!_validateForm()) {
        return;
      }

      isUploading.value = true;
      update();

      final token = sh1.getString(SharedPrefHelper.token);
      if (token == null || token.isEmpty) {
        throw Exception("Authentication token is missing. Please login again.");
      }

      // Check if this is Add or Edit mode
      bool isEditMode = course != null;
      
      // Prepare course data with validation
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
        try {
          final compressedFile = await compressImage(selectedImage.value!);
          files.add({
            'name': 'file',
            'filePath': compressedFile.path,
          });
        } catch (e) {
          throw Exception("Failed to process image: ${e.toString()}");
        }
      } else if (!isEditMode) {
        // For new courses, we need an image
        throw Exception("Please select an image for the course");
      } else {
        // For edit mode without new image, create dummy file
        try {
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
        } catch (e) {
          throw Exception("Failed to prepare file data: ${e.toString()}");
        }
      }

      // Choose appropriate API endpoint and method
      Map<String, dynamic> response;
      
      if (isEditMode) {
        // Edit existing course
        response = await NetworkService.makeMultipartPutRequest(
          url: ApiUrl.AddCourse + course!.courseId.toString(),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
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
            'Accept': 'application/json',
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
        
        Get.snackbar(
          "Success", 
          successMessage,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );

        // Navigate back to instructor dashboard
        Get.offAll(() => BottomNavScreen());

      } else {
        String errorMsg = response['response']?.toString() ?? 'Unknown error occurred';
        throw Exception("API Error: $errorMsg");
      }
    } catch (e) {
      String errorMessage = e.toString();
      
      // Handle specific error types
      if (errorMessage.contains('SocketException') || errorMessage.contains('NetworkException')) {
        errorMessage = "Network error. Please check your internet connection and try again.";
      } else if (errorMessage.contains('TimeoutException')) {
        errorMessage = "Request timeout. Please try again.";
      } else if (errorMessage.contains('FormatException')) {
        errorMessage = "Invalid data format. Please try again.";
      }
      
      _handleError(errorMessage);
      
      Get.snackbar(
        "Error", 
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isUploading.value = false;
      update();
    }
  }

  Future<File> compressImage(File file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(tempDir.path, 'compressed_${path.basename(file.path)}');

      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: 60,
        minWidth: 300,
        minHeight: 300,
      );

      if (compressedFile != null) {
        return File(compressedFile.path);
      } else {
        throw Exception("Image compression failed");
      }
    } catch (e) {
      print("⚠️ Image compression failed, using original: $e");
      return file; // Fall back to original file if compression fails
    }
  }

}
