import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../AddLession/Screen/ManageLessionScreen.dart';
import '../controller/lesson_controller.dart';

class LessonDetailScreen extends StatefulWidget {
  final int lessonId;

  const LessonDetailScreen({super.key, required this.lessonId});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  late LessonController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(LessonController());
    controller.fetchLessonDetail(widget.lessonId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.deepPurple,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Get.back(),
      ),
      title: Obx(() => Text(
        controller.lesson.value?.lessonName ?? "Lesson Details",
        style: const TextStyle(color: Colors.white, fontSize: 18),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      )),
      actions: [
        Obx(() => IconButton(
          onPressed: controller.isLoading.value ? null : () => controller.refreshLesson(),
          icon: controller.isLoading.value
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.refresh, color: Colors.white),
        )),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: controller.lesson.value == null
                  ? null
                  : () async {
                      final result = await Get.to(() => ManageLessionScreen(
                        courseId: controller.lesson.value!.courseId,
                        lesson: controller.lesson.value,
                      ));

                      if (result == true) {
                        controller.refreshLesson();
                      }
                    },
              icon: const Icon(Icons.edit),
              label: const Text("Edit Lesson"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: controller.lesson.value == null || controller.isDeleting.value
                  ? null
                  : () => _showDeleteConfirmation(),
              icon: controller.isDeleting.value
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.delete),
              label: Text(controller.isDeleting.value ? "Deleting..." : "Delete"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }
  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Loading lesson...", style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      }

      final lesson = controller.lesson.value;

      if (lesson == null) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "Lesson not found",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.refreshLesson(),
                child: Text("Retry"),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshLesson(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVideoPlayer(),
              _buildLessonInfo(lesson),
              _buildLessonStats(lesson),
              _buildCommentsSection(),
              SizedBox(height: 100), // Space for bottom navigation
            ],
          ),
        ),
      );
    });
  }

  Widget _buildVideoPlayer() {
    return Container(
      color: Colors.black,
      child: Obx(() {
        if (controller.isVideoLoading.value) {
          return SizedBox(
            height: 220,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    "Loading video...",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.videoError.value.isNotEmpty) {
          return Container(
            height: 220,
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
                    controller.videoError.value,
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.refreshLesson(),
                    child: Text("Retry"),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.isVideoReady.value && controller.chewieController != null) {
          return SizedBox(
            width: double.infinity,
            height: 220,
            child: Chewie(controller: controller.chewieController!),
          );
        }

        return SizedBox(
          height: 220,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_library, color: Colors.grey, size: 60),
                SizedBox(height: 16),
                Text(
                  "No video available",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLessonInfo(lesson) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson.lessonName ?? "Untitled Lesson",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Sequence #${lesson.sequenceNumber ?? 1}",
              style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            lesson.lessonContent ?? "No content available",
            style: TextStyle(
              fontSize: 16,
              height: 1.6,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonStats(lesson) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Lesson Information",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          SizedBox(height: 12),
          _buildInfoRow(Icons.play_circle, "Video Status", 
            lesson.video.processingStatus == "COMPLETED" ? "Ready" : 
            lesson.video.processingStatus == "PENDING" ? "Processing" : 
            lesson.video.processingStatus),
          _buildInfoRow(Icons.image, "Has Image", 
            lesson.image != null ? "Yes" : "No"),
          _buildInfoRow(Icons.comment, "Comments", 
            "${lesson.comments?.length ?? 0} comments"),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.comment, color: Colors.deepPurple),
              SizedBox(width: 8),
              Text(
                "Comments",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            "No comments yet. Be the first to comment!",
            style: TextStyle(
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text("Delete Lesson"),
          ],
        ),
        content: Text(
          "Are you sure you want to delete this lesson? This action cannot be undone.",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back(); // Close dialog
              await controller.deleteLession(widget.lessonId);
              if (!controller.isDeleting.value) {
                Future.delayed(Duration(milliseconds: 500), () {
                  Get.back(result: widget.lessonId);
                });
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
