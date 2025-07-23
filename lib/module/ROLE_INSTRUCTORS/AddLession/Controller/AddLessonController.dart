import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../../api/listing/api_listing.dart';
import '../../../../api/url/api_url.dart';

class AddLessonController extends GetxController {
  final lessonName = ''.obs;
  final lessonContent = ''.obs;
  final isEnabled = true.obs;
  final pickedImage = Rx<File?>(null);
  final pickedVideo = Rx<File?>(null);

  int courseId;

  SharedPrefHelper sh1 = SharedPrefHelper();


  AddLessonController({required this.courseId});


  void toggleEnabled(bool value) {
    isEnabled.value = value;
  }

  void setLessonName(String value) {
    lessonName.value = value;
  }

  void setLessonContent(String value) {
    lessonContent.value = value;
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      pickedImage.value = File(picked.path);
    }
  }

  Future<void> pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      pickedVideo.value = File(result.files.single.path!);
    }
  }

  Future<void> submitLesson() async {
    print("Course ID: $courseId");
    print("Lesson Name: ${lessonName.value}");
    print("Lesson Content: ${lessonContent.value}");
    print("Is Enabled: ${isEnabled.value}");
    print("Image: ${pickedImage.value?.path}");
    print("Video: ${pickedVideo.value?.path}");
    try {
      // addLession
      String url = ApiUrl.addLession;
      String? token = sh1.getString(SharedPrefHelper.token);
      print("Token is " + token.toString());
      Map<String,dynamic> CourseData = {
        'lessonName': lessonName.value.trim().toString(),
        'lessonContent': lessonContent.value.toString().trim(),
        'courseId': courseId,
      };


      print(jsonEncode(CourseData));

      final response = await NetworkService.makeMultipartPostRequest(url: url,
      headers:  {
          'Authorization': 'Bearer $token',
          },
        fields: {
          'lesson': jsonEncode(CourseData),
        },
        files: [
          {
            'name': 'image',
            'filePath': pickedImage.value!.path,
          },
          {
            'name': 'video',
            'filePath': pickedVideo.value!.path,
          },
        ],

      );

      print("Response is " + response['statusCode']);

      if (response['statusCode'] == 200) {
        Get.snackbar("Success", "Course uploaded successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        update();
        Get.snackbar("Error", response['response'].toString(),
            backgroundColor: Colors.red, colorText: Colors.white);
      }


    } catch (e) {
      print("Error is $e");
    }

    // TODO: Add your API call or data handling logic here
  }
}
