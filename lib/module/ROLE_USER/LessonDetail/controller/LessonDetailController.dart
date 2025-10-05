import 'dart:async';

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../api/listing/api_listing.dart';
import '../../../../api/url/api_url.dart';
import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../ROLE_INSTRUCTORS/showAllLession/model/lesson_model.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';

class LessonDetailController extends GetxController {
  var isLoading = false.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var isVideoLoading = false.obs;
  var isPlayerInitialized = false.obs;
  
  Lesson? lesson;
  var lessonId = 0.obs;
  var lessonName = ''.obs;
  var courseName = ''.obs;

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  
  SharedPrefHelper sharedPrefHelper = SharedPrefHelper();

  @override
  void onInit() {
    super.onInit();
    // Get lessonId from arguments
    if (Get.arguments != null) {
      lessonId.value = Get.arguments['lessonId'] ?? 0;
      lessonName.value = Get.arguments['lessonName'] ?? '';
      courseName.value = Get.arguments['courseName'] ?? '';
    }
    if (lessonId.value > 0) {
      fetchLessonDetails();
    }
  }

  @override
  void onReady() {
    super.onReady();
    // Additional setup after the controller is ready
  }

  @override
  void onClose() {
    // Clean up resources if needed
    _disposeVideoPlayer();
    super.onClose();
  }

  Future<void> fetchLessonDetails() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      
      String? token = sharedPrefHelper.getString(SharedPrefHelper.token);
      
      if (token == null) {
        hasError.value = true;
        errorMessage.value = 'User not authenticated';
        isLoading.value = false;
        return;
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      final response = await NetworkService.makeGetRequest(
        url: '${ApiUrl.getLessionDetails}${lessonId.value}',
        headers: headers,
      );

      isLoading.value = false;

      if (response["statusCode"] == 200) {
        lesson = Lesson.fromJson(response['response']);
        print('Lesson details loaded successfully: ${lesson?.lessonName}');
      } else {
        hasError.value = true;
        errorMessage.value = response["response"]?.toString() ?? 'Failed to load lesson details';
        Get.snackbar('Error', errorMessage.value);
      }
    } catch (e) {
      isLoading.value = false;
      hasError.value = true;
      errorMessage.value = 'An unexpected error occurred: ${e.toString()}';
      Get.snackbar('Error', errorMessage.value);
    }
  }

  Future<void> refreshLessonDetails() async {
    await fetchLessonDetails();
  }

  String getVideoStreamUrl() {
    if (lesson?.video.videoId != null) {
      return '${ApiUrl.getStremeUsingRange}${lesson!.video.videoId}';
    }
    return '';
  }

  String getVideoStreamUrlFallback() {
    if (lesson?.video.videoId != null) {
      return '${ApiUrl.getStremeUrl}${lesson!.video.videoId}';
    }
    return '';
  }



  Future<void> initializeVideoPlayer() async {


    // Try initializing even if status is pending/processing; stream may already be accessible
    if (!isVideoReady()) {
      Get.snackbar('Info', 'Attempting playback while video status is ${lesson?.video.processingStatus.toLowerCase()}');
    }
    final url = getVideoStreamUrl();
    if (url.isEmpty) {
      Get.snackbar('Error', 'Invalid video URL');
      return;
    }

    try {
      isVideoLoading.value = true;

      // Optional auth header if your stream requires it
      final String? token = sharedPrefHelper.getString(SharedPrefHelper.token);
      final Map<String, String>? headers = token == null || token.isEmpty
          ? null
          : {
              'Authorization': 'Bearer $token',
            };

      _disposeVideoPlayer();

      try {
        // Try range streaming first
        videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(url),
          httpHeaders: headers!,
        );
        await videoPlayerController!.initialize();
      } catch (e) {
        // Fallback to non-range endpoint (helps on iOS when server range headers mismatch)
        final fallback = getVideoStreamUrlFallback();
        _disposeVideoPlayer();
        try {
          videoPlayerController = VideoPlayerController.networkUrl(
            Uri.parse(fallback.isNotEmpty ? fallback : url),
            httpHeaders: headers!,
          );
          await videoPlayerController!.initialize();
        } catch (e2) {
          // Absolute fallback: download to temp file and play locally
          final file = await _downloadToTempFile(fallback.isNotEmpty ? fallback : url, headers);
          _disposeVideoPlayer();
          videoPlayerController = VideoPlayerController.file(file);
          await videoPlayerController!.initialize();
        }
      }

      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        looping: false,
        allowMuting: true,
        allowFullScreen: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
          backgroundColor: Colors.grey.shade700,
          bufferedColor: Colors.white54,
        ),
      );

      isPlayerInitialized.value = true;
    } catch (e) {
      Get.snackbar('Playback Error', 'Could not initialize player: $e');
    } finally {
      isVideoLoading.value = false;
    }
  }

  void _disposeVideoPlayer() {
    chewieController?.dispose();
    chewieController = null;
    videoPlayerController?.dispose();
    videoPlayerController = null;
    isPlayerInitialized.value = false;
  }

  Future<File> _downloadToTempFile(String url, Map<String, String>? headers) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/lesson_${lessonId.value}.mp4';
    final file = File(path);
    final dio = Dio();
    final resp = await dio.get<ResponseBody>(
      url,
      options: Options(
        responseType: ResponseType.stream,
        headers: headers,
        followRedirects: true,
        validateStatus: (s) => (s ?? 500) < 400,
      ),
    );
    final sink = file.openWrite();
    await resp.data!.stream.pipe(sink as StreamConsumer<Uint8List>);
    await sink.flush();
    await sink.close();
    return file;
  }

  Color getProcessingStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'processing':
        return Colors.orange;
      case 'pending':
        return Colors.amber;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getProcessingStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Ready';
      case 'processing':
        return 'Processing';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Failed';
      default:
        return status;
    }
  }

  bool isVideoReady() {
    return lesson?.video.processingStatus.toLowerCase() == 'completed';
  }

  void onVideoTap() {
    if (!isPlayerInitialized.value) {
      initializeVideoPlayer();
      return;
    }
    // If already initialized, toggle play/pause
    final isPlaying = videoPlayerController?.value.isPlaying ?? false;
    if (isPlaying) {
      videoPlayerController?.pause();
    } else {
      videoPlayerController?.play();
    }
  }

  void addComment() {
    // TODO: Implement comment functionality
    Get.snackbar('Comments', 'Comment functionality coming soon');
  }
}
