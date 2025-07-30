import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shaktihub/module/ROLE_INSTRUCTORS/showAllLession/model/lesson_model.dart';
import 'package:video_compress/video_compress.dart';

import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../../api/listing/api_listing.dart';
import '../../../../api/url/api_url.dart';

class ManageLessionController extends GetxController {
  String lessonName = '';
  String lessonContent = '';
  bool isEnabled = true;
  File? pickedImage;
  File? pickedVideo;
  String? imageUrl;  // 👈 existing image URL
  String? videoUrl;  // 👈 existing video URL
  bool isLoading = false;
  int? lessionId;

  final int courseId;
  final Lesson? lession;

  SharedPrefHelper sh1 = SharedPrefHelper();

  ManageLessionController({required this.courseId, this.lession}) {
    if (lession != null) {
      lessionId = lession!.lessonId;

      lessonName = lession!.lessonName ?? '';
      lessonContent = lession!.lessonContent ?? '';
      isEnabled =  true;
      imageUrl = lession!.image.imageUrl ?? '';   // 🖼️ load from server
      videoUrl = lession!.video.videoUrl ?? '';   // 📼 load from server
    }
  }

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
      imageUrl = null;
      update();
    }
  }

  Future<void> pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null && result.files.single.path != null) {
      final info = await VideoCompress.compressVideo(
        result.files.single.path!,
        quality: VideoQuality.MediumQuality,
        deleteOrigin: false,
      );

      pickedVideo = info?.file;
      videoUrl = null;
      update();
    }
  }

  Future<bool> submitLesson() async {
    isLoading = true;
    update();

    try {
      final token = sh1.getString(SharedPrefHelper.token);
      final isEditing = lession != null;

      String url = isEditing
          ? "${ApiUrl.updateLession}$lessionId"
          : ApiUrl.addLession;

      print("➡️ URL: $url");

      Map<String, dynamic> bodyData = {
        'lessonName': lessonName,
        'lessonContent': lessonContent,
        'courseId': courseId,
      };

      if (isEditing) {
        bodyData['lessonId'] = lessionId!;
      }

      if (pickedImage != null) {
        bodyData['image'] = pickedImage!.path;
      }

      if (pickedVideo != null) {
        bodyData['video'] = pickedVideo!.path;
      }

      print("📦 Final Body: $bodyData");

      dynamic response;

      if (isEditing) {
        response = await NetworkService.makeMultipartPutRequest(
          url: url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          fields: {'lesson': jsonEncode(bodyData)},
          files: [
            if (pickedImage != null)
              {'name': 'image', 'filePath': pickedImage!.path},
            if (pickedVideo != null)
              {'name': 'video', 'filePath': pickedVideo!.path},
          ],
        );
      } else {
        response = await NetworkService.makeMultipartPostRequest(
          url: url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          fields: {'lesson': jsonEncode(bodyData)},
          files: [
            if (pickedImage != null)
              {'name': 'image', 'filePath': pickedImage!.path},
            if (pickedVideo != null)
              {'name': 'video', 'filePath': pickedVideo!.path},
          ],
        );
      }

      print("✅ Response Status Code: ${response['statusCode']}");

      if (response['statusCode'] == 200) {
        Get.snackbar(
          "Success",
          "Lesson saved successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Future.delayed(const Duration(milliseconds: 800), () {
          Get.back(result: bodyData);
        });

        return true;
      } else {
        Get.snackbar(
          "Error",
          "Failed to save lesson",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      print("❌ Exception occurred: $e");
      Get.snackbar(
        "Exception",
        "Something went wrong: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }

}
