import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chewie/chewie.dart';
import '../controller/lesson_controller.dart';

class RangeVideoPlayer extends StatelessWidget {
  final LessonController controller;
  final double height;

  const RangeVideoPlayer({
    Key? key,
    required this.controller,
    this.height = 220,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Obx(() {
        // Show loading state
        if (controller.isVideoLoading.value) {
          return SizedBox(
            height: height,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    controller.streamingStatus.value.isNotEmpty
                        ? controller.streamingStatus.value
                        : "Loading video...",
                    style: TextStyle(color: Colors.white),
                  ),
                  if (controller.isRangeStreaming.value) ...[
                    SizedBox(height: 8),
                    Text(
                      "Using range streaming",
                      style: TextStyle(
                        color: Colors.blue[300],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        // Show error state
        if (controller.videoError.value.isNotEmpty) {
          return Container(
            height: height,
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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      controller.videoError.value,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => controller.retryVideoLoad(),
                        icon: Icon(Icons.refresh),
                        label: Text("Retry"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          // Try alternative streaming method
                          if (controller.supportsRangeRequests.value) {
                            controller.supportsRangeRequests.value = false;
                          } else {
                            controller.supportsRangeRequests.value = true;
                          }
                          controller.retryVideoLoad();
                        },
                        icon: Icon(Icons.swap_horiz),
                        label: Text("Try Alternative"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  if (controller.retryCount.value > 0) ...[
                    SizedBox(height: 8),
                    Text(
                      "Retry attempt: ${controller.retryCount.value}/${controller.maxRetries.value}",
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        // Show video player
        if (controller.isVideoReady.value && controller.chewieController != null) {
          return SizedBox(
            width: double.infinity,
            height: height,
            child: Stack(
              children: [
                Chewie(controller: controller.chewieController!),
                // Show streaming method indicator
                if (controller.isRangeStreaming.value)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.speed,
                            color: Colors.blue[300],
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Range",
                            style: TextStyle(
                              color: Colors.blue[300],
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        // Default loading state
        return SizedBox(
          height: height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 16),
                Text(
                  "Preparing video...",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class VideoControlsOverlay extends StatelessWidget {
  final LessonController controller;

  const VideoControlsOverlay({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isVideoReady.value || controller.videoController == null) {
        return SizedBox.shrink();
      }

      return Container(
        color: Colors.black26,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Progress bar
            Container(
              height: 4,
              child: LinearProgressIndicator(
                value: controller.videoProgress.value,
                backgroundColor: Colors.grey[600],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            // Control buttons
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () {
                      // Seek backward 10 seconds
                      final currentPosition = controller.videoController!.value.position;
                      final newPosition = currentPosition - Duration(seconds: 10);
                      controller.videoController!.seekTo(newPosition);
                    },
                    icon: Icon(Icons.replay_10, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: controller.toggleVideoPlayback,
                    icon: Icon(
                      controller.isVideoPlaying.value
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // Seek forward 10 seconds
                      final currentPosition = controller.videoController!.value.position;
                      final newPosition = currentPosition + Duration(seconds: 10);
                      controller.videoController!.seekTo(newPosition);
                    },
                    icon: Icon(Icons.forward_10, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
