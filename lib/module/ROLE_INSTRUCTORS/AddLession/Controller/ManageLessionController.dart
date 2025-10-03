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
  bool isVideoProcessing = false;
  bool isImageProcessing = false;
  double videoCompressionProgress = 0.0;
  String videoProcessingStatus = '';
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
    try {
      isImageProcessing = true;
      update();
      
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (picked != null) {
        pickedImage = File(picked.path);
        imageUrl = null;
        
        Get.snackbar(
          "Success",
          "Image selected successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
      }
    } catch (e) {
      print("❌ Error picking image: $e");
      Get.snackbar(
        "Error",
        "Failed to pick image: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isImageProcessing = false;
      update();
    }
  }

  Future<void> pickVideo() async {
      try {
      isVideoProcessing = true;
      videoCompressionProgress = 0.0;
      videoProcessingStatus = 'Selecting video...';
      update();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'avi', 'mov', 'mkv'],
      );
      
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileSizeInMB = await file.length() / (1024 * 1024);
        
        print("📹 Selected video size: ${fileSizeInMB.toStringAsFixed(2)} MB");
        
        // Show file size warning if too large
        if (fileSizeInMB > 100) {
          final shouldContinue = await Get.dialog<bool>(
            AlertDialog(
              title: Text('Large Video File'),
              content: Text(
                'The selected video is ${fileSizeInMB.toStringAsFixed(1)} MB. '
                'This may take longer to process and upload. Continue?'
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(result: false),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Get.back(result: true),
                  child: Text('Continue'),
                ),
              ],
            ),
          ) ?? false;
          
          if (!shouldContinue) {
            isVideoProcessing = false;
            update();
            return;
          }
        }

        videoProcessingStatus = 'Compressing video...';
        update();

        // Set up compression progress listener
        VideoCompress.setLogLevel(0);
        
        final subscription = VideoCompress.compressProgress$.subscribe((progress) {
          videoCompressionProgress = progress / 100.0;
          videoProcessingStatus = 'Compressing... ${progress.toStringAsFixed(0)}%';
          update();
        });

        try {
          final info = await VideoCompress.compressVideo(
            result.files.single.path!,
            quality: VideoQuality.MediumQuality,
            deleteOrigin: false,
            includeAudio: true,
          );

          subscription.unsubscribe();

          if (info != null && info.file != null) {
            pickedVideo = info.file;
            videoUrl = null;
            
            final compressedSizeInMB = await info.file!.length() / (1024 * 1024);
            print("📹 Compressed video size: ${compressedSizeInMB.toStringAsFixed(2)} MB");
            
            videoProcessingStatus = 'Video ready!';
            
            Get.snackbar(
              "Success",
              "Video compressed successfully! "
              "Size reduced from ${fileSizeInMB.toStringAsFixed(1)} MB to ${compressedSizeInMB.toStringAsFixed(1)} MB",
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: Duration(seconds: 3),
            );
          } else {
            throw Exception("Video compression failed");
          }
        } catch (e) {
          subscription.unsubscribe();
          throw e;
        }
      }
    } catch (e) {
      print("❌ Error processing video: $e");
      Get.snackbar(
        "Error",
        "Failed to process video: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    } finally {
      isVideoProcessing = false;
      videoCompressionProgress = 0.0;
      videoProcessingStatus = '';
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

      // Prepare lesson JSON data (without file paths)
      Map<String, dynamic> lessonData = {
        'lessonName': lessonName,
        'lessonContent': lessonContent,
        'courseId': courseId,
      };

      if (isEditing) {
        lessonData['lessonId'] = lessionId!;
      }

      print("📦 Lesson Data: $lessonData");

      // Prepare files list
      List<Map<String, dynamic>> files = [];
      
      // Add image file if selected
      if (pickedImage != null) {
        files.add({
          'name': 'image',
          'filePath': pickedImage!.path,
        });
        print("📷 Image file added: ${pickedImage!.path}");
      }
      
      // Add video file if selected
      if (pickedVideo != null) {
        files.add({
          'name': 'video', 
          'filePath': pickedVideo!.path,
        });
        print("🎥 Video file added: ${pickedVideo!.path}");
      }

      print("📁 Total files to upload: ${files.length}");

      dynamic response;

      if (isEditing) {
        response = await NetworkService.makeMultipartPutRequest(
          url: url,
          headers: {
            'Authorization': 'Bearer $token',
            // Don't set Content-Type for multipart requests
          },
          fields: {
            'lesson': jsonEncode(lessonData), // JSON string in lesson field
          },
          files: files,
        );
      } else {
        response = await NetworkService.makeMultipartPostRequest(
          url: url,
          headers: {
            'Authorization': 'Bearer $token',
            // Don't set Content-Type for multipart requests
          },
          fields: {
            'lesson': jsonEncode(lessonData), // JSON string in lesson field
          },
          files: files,
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
          Get.back();
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
