import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          'Authorization': 'Bearer $token',
        },
      );

      lesson.value = Lesson.fromJson(response["response"]);

      if (lesson.value?.video.videoId != null) {
        await _loadVideoFromUrl(lesson.value!.video.videoId!);
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadVideoFromUrl(int videoId) async {
    String videoUrl = "${ApiUrl.getStremeUsingRange}$videoId";
    String? token = sh1.getString(SharedPrefHelper.token);

    videoController = VideoPlayerController.network(
      videoUrl,
      httpHeaders: {
        'Authorization': 'Bearer $token',
      },
    );

    await videoController!.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoController!,
      autoPlay: false,
      looping: false,
    );

    isVideoReady.value = true;
  }

  @override
  void onClose() {
    videoController?.dispose();
    chewieController?.dispose();
    super.onClose();
  }

  Future<void> deleteLession(int lessonId) async {
    try {
      String url = ApiUrl.lessionDelete + lessonId.toString();
      final response = await NetworkService.makeDeleteRequest(url: url);
      print("response is ${response['statusCode'].toString()}");
    } catch (e) {
      print("Error is ${e.toString()}");
    }
  }
}
