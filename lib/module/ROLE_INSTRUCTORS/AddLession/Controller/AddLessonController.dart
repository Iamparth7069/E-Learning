import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../../api/listing/api_listing.dart';
import '../../../../api/url/api_url.dart';

class AddLessonController extends GetxController {
  String lessonName = '';
  String lessonContent = '';
  bool isEnabled = true;
  File? pickedImage;
  File? pickedVideo;
  bool isLoading = false;

  final int courseId;
  SharedPrefHelper sh1 = SharedPrefHelper();

  AddLessonController({required this.courseId});

  void toggleEnabled(bool value) {
    isEnabled = value;
    update();
  }

  void setLessonName(String value) {
    lessonName = value;
    update();
  }

  void setLessonContent(String value) {
    lessonContent = value;
    update();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      pickedImage = File(picked.path);
      update();
    }
  }

  Future<void> pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      pickedVideo = File(result.files.single.path!);
      update();
    }
  }

  Future<bool> submitLesson() async {
    isLoading = true;
    update();

    String url = ApiUrl.addLession;
    String? token = sh1.getString(SharedPrefHelper.token);

    Map<String, dynamic> courseData = {
      'lessonName': lessonName.trim(),
      'lessonContent': lessonContent.trim(),
      'courseId': courseId,
    };

    final response = await NetworkService.makeMultipartPostRequest(
      url: url,
      headers: {
        'Authorization': 'Bearer $token',
      },
      fields: {
        'lesson': jsonEncode(courseData),
      },
      files: [
        {
          'name': 'image',
          'filePath': pickedImage!.path,
        },
        {
          'name': 'video',
          'filePath': pickedVideo!.path,
        },
      ],
    );

    isLoading = false;
    update();

    if (response['statusCode'] == 200) {
      Get.snackbar("Success", "Course uploaded successfully",
          backgroundColor: Colors.green, colorText: Colors.white);
      return true;
    } else {
      Get.snackbar("Error", response['response'].toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
      return false;
    }
  }
}
