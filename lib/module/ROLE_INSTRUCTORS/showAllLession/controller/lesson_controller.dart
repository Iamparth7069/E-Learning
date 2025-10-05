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
  
  // Range streaming properties
  RxBool isRangeStreaming = false.obs;
  RxInt retryCount = 0.obs;
  RxInt maxRetries = 3.obs;
  RxString streamingStatus = ''.obs;
  
  // Video metadata
  RxInt videoSize = 0.obs;
  RxString videoContentType = ''.obs;
  RxBool supportsRangeRequests = false.obs;

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
      retryCount.value = 0;
      streamingStatus.value = 'Initializing...';
      
      print("🎥 Loading video with ID: $videoId");

      // Dispose previous controllers
      await _disposeVideoControllers();

      // First, try to get video metadata and check if range requests are supported
      await _checkVideoMetadata(videoId);
      
      // Try range-based streaming first, fallback to regular streaming
      bool success = false;
      
      if (supportsRangeRequests.value) {
        print("🔄 Attempting range-based streaming");
        success = await _loadVideoWithRangeStreaming(videoId);
      }
      
      if (!success) {
        print("🔄 Falling back to regular streaming");
        success = await _loadVideoWithRegularStreaming(videoId);
      }
      
      if (!success) {
        throw Exception("Failed to load video after all attempts");
      }

    } catch (e) {
      print("❌ Error loading video: $e");
      videoError.value = e.toString();
      
      // Show retry option if we haven't exceeded max retries
      if (retryCount.value < maxRetries.value) {
        _showRetryDialog(e.toString());
      } else {
        Get.snackbar(
          "Video Error",
          "Failed to load video after ${maxRetries.value} attempts. Please check your connection and try again.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: Duration(seconds: 5),
        );
      }
    } finally {
      isVideoLoading.value = false;
      streamingStatus.value = '';
    }
  }

  Future<void> _checkVideoMetadata(int videoId) async {
    try {
      String headUrl = "${ApiUrl.getStremeUrl}$videoId";
      
      print("🔍 Checking video metadata: $headUrl");
      
      // First try HEAD request to get video metadata
      final headResponse = await NetworkService.makeHeadRequest(url: headUrl);
      
      if (headResponse["statusCode"] == 200) {
        // Check if Accept-Ranges header is present
        final headers = headResponse["headers"] as Map<String, dynamic>?;
        final acceptRanges = headers?['accept-ranges']?.toString().toLowerCase();
        
        if (acceptRanges == 'bytes') {
          supportsRangeRequests.value = true;
          print("✅ Range requests supported (HEAD response)");
          return;
        }
      }
      
      // Fallback: Try a small range request to test support
      final rangeResponse = await NetworkService.makeRangeRequest(
        url: headUrl,
        range: 'bytes=0-1',
      );
      
      if (rangeResponse["statusCode"] == 206) {
        supportsRangeRequests.value = true;
        print("✅ Range requests supported (range test)");
      } else {
        supportsRangeRequests.value = false;
        print("⚠️ Range requests not supported, using regular streaming");
      }
      
    } catch (e) {
      print("⚠️ Could not check video metadata: $e");
      supportsRangeRequests.value = false;
    }
  }

  Future<bool> _loadVideoWithRangeStreaming(int videoId) async {
    try {
      isRangeStreaming.value = true;
      streamingStatus.value = 'Setting up range streaming...';
      
      String? token = sh1.getString(SharedPrefHelper.token);
      String rangeUrl = "${ApiUrl.getStremeUsingRange}$videoId";
      
      print("🎬 Loading video with range streaming: $rangeUrl");

      videoController = VideoPlayerController.networkUrl(
        Uri.parse(rangeUrl),
        httpHeaders: {
          'Authorization': 'Bearer $token',
          'Range': 'bytes=0-',
          'Accept': 'video/*',
        },
      );

      // Add error listener
      videoController!.addListener(_videoErrorListener);
      
      streamingStatus.value = 'Initializing video player...';
      await videoController!.initialize();

      // Add listeners for video progress
      videoController!.addListener(_videoListener);

      chewieController = ChewieController(
        videoPlayerController: videoController!,
        autoPlay: false,
        looping: false,
        showControlsOnInitialize: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.blueAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightBlue,
        ),
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  streamingStatus.value,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
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
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => retryVideoLoad(),
                    child: Text("Retry"),
                  ),
                ],
              ),
            ),
          );
        },
      );

      isVideoReady.value = true;
      print("✅ Video loaded successfully with range streaming");
      return true;
      
    } catch (e) {
      print("❌ Range streaming failed: $e");
      await _disposeVideoControllers();
      return false;
    } finally {
      isRangeStreaming.value = false;
    }
  }

  Future<bool> _loadVideoWithRegularStreaming(int videoId) async {
    try {
      streamingStatus.value = 'Setting up regular streaming...';
      
      String? token = sh1.getString(SharedPrefHelper.token);
      String videoUrl = "${ApiUrl.getStremeUrl}$videoId";
      
      print("🎬 Loading video with regular streaming: $videoUrl");

      videoController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        httpHeaders: {
          'Authorization': 'Bearer $token',
          'Accept': 'video/*',
        },
      );

      // Add error listener
      videoController!.addListener(_videoErrorListener);
      
      streamingStatus.value = 'Initializing video player...';
      await videoController!.initialize();

      // Add listeners for video progress
      videoController!.addListener(_videoListener);

      chewieController = ChewieController(
        videoPlayerController: videoController!,
        autoPlay: false,
        looping: false,
        showControlsOnInitialize: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.blueAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightBlue,
        ),
        placeholder: Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  streamingStatus.value,
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
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
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => retryVideoLoad(),
                    child: Text("Retry"),
                  ),
                ],
              ),
            ),
          );
        },
      );

      isVideoReady.value = true;
      print("✅ Video loaded successfully with regular streaming");
      return true;
      
    } catch (e) {
      print("❌ Regular streaming failed: $e");
      await _disposeVideoControllers();
      return false;
    }
  }

  void _videoErrorListener() {
    if (videoController != null && videoController!.value.hasError) {
      String error = videoController!.value.errorDescription ?? 'Unknown video error';
      print("🎥 Video error detected: $error");
      videoError.value = error;
      
      // Auto-retry on certain errors
      if (retryCount.value < maxRetries.value && 
          (error.contains('network') || error.contains('timeout') || error.contains('connection'))) {
        Future.delayed(Duration(seconds: 2), () => retryVideoLoad());
      }
    }
  }

  void _showRetryDialog(String error) {
    Get.dialog(
      AlertDialog(
        title: Text("Video Loading Failed"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Error: $error"),
            SizedBox(height: 16),
            Text("Would you like to retry?"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              retryVideoLoad();
            },
            child: Text("Retry"),
          ),
        ],
      ),
    );
  }

  Future<void> retryVideoLoad() async {
    if (retryCount.value >= maxRetries.value) {
      Get.snackbar(
        "Max Retries Reached",
        "Unable to load video after ${maxRetries.value} attempts",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    
    retryCount.value++;
    print("🔄 Retrying video load (attempt ${retryCount.value}/${maxRetries.value})");
    
    if (lesson.value?.video.videoId != null) {
      await _loadVideoFromUrl(lesson.value!.video.videoId!);
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
    videoController?.removeListener(_videoErrorListener);
    videoController?.dispose();
    chewieController?.dispose();
    videoController = null;
    chewieController = null;
    isVideoReady.value = false;
  }

  @override
  void onClose() {
    _disposeVideoControllers();
    super.onClose();
  }

  Future<bool> deleteLession(int lessonId) async {
    try {
      isDeleting.value = true;
      String? token = sh1.getString(SharedPrefHelper.token);
      
      if (token == null || token.isEmpty) {
        throw Exception("Authentication token is missing. Please login again.");
      }
      
      String url = ApiUrl.lessionDelete + lessonId.toString();
      
      print("🗑️ Deleting lesson: $url");
      
      final response = await NetworkService.makeDeleteRequest(
        url: url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      
      print("📊 Delete response: ${response['statusCode']}");
      
      if (response['statusCode'] == 200 || response['statusCode'] == 204) {
        Get.snackbar(
          "Success",
          "Lesson deleted successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
        );
        
        // Dispose video controllers before navigating back
        await _disposeVideoControllers();
        
        return true; // Success
      } else {
        String errorMsg = response['response']?.toString() ?? 'Unknown error occurred';
        throw Exception("Failed to delete lesson: $errorMsg");
      }
    } catch (e) {
      print("❌ Error deleting lesson: $e");
      
      String errorMessage = e.toString();
      
      // Handle specific error types
      if (errorMessage.contains('SocketException') || errorMessage.contains('NetworkException')) {
        errorMessage = "Network error. Please check your internet connection and try again.";
      } else if (errorMessage.contains('TimeoutException')) {
        errorMessage = "Request timeout. Please try again.";
      }
      
      Get.snackbar(
        "Error",
        "Failed to delete lesson: $errorMessage",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
      
      return false; // Failed
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