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
  var videoError = ''.obs;
  var isVideoReady = false.obs;
  var retryCount = 0.obs;
  var maxRetries = 3.obs;
  var isEnrolled = false.obs;
  var previewMode = false.obs;
  var previewTimeRemaining = 60.obs; // 60 seconds preview
  
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
        // Check if video is ready for playback
        isVideoReady.value = isVideoReadyForPlayback();
        // Check enrollment status
        await checkEnrollmentStatus();
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
      final url = '${ApiUrl.getStremeUsingRange}${lesson!.video.videoId}';
      print('🎥 Range Stream URL: $url');
      return url;
    }
    print('❌ No video ID available');
    return '';
  }

  String getVideoStreamUrlFallback() {
    if (lesson?.video.videoId != null) {
      final url = '${ApiUrl.getStremeUrl}${lesson!.video.videoId}';
      print('🎥 Fallback Stream URL: $url');
      return url;
    }
    print('❌ No video ID available for fallback');
    return '';
  }



  Future<void> initializeVideoPlayer() async {
    if (lesson == null) {
      videoError.value = 'Lesson data not available';
      return;
    }

    // Check enrollment status first
    if (!isEnrolled.value) {
      videoError.value = 'Please enroll in this course to access the full video content';
      previewMode.value = true;
      Get.snackbar(
        'Enrollment Required',
        'Please enroll in this course to access the full video content',
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        icon: const Icon(Icons.school, color: Colors.white),
      );
      return;
    }

    // Allow playback for PENDING status (preview mode)
    if (!isVideoReadyForPlayback()) {
      if (lesson!.video.processingStatus.toLowerCase() == 'pending') {
        previewMode.value = true;
        // Allow preview for 1 minute
        _startPreviewTimer();
        Get.snackbar(
          'Preview Mode',
          'Video is still processing. Showing preview for 1 minute.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: const Icon(Icons.info, color: Colors.white),
        );
      } else {
        videoError.value = 'Video is not ready for playback. Status: ${lesson!.video.processingStatus}';
        Get.snackbar(
          'Video Not Ready',
          'Video is still ${lesson!.video.processingStatus.toLowerCase()}. Please wait for processing to complete.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: const Icon(Icons.info, color: Colors.white),
        );
        return;
      }
    }

    final url = getVideoStreamUrl();
    if (url.isEmpty) {
      videoError.value = 'Invalid video URL - No video ID found';
      print('❌ Video URL is empty - lesson: ${lesson?.lessonName}, videoId: ${lesson?.video.videoId}');
      Get.snackbar(
        'Error',
        'Invalid video URL - No video ID found',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isVideoLoading.value = true;
      videoError.value = '';
      retryCount.value = 0;

      print('🎬 Starting video initialization...');
      print('📹 Video URL: $url');
      print('📊 Video Status: ${lesson!.video.processingStatus}');
      print('🎯 Preview Mode: ${previewMode.value}');

      // Get authentication token
      final String? token = sharedPrefHelper.getString(SharedPrefHelper.token);
      final Map<String, String>? headers = token == null || token.isEmpty
          ? null
          : {
              'Authorization': 'Bearer $token',
            };

      print('🔑 Token available: ${token != null && token.isNotEmpty}');

      _disposeVideoPlayer();

      // Try to initialize video player with retry mechanism
      await _initializeVideoWithRetry(url, headers);

      print('✅ Video initialization completed successfully');

    } catch (e) {
      print("❌ Video initialization error: $e");
      videoError.value = 'Failed to initialize video player: ${e.toString()}';
      Get.snackbar(
        'Playback Error',
        'Could not initialize video player. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isVideoLoading.value = false;
    }
  }

  Future<void> _initializeVideoWithRetry(String url, Map<String, String>? headers) async {
    for (int attempt = 0; attempt < maxRetries.value; attempt++) {
      try {
        retryCount.value = attempt + 1;
        print("🔄 Attempt ${attempt + 1}/${maxRetries.value}");
        
        if (attempt == 0) {
          // First attempt: Try direct range streaming
          print("📡 Trying direct range streaming...");
          await _tryRangeStreaming(url, headers);
        } else if (attempt == 1) {
          // Second attempt: Try chunked download and local playback
          print("💾 Trying chunked download and local playback...");
          await _tryLocalPlayback(url, headers);
        } else {
          // Third attempt: Try fallback URL with chunked download
          final fallback = getVideoStreamUrlFallback();
          print("🔄 Trying fallback URL with chunked download: $fallback");
          if (fallback.isNotEmpty) {
            await _tryLocalPlayback(fallback, headers);
          } else {
            throw Exception('No fallback URL available');
          }
        }

        // If we reach here, initialization was successful
        print("✅ Video player initialized successfully on attempt ${attempt + 1}");
        _setupChewieController();
        isPlayerInitialized.value = true;
        videoError.value = '';
        return;

      } catch (e) {
        print("❌ Attempt ${attempt + 1} failed: $e");
        print("📍 Error type: ${e.runtimeType}");
        if (attempt == maxRetries.value - 1) {
          // Last attempt failed
          print("💥 All attempts failed, throwing error");
          rethrow;
        }
        // Wait before retry
        final waitTime = 2 * (attempt + 1);
        print("⏳ Waiting ${waitTime}s before retry...");
        await Future.delayed(Duration(seconds: waitTime));
      }
    }
  }

  Future<void> _tryRangeStreaming(String url, Map<String, String>? headers) async {
    print("🎥 Creating VideoPlayerController for: $url");
    print("🔑 Headers: ${headers ?? 'No headers'}");
    
    try {
      videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: headers ?? {},
      );
      
      print("⏳ Initializing video player...");
      await videoPlayerController!.initialize();
      print("✅ Video player initialized successfully");
      
      // Add error listener
      videoPlayerController!.addListener(_videoErrorListener);
      print("👂 Error listener added");
      
    } catch (e) {
      print("❌ Range streaming failed: $e");
      print("📍 Error type: ${e.runtimeType}");
      rethrow;
    }
  }

  Future<void> _tryLocalPlayback(String url, Map<String, String>? headers) async {
    final file = await _downloadToTempFile(url, headers);
    _disposeVideoPlayer();
    
    videoPlayerController = VideoPlayerController.file(file);
    await videoPlayerController!.initialize();
    
    // Add error listener
    videoPlayerController!.addListener(_videoErrorListener);
  }

  void _setupChewieController() {
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController!,
      autoPlay: false, // Don't autoplay, let user control
      looping: false,
      allowMuting: true,
      allowFullScreen: true,
      showOptions: true,
      showControls: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.blue,
        handleColor: Colors.blueAccent,
        backgroundColor: Colors.grey.shade700,
        bufferedColor: Colors.white54,
      ),
      cupertinoProgressColors: ChewieProgressColors(
        playedColor: Colors.blue,
        handleColor: Colors.blueAccent,
        backgroundColor: Colors.grey.shade700,
        bufferedColor: Colors.white54,
      ),
    );
  }

  void _videoErrorListener() {
    if (videoPlayerController?.value.hasError == true) {
      final error = videoPlayerController?.value.errorDescription ?? 'Unknown video error';
      print("❌ Video player error: $error");
      videoError.value = error;
    }
  }

  void _disposeVideoPlayer() {
    chewieController?.dispose();
    chewieController = null;
    videoPlayerController?.dispose();
    videoPlayerController = null;
    isPlayerInitialized.value = false;
  }

  // Retry video initialization
  Future<void> retryVideoInitialization() async {
    await initializeVideoPlayer();
  }

  // Check if video is ready for playback
  bool isVideoReadyForPlayback() {
    return lesson?.video.processingStatus.toLowerCase() == 'completed';
  }

  // Check enrollment status
  Future<void> checkEnrollmentStatus() async {
    if (lesson == null) return;
    
    try {
      String? token = sharedPrefHelper.getString(SharedPrefHelper.token);
      if (token == null) {
        isEnrolled.value = false;
        return;
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      // Check if user is enrolled in this course
      final response = await NetworkService.makeGetRequest(
        url: '${ApiUrl.getUserByCourse}${lesson!.courseId}',
        headers: headers,
      );

      if (response["statusCode"] == 200) {
        List<dynamic> enrollments = response['response'];
        // Check if current user is enrolled
        isEnrolled.value = enrollments.isNotEmpty;
        print('Enrollment status: ${isEnrolled.value}');
      } else {
        isEnrolled.value = false;
      }
    } catch (e) {
      print('Error checking enrollment: $e');
      isEnrolled.value = false;
    }
  }

  // Start preview timer
  void _startPreviewTimer() {
    previewTimeRemaining.value = 60;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (previewTimeRemaining.value > 0) {
        previewTimeRemaining.value--;
      } else {
        timer.cancel();
        _endPreview();
      }
    });
  }

  // End preview mode
  void _endPreview() {
    previewMode.value = false;
    _disposeVideoPlayer();
    Get.snackbar(
      'Preview Ended',
      'Please enroll in the course to continue watching',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: const Icon(Icons.school, color: Colors.white),
    );
  }

  Future<File> _downloadToTempFile(String url, Map<String, String>? headers) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/lesson_${lessonId.value}.mp4';
    final file = File(path);
    
    print("💾 Starting video download to: $path");
    
    try {
      // First, try to get file size with HEAD request
      final headResponse = await NetworkService.makeHeadRequest(url: url, headers: headers);
      final contentLength = headResponse['headers']?['content-length']?.first;
      final fileSize = contentLength != null ? int.parse(contentLength) : null;
      
      print("📏 File size: ${fileSize ?? 'Unknown'} bytes");
      
      if (fileSize != null && fileSize > 0) {
        // Download in chunks using range requests
        await _downloadVideoInChunks(url, headers, file, fileSize);
      } else {
        // Fallback to regular download
        await _downloadVideoRegular(url, headers, file);
      }
      
      print("✅ Video download completed: ${file.lengthSync()} bytes");
      return file;
    } catch (e) {
      print("❌ Error downloading video: $e");
      // Try regular download as fallback
      await _downloadVideoRegular(url, headers, file);
      return file;
    }
  }

  Future<void> _downloadVideoInChunks(String url, Map<String, String>? headers, File file, int fileSize) async {
    const chunkSize = 1024 * 1024; // 1MB chunks
    final sink = file.openWrite();
    
    try {
      for (int start = 0; start < fileSize; start += chunkSize) {
        final end = (start + chunkSize - 1).clamp(0, fileSize - 1);
        final range = 'bytes=$start-$end';
        
        print("📥 Downloading chunk: $range");
        
        final response = await NetworkService.makeRangeRequest(
          url: url,
          range: range,
          headers: headers,
        );
        
        if (response['statusCode'] == 206) {
          final chunkData = response['response'] as List<int>;
          sink.add(chunkData);
          print("✅ Chunk downloaded: ${chunkData.length} bytes");
        } else {
          print("❌ Chunk download failed with status: ${response['statusCode']}");
          throw Exception('Chunk download failed');
        }
      }
    } finally {
      await sink.flush();
      await sink.close();
    }
  }

  Future<void> _downloadVideoRegular(String url, Map<String, String>? headers, File file) async {
    print("📥 Using regular download method");
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

  void onVideoTap() {
    print("👆 Video tapped - Player initialized: ${isPlayerInitialized.value}");
    print("📊 Video error: ${videoError.value}");
    print("🎯 Preview mode: ${previewMode.value}");
    print("📚 Enrolled: ${isEnrolled.value}");
    
    if (!isPlayerInitialized.value) {
      print("🚀 Starting video initialization...");
      initializeVideoPlayer();
      return;
    }
    // If already initialized, toggle play/pause
    final isPlaying = videoPlayerController?.value.isPlaying ?? false;
    print("▶️ Currently playing: $isPlaying");
    if (isPlaying) {
      videoPlayerController?.pause();
    } else {
      videoPlayerController?.play();
    }
  }

  // Test method to check video URL accessibility
  Future<void> testVideoUrl() async {
    if (lesson == null) {
      print("❌ No lesson data available");
      return;
    }

    final url = getVideoStreamUrl();
    print("🔍 Testing video URL: $url");
    
    if (url.isEmpty) {
      print("❌ Video URL is empty");
      return;
    }

    try {
      String? token = sharedPrefHelper.getString(SharedPrefHelper.token);
      final Map<String, String>? headers = token == null || token.isEmpty
          ? null
          : {
              'Authorization': 'Bearer $token',
            };

      print("🌐 Making HEAD request to test URL...");
      final response = await NetworkService.makeHeadRequest(
        url: url,
        headers: headers,
      );

      print("📊 Response status: ${response['statusCode']}");
      print("📋 Response headers: ${response['headers']}");
      
      if (response['statusCode'] == 200) {
        print("✅ Video URL is accessible");
      } else {
        print("❌ Video URL returned status: ${response['statusCode']}");
      }
    } catch (e) {
      print("❌ Error testing video URL: $e");
    }
  }

  // Test range request specifically
  Future<void> testRangeRequest() async {
    if (lesson == null) {
      print("❌ No lesson data available");
      return;
    }

    final url = getVideoStreamUrl();
    print("🔍 Testing range request for URL: $url");
    
    if (url.isEmpty) {
      print("❌ Video URL is empty");
      return;
    }

    try {
      String? token = sharedPrefHelper.getString(SharedPrefHelper.token);
      final Map<String, String>? headers = token == null || token.isEmpty
          ? null
          : {
              'Authorization': 'Bearer $token',
            };

      print("🌐 Making range request (bytes=0-1023)...");
      final response = await NetworkService.makeRangeRequest(
        url: url,
        range: 'bytes=0-1023',
        headers: headers,
      );

      print("📊 Range response status: ${response['statusCode']}");
      print("📋 Range response headers: ${response['headers']}");
      
      if (response['statusCode'] == 206) {
        print("✅ Range request successful (206 Partial Content)");
      } else if (response['statusCode'] == 200) {
        print("⚠️ Range request returned 200 (full content)");
      } else {
        print("❌ Range request failed with status: ${response['statusCode']}");
      }
    } catch (e) {
      print("❌ Error testing range request: $e");
    }
  }

  void addComment() {
    // TODO: Implement comment functionality
    Get.snackbar('Comments', 'Comment functionality coming soon');
  }
}
