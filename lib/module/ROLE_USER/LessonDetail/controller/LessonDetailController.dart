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
  var isEnrolled = true.obs; // Always allow access
  var previewMode = false.obs;
  var previewTimeRemaining = 60.obs; // 60 seconds preview
  
  // Lesson progress tracking
  var enrollmentId = 0.obs;
  var lastWatchedSeconds = 0.obs;
  var isCompleted = false.obs;
  var totalVideoDuration = 0.obs;
  var currentVideoPosition = 0.obs;
  Timer? progressUpdateTimer;
  var isProgressTrackingEnabled = true.obs;
  
  // Rating system
  var userRating = 0.obs;
  var userComment = ''.obs;
  var isRatingSubmitted = false.obs;
  var isRatingLoading = false.obs;
  var ratingError = ''.obs;
  
  // Average rating system
  var averageRating = 0.0.obs;
  var totalRating = 0.obs;
  var isAverageRatingLoading = false.obs;
  var averageRatingError = ''.obs;
  
  // Course completion system
  var isCourseCompleted = false.obs;
  var isCourseCompletionLoading = false.obs;
  var courseCompletionError = ''.obs;
  
  Lesson? lesson;
  var lessonId = 0.obs;
  var lessonName = ''.obs;
  var courseName = ''.obs;

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  
  SharedPrefHelper sharedPrefHelper = SharedPrefHelper();

  // Constructor to initialize with arguments
  LessonDetailController({int? lessonId, String? lessonName, String? courseName, int? enrollmentId}) {
    if (lessonId != null) this.lessonId.value = lessonId;
    if (lessonName != null) this.lessonName.value = lessonName;
    if (courseName != null) this.courseName.value = courseName;
    if (enrollmentId != null) this.enrollmentId.value = enrollmentId;
  }

  @override
  void onInit() {
    super.onInit();
    print('🎯 LessonDetailController initialized');
    
    // Get lessonId from arguments
    if (Get.arguments != null) {
      lessonId.value = Get.arguments['lessonId'] ?? 0;
      lessonName.value = Get.arguments['lessonName'] ?? '';
      courseName.value = Get.arguments['courseName'] ?? '';
      enrollmentId.value = Get.arguments['enrollmentId'] ?? 0;
      print('📚 Lesson ID: ${lessonId.value}, Name: ${lessonName.value}, Enrollment ID: ${enrollmentId.value}');
    }
    
    if (lessonId.value > 0) {
      fetchLessonDetails();
    } else {
      print('⚠️ No lesson ID provided');
      hasError.value = true;
      errorMessage.value = 'No lesson ID provided';
    }
  }

  @override
  void onClose() {
    print('🧹 LessonDetailController disposing...');
    // Stop progress tracking
    _stopProgressTracking();
    // Update lesson progress before disposing
    _updateLessonProgressOnDispose();
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
        // Always allow access - no enrollment check needed
        isEnrolled.value = true;
        // Fetch average rating for the course
        fetchAverageRating();
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
      
      // Check if URL is HTTP and warn about potential issues
      if (url.startsWith('http://')) {
        print('⚠️ Warning: Video URL uses HTTP (not HTTPS). This may cause network security issues on Android.');
        print('💡 Consider using HTTPS for video streaming to avoid cleartext traffic errors.');
        
        // Try to convert HTTP to HTTPS
        final httpsUrl = url.replaceFirst('http://', 'https://');
        print('🔄 Attempting HTTPS URL: $httpsUrl');
        return httpsUrl;
      }
      
      return url;
    }
    print('❌ No video ID available');
    return '';
  }

  // Alternative method to get video URL with better error handling
  String getVideoStreamUrlWithFallback() {
    if (lesson?.video.videoId != null) {
      final baseUrl = ApiUrl.getStremeUsingRange;
      final videoId = lesson!.video.videoId;
      
      print('🎥 Base URL: $baseUrl');
      print('🎥 Video ID: $videoId');
      
      // Try HTTPS first
      if (baseUrl.startsWith('http://')) {
        final httpsBaseUrl = baseUrl.replaceFirst('http://', 'https://');
        final httpsUrl = '$httpsBaseUrl$videoId';
        print('🔒 Trying HTTPS URL first: $httpsUrl');
        return httpsUrl;
      }
      
      // Fallback to original URL
      final url = '$baseUrl$videoId';
      print('🌐 Using original URL: $url');
      return url;
    }
    print('❌ No video ID available');
    return '';
  }

  // Removed fallback URL as per requirement - only use range API



  Future<void> initializeVideoPlayer() async {
    if (lesson == null) {
      videoError.value = 'Lesson data not available';
      return;
    }

    // Always allow access - no enrollment restrictions
    isEnrolled.value = true;

    // Allow playback for any status - show preview mode for non-completed videos
    if (!isVideoReadyForPlayback()) {
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
    }

    // Try to get video URL with fallback
    String url = getVideoStreamUrlWithFallback();
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
    
    print('🎬 Final video URL: $url');
    
    // Print comprehensive debug information
    printVideoDebugInfo();

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

      // Test video URL connectivity first
      final isAccessible = await testVideoUrlConnectivity(url, headers);
      print('🔍 Video URL accessible: $isAccessible');
      
      if (!isAccessible) {
        // If HTTPS failed, try HTTP as fallback
        if (url.startsWith('https://')) {
          final httpUrl = url.replaceFirst('https://', 'http://');
          print('🔄 HTTPS failed, trying HTTP fallback: $httpUrl');
          final httpAccessible = await testVideoUrlConnectivity(httpUrl, headers);
          if (httpAccessible) {
            url = httpUrl;
            print('✅ HTTP fallback is accessible');
          }
        }
      }

      // Test server range support
      final supportsRange = await testServerRangeSupport(url, headers);
      print('🔍 Server range support: $supportsRange');

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
    String currentUrl = url;
    
    for (int attempt = 0; attempt < maxRetries.value; attempt++) {
      try {
        retryCount.value = attempt + 1;
        print("🔄 Attempt ${attempt + 1}/${maxRetries.value}");
        print("🌐 Using URL: $currentUrl");
        
        if (attempt == 0) {
          // First attempt: Try optimized range streaming
          print("📡 Trying optimized range streaming...");
          await _tryOptimizedRangeStreaming(currentUrl, headers);
        } else if (attempt == 1) {
          // Second attempt: Try range streaming with fallback headers
          print("🔄 Trying range streaming with fallback headers...");
          await _tryRangeStreamingWithModifiedHeaders(currentUrl, headers);
        } else {
          // Third attempt: Try complete video download and local playback
          print("💾 Trying complete video download and local playback...");
          await _tryCompleteVideoDownload(currentUrl, headers);
        }

        // If we reach here, initialization was successful
        print("✅ Video player initialized successfully on attempt ${attempt + 1}");
        _setupChewieController();
        isPlayerInitialized.value = true;
        videoError.value = '';
        // Start progress tracking
        _startProgressTracking();
        return;

      } catch (e) {
        print("❌ Attempt ${attempt + 1} failed: $e");
        print("📍 Error type: ${e.runtimeType}");
        
        // Check if it's a cleartext HTTP error and try HTTPS fallback
        if (e.toString().contains('CleartextNotPermittedException') || 
            e.toString().contains('Cleartext HTTP traffic not permitted')) {
          print("🔒 Detected cleartext HTTP error, trying HTTPS fallback...");
          if (currentUrl.startsWith('http://')) {
            currentUrl = currentUrl.replaceFirst('http://', 'https://');
            print("🔄 Switching to HTTPS URL: $currentUrl");
            // Don't increment attempt counter for this fallback
            attempt--;
            continue;
          }
        }
        
        // Check if it's a range request error and try different approach
        if (e.toString().contains('content range mismatch') || 
            e.toString().contains('CoreMediaErrorDomain error -12939') ||
            e.toString().contains('OSStatus error -12848')) {
          print("🔧 Detected video streaming error, will try alternative approach");
        }
        
        if (attempt == maxRetries.value - 1) {
          // Last attempt failed
          print("💥 All attempts failed, throwing error");
          rethrow;
        }
        
        // Clean up failed attempt
        _disposeVideoPlayer();
        
        // Reduced wait time for faster retry
        final waitTime = 1; // Reduced from 2 * (attempt + 1)
        print("⏳ Waiting ${waitTime}s before retry...");
        await Future.delayed(Duration(seconds: waitTime));
      }
    }
  }

  Future<void> _tryOptimizedRangeStreaming(String url, Map<String, String>? headers) async {
    print("🎥 Creating optimized VideoPlayerController for: $url");
    print("🔑 Headers: ${headers ?? 'No headers'}");
    
    try {
      // Create optimized headers for smooth streaming
      final customHeaders = Map<String, String>.from(headers ?? {});
      
      // Remove any existing Range header to let the video player handle it
      customHeaders.remove('Range');
      
      // Add optimized headers for smooth video streaming
      customHeaders['Accept'] = 'video/mp4,video/*,*/*;q=0.9';
      customHeaders['Accept-Encoding'] = 'identity'; // Disable compression for range requests
      customHeaders['Connection'] = 'keep-alive';
      customHeaders['Cache-Control'] = 'no-cache';
      customHeaders['Pragma'] = 'no-cache';
      customHeaders['User-Agent'] = 'Mozilla/5.0 (compatible; VideoPlayer/1.0)';
      
      // Add headers to bypass cleartext restrictions for development
      if (url.startsWith('http://')) {
        customHeaders['X-Allow-Cleartext'] = 'true';
        customHeaders['X-Development-Mode'] = 'true';
        print("🔓 Added cleartext bypass headers for HTTP URL");
      }
      
      print("🔧 Using optimized headers for smooth streaming: $customHeaders");
      
      videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: customHeaders,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );
      
      print("⏳ Initializing optimized video player...");
      await videoPlayerController!.initialize();
      print("✅ Optimized video player initialized successfully");
      
      // Add error listener
      videoPlayerController!.addListener(_videoErrorListener);
      // Add progress tracking listener
      videoPlayerController!.addListener(_videoProgressListener);
      print("👂 Error listener and progress listener added");
      
    } catch (e) {
      print("❌ Optimized range streaming failed: $e");
      print("📍 Error type: ${e.runtimeType}");
      
      // If it's a cleartext error, provide helpful message
      if (e.toString().contains('CleartextNotPermittedException') || 
          e.toString().contains('Cleartext HTTP traffic not permitted')) {
        print("🔒 Cleartext HTTP error - network security configuration may need adjustment");
        videoError.value = 'Network security error: HTTP video streaming is blocked. Please check your network configuration or use HTTPS.';
      }
      
      rethrow;
    }
  }

  Future<void> _tryRangeStreaming(String url, Map<String, String>? headers) async {
    print("🎥 Creating VideoPlayerController for: $url");
    print("🔑 Headers: ${headers ?? 'No headers'}");
    
    try {
      // Create a custom HTTP client that handles range requests properly
      final customHeaders = Map<String, String>.from(headers ?? {});
      
      // Remove any existing Range header to let the video player handle it
      customHeaders.remove('Range');
      
      // Add proper headers for video streaming
      customHeaders['Accept'] = 'video/*,*/*;q=0.9';
      customHeaders['Accept-Encoding'] = 'identity'; // Disable compression for range requests
      customHeaders['Connection'] = 'keep-alive';
      
      print("🔧 Using custom headers for video streaming: $customHeaders");
      
      videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: customHeaders,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );
      
      print("⏳ Initializing video player...");
      await videoPlayerController!.initialize();
      print("✅ Video player initialized successfully");
      
      // Add error listener
      videoPlayerController!.addListener(_videoErrorListener);
      // Add progress tracking listener
      videoPlayerController!.addListener(_videoProgressListener);
      print("👂 Error listener and progress listener added");
      
    } catch (e) {
      print("❌ Range streaming failed: $e");
      print("📍 Error type: ${e.runtimeType}");
      rethrow;
    }
  }

  Future<void> _tryRangeStreamingWithModifiedHeaders(String url, Map<String, String>? headers) async {
    print("🎥 Creating VideoPlayerController with modified headers for: $url");
    
    try {
      // Create headers optimized for range streaming
      final customHeaders = Map<String, String>.from(headers ?? {});
      
      // Remove any existing Range header to let the video player handle it
      customHeaders.remove('Range');
      
      // Add headers optimized for video streaming
      customHeaders['Accept'] = 'video/mp4,video/*,*/*;q=0.9';
      customHeaders['Accept-Encoding'] = 'identity'; // Disable compression
      customHeaders['Connection'] = 'keep-alive';
      customHeaders['Cache-Control'] = 'no-cache';
      customHeaders['Pragma'] = 'no-cache';
      
      print("🔧 Using optimized headers for range streaming: $customHeaders");
      
      videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: customHeaders,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );
      
      print("⏳ Initializing video player with modified headers...");
      await videoPlayerController!.initialize();
      print("✅ Video player initialized successfully with modified headers");
      
      // Add error listener
      videoPlayerController!.addListener(_videoErrorListener);
      // Add progress tracking listener
      videoPlayerController!.addListener(_videoProgressListener);
      print("👂 Error listener and progress listener added");
      
    } catch (e) {
      print("❌ Range streaming with modified headers failed: $e");
      print("📍 Error type: ${e.runtimeType}");
      rethrow;
    }
  }

  Future<void> _tryCompleteVideoDownload(String url, Map<String, String>? headers) async {
    print("💾 Starting complete video download for: $url");
    
    try {
      // Get the complete video file size first
      final headResponse = await NetworkService.makeHeadRequest(url: url, headers: headers);
      final contentLength = headResponse['headers']?['content-length']?.first;
      final fileSize = contentLength != null ? int.parse(contentLength) : null;
      
      print("📏 Complete video file size: ${fileSize ?? 'Unknown'} bytes");
      
      if (fileSize != null && fileSize > 0) {
        // Download the complete video file
        final file = await _downloadCompleteVideo(url, headers, fileSize);
        _disposeVideoPlayer();
        
        print("📁 Video downloaded to: ${file.path}");
        print("📊 Downloaded file size: ${file.lengthSync()} bytes");
        
        // Verify file integrity
        if (file.lengthSync() != fileSize) {
          throw Exception('Downloaded file size mismatch. Expected: $fileSize, Got: ${file.lengthSync()}');
        }
        
        videoPlayerController = VideoPlayerController.file(file);
        await videoPlayerController!.initialize();
        
        // Add error listener
        videoPlayerController!.addListener(_videoErrorListener);
        // Add progress tracking listener
        videoPlayerController!.addListener(_videoProgressListener);
        print("✅ Complete video download and playback setup successful");
      } else {
        throw Exception('Could not determine video file size');
      }
    } catch (e) {
      print("❌ Complete video download failed: $e");
      print("📍 Error type: ${e.runtimeType}");
      rethrow;
    }
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
      autoInitialize: true, // Auto initialize for faster loading
      startAt: Duration.zero, // Start from beginning
      // Add error handling
      errorBuilder: (context, errorMessage) {
        print("🎬 Chewie error: $errorMessage");
        return Container(
          color: Colors.black,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  'Video Playback Error',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => retryVideoInitialization(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
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
      
      // Handle specific cleartext HTTP error
      if (error.contains('CleartextNotPermittedException') || 
          error.contains('Cleartext HTTP traffic not permitted')) {
        videoError.value = 'Network security error: HTTP traffic not allowed. Please check your network configuration.';
        Get.snackbar(
          'Network Error',
          'HTTP video streaming is blocked. Please contact support.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.wifi_off, color: Colors.white),
          duration: const Duration(seconds: 5),
        );
      } else if (error.contains('Source error')) {
        videoError.value = 'Video source error: Unable to load video stream. Please try again.';
        Get.snackbar(
          'Video Error',
          'Unable to load video. Please check your connection and try again.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
      } else {
        videoError.value = error;
      }
    }
  }

  void _videoProgressListener() {
    if (videoPlayerController != null && videoPlayerController!.value.isInitialized) {
      final position = videoPlayerController!.value.position;
      final duration = videoPlayerController!.value.duration;
      
      // Update current position
      currentVideoPosition.value = position.inSeconds;
      totalVideoDuration.value = duration.inSeconds;
      
      // Update last watched seconds
      lastWatchedSeconds.value = position.inSeconds;
      
      // Check if video is completed (90% watched)
      if (duration.inSeconds > 0) {
        final progressPercentage = (position.inSeconds / duration.inSeconds) * 100;
        if (progressPercentage >= 90 && !isCompleted.value) {
          isCompleted.value = true;
          print("🎉 Video completed! Watched ${progressPercentage.toStringAsFixed(1)}%");
          // Update progress immediately when completed
          _updateLessonProgress();
          // Check if course should be marked as complete
          checkCourseCompletion();
        }
      }
    }
  }

  void _disposeVideoPlayer() {
    chewieController?.dispose();
    chewieController = null;
    videoPlayerController?.dispose();
    videoPlayerController = null;
    isPlayerInitialized.value = false;
  }

  // Start progress tracking timer
  void _startProgressTracking() {
    if (!isProgressTrackingEnabled.value) return;
    
    progressUpdateTimer?.cancel();
    progressUpdateTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (isProgressTrackingEnabled.value && videoPlayerController != null) {
        _updateLessonProgress();
      }
    });
    print("⏰ Progress tracking started - updating every 30 seconds");
  }

  // Stop progress tracking timer
  void _stopProgressTracking() {
    progressUpdateTimer?.cancel();
    progressUpdateTimer = null;
    isProgressTrackingEnabled.value = false;
    print("⏹️ Progress tracking stopped");
  }

  // Update lesson progress on dispose
  Future<void> _updateLessonProgressOnDispose() async {
    if (enrollmentId.value > 0 && lessonId.value > 0) {
      print("💾 Updating lesson progress on dispose...");
      await _updateLessonProgress();
    }
  }

  // Update lesson progress API call
  Future<void> _updateLessonProgress() async {
    if (enrollmentId.value <= 0 || lessonId.value <= 0) {
      print("⚠️ Cannot update progress - missing enrollmentId or lessonId");
      return;
    }

    try {
      String? token = sharedPrefHelper.getString(SharedPrefHelper.token);
      if (token == null) {
        print("❌ No authentication token available");
        return;
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      Map<String, dynamic> body = {
        "enrollmentId": enrollmentId.value,
        "lessonId": lessonId.value,
        "completed": isCompleted.value,
        "lastWatchedSeconds": lastWatchedSeconds.value
      };

      print("📤 Updating lesson progress: $body");

      final response = await NetworkService.makePostRequest(
        url: '${ApiUrl.baseUrl}/api/v1/lesson-progress',
        headers: headers,
        body: body,
      );

      if (response["statusCode"] == 200 || response["statusCode"] == 201) {
        print("✅ Lesson progress updated successfully");
        print("📊 Progress: ${lastWatchedSeconds.value}s watched, Completed: ${isCompleted.value}");
      } else {
        print("❌ Failed to update lesson progress: ${response["response"]}");
      }
    } catch (e) {
      print("❌ Error updating lesson progress: $e");
    }
  }

  // Retry video initialization
  Future<void> retryVideoInitialization() async {
    await initializeVideoPlayer();
  }

  // Check if video is ready for playback - always return true to allow playback
  bool isVideoReadyForPlayback() {
    return true; // Always allow playback regardless of status
  }

  // Check enrollment status - always allow access
  Future<void> checkEnrollmentStatus() async {
    // Always allow access - no enrollment restrictions
    isEnrolled.value = true;
    print('Access granted - no enrollment restrictions');
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
    // Don't dispose video player - allow continued playback
    Get.snackbar(
      'Preview Ended',
      'You can continue watching the video',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.play_arrow, color: Colors.white),
    );
  }

  Future<File> _downloadCompleteVideo(String url, Map<String, String>? headers, int fileSize) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/lesson_${lessonId.value}_complete.mp4';
    final file = File(path);
    
    print("💾 Starting complete video download to: $path");
    print("📏 Expected file size: $fileSize bytes");
    
    try {
      // Download the complete video using a single request
      final dio = Dio();
      final response = await dio.get<ResponseBody>(
        url,
        options: Options(
          responseType: ResponseType.stream,
          headers: headers,
          followRedirects: true,
          validateStatus: (s) => (s ?? 500) < 400,
        ),
      );
      
      if (response.statusCode == 200) {
        final sink = file.openWrite();
        await response.data!.stream.pipe(sink as StreamConsumer<Uint8List>);
        await sink.flush();
        await sink.close();
        
        print("✅ Complete video download finished: ${file.lengthSync()} bytes");
        
        // Verify the download
        if (file.lengthSync() != fileSize) {
          throw Exception('Download size mismatch. Expected: $fileSize, Got: ${file.lengthSync()}');
        }
        
        return file;
      } else {
        throw Exception('Download failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print("❌ Error downloading complete video: $e");
      rethrow;
    }
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
    const chunkSize = 2 * 1024 * 1024; // 2MB chunks for better performance
    final sink = file.openWrite();
    
    try {
      for (int start = 0; start < fileSize; start += chunkSize) {
        final end = (start + chunkSize - 1).clamp(0, fileSize - 1);
        final range = 'bytes=$start-$end';
        
        print("📥 Downloading chunk: $range (${((start / fileSize) * 100).toStringAsFixed(1)}%)");
        
        // Retry mechanism for each chunk
        bool chunkDownloaded = false;
        int chunkRetries = 0;
        const maxChunkRetries = 3;
        
        while (!chunkDownloaded && chunkRetries < maxChunkRetries) {
          try {
            final response = await NetworkService.makeRangeRequest(
              url: url,
              range: range,
              headers: headers,
            );
            
            if (response['statusCode'] == 206) {
              final chunkData = response['response'] as List<int>;
              sink.add(chunkData);
              print("✅ Chunk downloaded: ${chunkData.length} bytes");
              chunkDownloaded = true;
            } else if (response['statusCode'] == 200) {
              // Server doesn't support range requests, download entire file
              print("⚠️ Server doesn't support range requests, downloading entire file");
              final chunkData = response['response'] as List<int>;
              sink.add(chunkData);
              chunkDownloaded = true;
              break; // Exit the chunk loop since we got the whole file
            } else {
              print("❌ Chunk download failed with status: ${response['statusCode']}");
              chunkRetries++;
              if (chunkRetries < maxChunkRetries) {
                print("🔄 Retrying chunk download (attempt ${chunkRetries + 1}/$maxChunkRetries)");
                await Future.delayed(Duration(seconds: 1));
              }
            }
          } catch (e) {
            print("❌ Chunk download error: $e");
            chunkRetries++;
            if (chunkRetries < maxChunkRetries) {
              print("🔄 Retrying chunk download (attempt ${chunkRetries + 1}/$maxChunkRetries)");
              await Future.delayed(Duration(seconds: 1));
            }
          }
        }
        
        if (!chunkDownloaded) {
          throw Exception('Failed to download chunk after $maxChunkRetries attempts');
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

  // Debug method to print comprehensive video information
  void printVideoDebugInfo() {
    print("🔍 === VIDEO DEBUG INFO ===");
    print("📚 Lesson: ${lesson?.lessonName}");
    print("🎥 Video ID: ${lesson?.video.videoId}");
    print("📊 Video Status: ${lesson?.video.processingStatus}");
    print("🌐 Base URL: ${ApiUrl.getStremeUsingRange}");
    print("🔗 Full URL: ${getVideoStreamUrlWithFallback()}");
    print("🔒 HTTPS URL: ${getVideoStreamUrl()}");
    print("📱 Player Initialized: ${isPlayerInitialized.value}");
    print("❌ Video Error: ${videoError.value}");
    print("⏳ Video Loading: ${isVideoLoading.value}");
    print("🎯 Preview Mode: ${previewMode.value}");
    print("📚 Enrolled: ${isEnrolled.value}");
    print("🔍 === END DEBUG INFO ===");
  }

  // Test method to check video URL accessibility
  Future<void> testVideoUrl() async {
    if (lesson == null) {
      print("❌ No lesson data available");
      return;
    }

    final url = getVideoStreamUrl();
    print("🔍 Testing range video URL: $url");
    
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

      print("🌐 Making HEAD request to test range URL...");
      final response = await NetworkService.makeHeadRequest(
        url: url,
        headers: headers,
      );

      print("📊 Response status: ${response['statusCode']}");
      print("📋 Response headers: ${response['headers']}");
      
      if (response['statusCode'] == 200) {
        print("✅ Range video URL is accessible");
        final contentLength = response['headers']?['content-length']?.first;
        final acceptRanges = response['headers']?['accept-ranges']?.first;
        print("📏 Content-Length: $contentLength");
        print("🎯 Accept-Ranges: $acceptRanges");
      } else {
        print("❌ Range video URL returned status: ${response['statusCode']}");
      }
    } catch (e) {
      print("❌ Error testing range video URL: $e");
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
        final contentRange = response['headers']?['content-range']?.first;
        print("📏 Content-Range: $contentRange");
      } else if (response['statusCode'] == 200) {
        print("⚠️ Range request returned 200 (full content) - server may not support range requests");
      } else {
        print("❌ Range request failed with status: ${response['statusCode']}");
      }
    } catch (e) {
      print("❌ Error testing range request: $e");
    }
  }

  // Test server's range request support
  Future<bool> testServerRangeSupport(String url, Map<String, String>? headers) async {
    try {
      print("🔍 Testing server range support for: $url");
      
      // Test with a small range request
      final response = await NetworkService.makeRangeRequest(
        url: url,
        range: 'bytes=0-1023',
        headers: headers,
      );
      
      final statusCode = response['statusCode'];
      print("📊 Range test response: $statusCode");
      
      if (statusCode == 206) {
        print("✅ Server supports range requests");
        return true;
      } else if (statusCode == 200) {
        print("⚠️ Server doesn't support range requests (returned full content)");
        return false;
      } else {
        print("❌ Server range test failed with status: $statusCode");
        return false;
      }
    } catch (e) {
      print("❌ Error testing server range support: $e");
      return false;
    }
  }

  // Test video URL connectivity with multiple attempts
  Future<bool> testVideoUrlConnectivity(String url, Map<String, String>? headers) async {
    try {
      print("🌐 Testing video URL connectivity: $url");
      
      // First try HEAD request
      final headResponse = await NetworkService.makeHeadRequest(url: url, headers: headers);
      print("📊 HEAD request status: ${headResponse['statusCode']}");
      
      if (headResponse['statusCode'] == 200) {
        print("✅ Video URL is accessible via HEAD request");
        return true;
      }
      
      // If HEAD fails, try GET request with small range
      print("🔄 HEAD failed, trying range request...");
      final rangeResponse = await NetworkService.makeRangeRequest(
        url: url,
        range: 'bytes=0-1023',
        headers: headers,
      );
      
      print("📊 Range request status: ${rangeResponse['statusCode']}");
      
      if (rangeResponse['statusCode'] == 206 || rangeResponse['statusCode'] == 200) {
        print("✅ Video URL is accessible via range request");
        return true;
      }
      
      print("❌ Video URL is not accessible");
      return false;
      
    } catch (e) {
      print("❌ Error testing video URL connectivity: $e");
      
      // Check if it's a cleartext HTTP error
      if (e.toString().contains('CleartextNotPermittedException') || 
          e.toString().contains('Cleartext HTTP traffic not permitted')) {
        print("🔒 Cleartext HTTP error detected - trying HTTPS fallback");
        return false;
      }
      
      return false;
    }
  }

  void addComment() {
    // TODO: Implement comment functionality
    Get.snackbar('Comments', 'Comment functionality coming soon');
  }

  // Manual progress update method for testing
  Future<void> updateProgressManually() async {
    await _updateLessonProgress();
    Get.snackbar(
      'Progress Updated',
      'Lesson progress has been updated successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check, color: Colors.white),
    );
  }

  // Rating methods
  void setRating(int rating) {
    userRating.value = rating;
    ratingError.value = '';
    print("⭐ Rating set to: $rating");
  }

  void setComment(String comment) {
    userComment.value = comment;
    ratingError.value = '';
  }

  Future<void> submitRating() async {
    if (enrollmentId.value <= 0) {
      ratingError.value = 'Enrollment ID is required';
      Get.snackbar(
        'Error',
        'Enrollment ID is required',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    if (userRating.value <= 0) {
      ratingError.value = 'Please select a rating';
      Get.snackbar(
        'Error',
        'Please select a rating',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    try {
      isRatingLoading.value = true;
      ratingError.value = '';

      String? token = sharedPrefHelper.getString(SharedPrefHelper.token);
      if (token == null) {
        ratingError.value = 'Authentication required';
        Get.snackbar(
          'Error',
          'Authentication required',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
        return;
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      Map<String, dynamic> body = {
        "enrollmentId": enrollmentId.value,
        "rating": userRating.value,
        "comment": userComment.value.isNotEmpty ? userComment.value : "Good lesson content"
      };

      print("📤 Submitting rating: $body");

      final response = await NetworkService.makePostRequest(
        url: '${ApiUrl.baseUrl}/api/v1/ratings/rate',
        headers: headers,
        body: body,
      );

      if (response["statusCode"] == 200 || response["statusCode"] == 201) {
        isRatingSubmitted.value = true;
        print("✅ Rating submitted successfully");
        Get.snackbar(
          'Rating Submitted',
          'Thank you for rating this lesson!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.star, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
      } else {
        ratingError.value = response["response"]?.toString() ?? 'Failed to submit rating';
        print("❌ Failed to submit rating: ${response["response"]}");
        Get.snackbar(
          'Error',
          'Failed to submit rating. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      ratingError.value = 'An error occurred while submitting rating';
      print("❌ Error submitting rating: $e");
      Get.snackbar(
        'Error',
        'An error occurred while submitting rating',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isRatingLoading.value = false;
    }
  }

  void resetRating() {
    userRating.value = 0;
    userComment.value = '';
    isRatingSubmitted.value = false;
    ratingError.value = '';
  }

  // Average rating methods
  Future<void> fetchAverageRating() async {
    if (lesson?.courseId == null) {
      print("⚠️ Cannot fetch average rating - no course ID available");
      return;
    }

    try {
      isAverageRatingLoading.value = true;
      averageRatingError.value = '';

      String? token = sharedPrefHelper.getString(SharedPrefHelper.token);
      if (token == null) {
        averageRatingError.value = 'Authentication required';
        return;
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      final courseId = lesson!.courseId;
      final url = '${ApiUrl.baseUrl}api/v1/ratings/average-rating/$courseId';
      
      print("📤 Fetching average rating for course ID: $courseId");
      print("🌐 URL: $url");

      final response = await NetworkService.makeGetRequest(
        url: url,
        headers: headers,
      );

      if (response["statusCode"] == 200) {
        final data = response['response'];
        averageRating.value = (data['averageRating'] ?? 0.0).toDouble();
        totalRating.value = data['totalRating'] ?? 0;
        print("✅ Average rating fetched successfully: ${averageRating.value} (${totalRating.value} ratings)");
      } else {
        averageRatingError.value = response["response"]?.toString() ?? 'Failed to fetch average rating';
        print("❌ Failed to fetch average rating: ${response["response"]}");
      }
    } catch (e) {
      averageRatingError.value = 'An error occurred while fetching average rating';
      print("❌ Error fetching average rating: $e");
    } finally {
      isAverageRatingLoading.value = false;
    }
  }

  String getRatingText(double rating) {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 3.5) return 'Very Good';
    if (rating >= 2.5) return 'Good';
    if (rating >= 1.5) return 'Fair';
    if (rating >= 0.5) return 'Poor';
    return 'No Rating';
  }

  Color getRatingColor(double rating) {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.blue;
    if (rating >= 2.0) return Colors.orange;
    if (rating >= 1.0) return Colors.red;
    return Colors.grey;
  }

  // Course completion methods
  Future<void> markCourseAsComplete() async {
    if (enrollmentId.value <= 0) {
      courseCompletionError.value = 'Enrollment ID is required';
      Get.snackbar(
        'Error',
        'Enrollment ID is required',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
      return;
    }

    try {
      isCourseCompletionLoading.value = true;
      courseCompletionError.value = '';

      String? token = sharedPrefHelper.getString(SharedPrefHelper.token);
      if (token == null) {
        courseCompletionError.value = 'Authentication required';
        Get.snackbar(
          'Error',
          'Authentication required',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
        return;
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      print("📤 Marking course as complete for enrollment ID: ${enrollmentId.value}");

      final response = await NetworkService.makePostRequest(
        url: '${ApiUrl.baseUrl}/api/v1/enrollments/${enrollmentId.value}/complete',
        headers: headers,
        body: {}, // Empty body as per API specification
      );

      if (response["statusCode"] == 200 || response["statusCode"] == 201) {
        isCourseCompleted.value = true;
        print("✅ Course marked as complete successfully");
        Get.snackbar(
          'Course Completed!',
          'Congratulations! You have successfully completed this course.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.celebration, color: Colors.white),
          duration: const Duration(seconds: 5),
        );
      } else {
        courseCompletionError.value = response["response"]?.toString() ?? 'Failed to mark course as complete';
        print("❌ Failed to mark course as complete: ${response["response"]}");
        Get.snackbar(
          'Error',
          'Failed to mark course as complete. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      courseCompletionError.value = 'An error occurred while marking course as complete';
      print("❌ Error marking course as complete: $e");
      Get.snackbar(
        'Error',
        'An error occurred while marking course as complete',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isCourseCompletionLoading.value = false;
    }
  }

  // Check if course should be marked as complete
  void checkCourseCompletion() {
    // This method can be called when all lessons in a course are completed
    // For now, we'll call it when the current lesson is completed
    if (isCompleted.value && !isCourseCompleted.value) {
      print("🎓 Lesson completed, checking if course should be marked as complete");
      // You can add additional logic here to check if all lessons are completed
      // For now, we'll mark the course as complete when this lesson is completed
      markCourseAsComplete();
    }
  }
}
