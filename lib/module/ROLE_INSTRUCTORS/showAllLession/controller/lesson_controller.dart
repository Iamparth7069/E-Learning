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
  RxBool isVideoLoading = false.obs;
  RxBool isDeleting = false.obs;
  RxString videoError = ''.obs;

  VideoPlayerController? videoController;
  ChewieController? chewieController;

  RxBool isVideoReady = false.obs;
  RxBool isVideoPlaying = false.obs;
  RxDouble videoProgress = 0.0.obs;

  final SharedPrefHelper sh1 = SharedPrefHelper();

  Future<void> fetchLessonDetail(int lessonId) async {
    try {
      isLoading.value = true;
      isVideoReady.value = false;
      videoError.value = '';

      String url = ApiUrl.getLessionDetails + lessonId.toString();
      String? token = sh1.getString(SharedPrefHelper.token);

      print("🔍 Fetching lesson details from: $url");

      final response = await NetworkService.makeGetRequest(
        url: url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("📊 Lesson Response: ${response["response"]}");

      if (response["statusCode"] == 200) {
        lesson.value = Lesson.fromJson(response["response"]);
        print("✅ Lesson loaded: ${lesson.value?.lessonName}");

        // Load video if available
        if (lesson.value?.video.videoId != null) {
          await _loadVideoFromUrl(lesson.value!.video.videoId!);
        } else {
          print("⚠️ No video found for this lesson");
        }
      } else {
        throw Exception("Failed to load lesson: ${response["response"]}");
      }
    } catch (e) {
      print("❌ Error fetching lesson: $e");
      Get.snackbar(
        "Error", 
        "Failed to load lesson: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadVideoFromUrl(int videoId) async {
    try {
      isVideoLoading.value = true;
      videoError.value = '';
      
      // Using the correct endpoint: videos/stream/:videoId
      String videoUrl = "${ApiUrl.baseUrl}/videos/stream/$videoId";
      String? token = sh1.getString(SharedPrefHelper.token);

      print("🎥 Loading video from: $videoUrl");

      // Dispose previous controllers
      await _disposeVideoControllers();

      videoController = VideoPlayerController.network(
        videoUrl,
        httpHeaders: {
          'Authorization': 'Bearer $token',
        },
      );

      await videoController!.initialize();

      // Add listeners for video progress
      videoController!.addListener(_videoListener);

      chewieController = ChewieController(
        videoPlayerController: videoController!,
        autoPlay: false,
        looping: false,
        showControlsOnInitialize: false,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.blueAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightBlue,
        ),
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 60),
                  SizedBox(height: 16),
                  Text(
                    "Video Error",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );

      isVideoReady.value = true;
      print("✅ Video loaded successfully");

    } catch (e) {
      print("❌ Error loading video: $e");
      videoError.value = e.toString();
      Get.snackbar(
        "Video Error",
        "Failed to load video: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isVideoLoading.value = false;
    }
  }

  void _videoListener() {
    if (videoController != null) {
      isVideoPlaying.value = videoController!.value.isPlaying;
      if (videoController!.value.duration != Duration.zero) {
        videoProgress.value = videoController!.value.position.inMilliseconds / 
                             videoController!.value.duration.inMilliseconds;
      }
    }
  }

  Future<void> _disposeVideoControllers() async {
    videoController?.removeListener(_videoListener);
    videoController?.dispose();
    chewieController?.dispose();
    videoController = null;
    chewieController = null;
  }

  @override
  void onClose() {
    _disposeVideoControllers();
    super.onClose();
  }

  Future<void> deleteLession(int lessonId) async {
    try {
      isDeleting.value = true;
      String? token = sh1.getString(SharedPrefHelper.token);
      
      String url = ApiUrl.lessionDelete + lessonId.toString();
      
      print("🗑️ Deleting lesson: $url");
      
      final response = await NetworkService.makeDeleteRequest(
        url: url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      print("📊 Delete response: ${response['statusCode']}");
      
      if (response['statusCode'] == 200) {
        Get.snackbar(
          "Success",
          "Lesson deleted successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception("Failed to delete lesson");
      }
    } catch (e) {
      print("❌ Error deleting lesson: $e");
      Get.snackbar(
        "Error",
        "Failed to delete lesson: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isDeleting.value = false;
    }
  }

  /// Refresh lesson data
  Future<void> refreshLesson() async {
    if (lesson.value != null) {
      await fetchLessonDetail(lesson.value!.lessonId);
    }
  }

  /// Toggle video play/pause
  void toggleVideoPlayback() {
    if (videoController != null && isVideoReady.value) {
      if (videoController!.value.isPlaying) {
        videoController!.pause();
      } else {
        videoController!.play();
      }
    }
  }
}
