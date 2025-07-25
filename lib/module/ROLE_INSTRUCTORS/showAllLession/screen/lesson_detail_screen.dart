import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/lesson_controller.dart';

class LessonDetailScreen extends StatelessWidget {
  final int lessonId;

  const LessonDetailScreen({super.key, required this.lessonId});
  @override
  Widget build(BuildContext context) {
    final LessonController controller = Get.put(LessonController());

    // Fetch lesson
    controller.fetchLessonDetail(lessonId);

    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to Edit Screen
                  print("Edit tapped");
                },
                icon: const Icon(Icons.edit,color: Colors.white),
                label: const Text("Edit",style: TextStyle(color: Colors.white,fontSize: 18),),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.defaultDialog(
                    title: "Delete Lesson",
                    middleText: "Are you sure you want to delete this lesson?",
                    textConfirm: "Yes",
                    textCancel: "Cancel",
                    confirmTextColor: Colors.white,
                    cancelTextColor: Colors.deepPurple,
                    buttonColor: Colors.red,
                    onConfirm: () {
                      // Call your delete function here
                      controller.deleteLession(lessonId); // you should implement this in your controller
                      Get.back(); // Close the dialog
                      Get.back(); // Go back to previous screen after deletion (optional)
                    },
                    onCancel: () {
                      // Just close the dialog
                    },
                  );
                },

                icon: const Icon(Icons.delete,color: Colors.white,size: 18,),
                label: const Text("Delete",style: TextStyle(color: Colors.white,fontSize: 18),),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Lesson Details", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final lesson = controller.lesson.value;

        if (lesson == null) {
          return const Center(child: Text("Lesson not found."));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() {
                if (controller.isVideoReady.value && controller.chewieController != null) {
                  return SizedBox(
                    width: double.infinity,
                    height: 220,
                    child: Chewie(controller: controller.chewieController!),
                  );
                } else {
                  return SizedBox(
                    height: 220,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              }),

              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  lesson.lessonName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  lesson.lessonContent,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text("Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text("No comments yet. Be the first to comment."),
              ),
              const SizedBox(height: 60),
            ],
          ),
        );
      }),
    );
  }
}
