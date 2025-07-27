import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../AddLession/Screen/ManageLessionScreen.dart';
import '../controller/ShowAllLessionController.dart';
import 'lesson_detail_screen.dart';

class ShowLession extends StatelessWidget {
  final int courseId;
  const ShowLession({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShowAllLessionController(courseId));

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add, size: 34, color: Colors.white),
        onPressed: () {
          Get.to(ManageLessionScreen(courseId: courseId));
        },
      ),
      appBar: AppBar(
        title: const Text(
          'Lessons',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await controller.loadAllLession();
            },
          ),
        ],
        elevation: 4,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),

      body: GetBuilder<ShowAllLessionController>(
        builder: (controller) {
          if (controller.isLoadding) {
            return const Center(child: CircularProgressIndicator());
          } else if (controller.allLessons.isEmpty) {
            return const Center(child: Text("No lessons found"));
          }

          return RefreshIndicator(
            onRefresh: controller.loadAllLession,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: controller.allLessons.length,
              itemBuilder: (context, index) {
                final lesson = controller.allLessons[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        lesson.image?.imageUrl ?? '',
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported),
                      ),
                    ),
                    title: Text(
                      lesson.lessonName ?? '',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      lesson.lessonContent ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.play_circle_fill, color: Colors.blueAccent, size: 32),
                    onTap: () async {
                      final deletedLessonId = await Get.to(() => LessonDetailScreen(lessonId: lesson.lessonId!));
                      if (deletedLessonId != null) {
                        controller.allLessons.removeWhere((l) => l.lessonId == deletedLessonId);
                        controller.update();
                      }
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
