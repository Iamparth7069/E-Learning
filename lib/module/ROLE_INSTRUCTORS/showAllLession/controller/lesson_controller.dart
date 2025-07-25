import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../../api/listing/api_listing.dart';
import '../../../../api/url/api_url.dart';
import '../model/lesson_model.dart';

class LessonController extends GetxController {
  Rxn<Lesson> lesson = Rxn<Lesson>();
  RxBool isLoading = false.obs;

  VideoPlayerController? videoController;
  ChewieController? chewieController;

  RxBool isVideoReady = false.obs;

  final SharedPrefHelper sh1 = SharedPrefHelper();

  Future<void> fetchLessonDetail(int lessonId) async {
    try {
      isLoading.value = true;
      isVideoReady.value = false;

      String url = ApiUrl.getLessionDetails + lessonId.toString();
      String? token = sh1.getString(SharedPrefHelper.token);

      final response = await NetworkService.makeGetRequest(
        url: url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      lesson.value = Lesson.fromJson(response["response"]);

      if (lesson.value?.video.videoId != null) {
        await _loadVideoFromBytes(lesson.value!.video.videoId!);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadVideoFromBytes(int videoId) async {
    String byteUrl = "${ApiUrl.getStremeUrl}$videoId";
    String? token = sh1.getString(SharedPrefHelper.token);

    final response = await http.get(
      Uri.parse(byteUrl),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      Uint8List bytes = response.bodyBytes;

      final tempDir = await getTemporaryDirectory();
      final file = File("${tempDir.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4");
      await file.writeAsBytes(bytes);

      videoController = VideoPlayerController.file(file);
      await videoController!.initialize();

      chewieController = ChewieController(
        videoPlayerController: videoController!,
        autoPlay: false,
        looping: false,
      );

      isVideoReady.value = true;
    } else {
      Get.snackbar("Error", "Failed to load video.");
    }
  }

  @override
  void onClose() {
    videoController?.dispose();
    chewieController?.dispose();
    super.onClose();
  }

  void deleteLession(int lessonId) {
      try{

      }catch(e){
        print("Error is ${e.toString()}");

      }
  }
}
