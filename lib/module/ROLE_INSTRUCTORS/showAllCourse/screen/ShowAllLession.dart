import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../AddLession/Screen/AddLessonScreen.dart';
import '../controller/ShowAllLessionController.dart';

class ShowLession extends StatelessWidget {
  final int courseId;
  const ShowLession({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShowAllLessionController(courseId));

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add,size: 34,color: Colors.white,),
        onPressed: () {
          Get.to(AddLessonScreen(courseId: courseId));
      },),
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
              // Force rebuild by re-calling the controller method
              await controller.loadAllLession();
            },
          ),
        ],
        elevation: 4,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),

      // ✅ FutureBuilder with actual function call
      body: FutureBuilder(
        future: controller.loadAllLession(), // ✅ important: CALL the method
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ Error: ${snapshot.error}'));
          } else if (controller.allLessons.isEmpty) {
            return const Center(child: Text("No lessons found"));
          }
          return ListView.builder(
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
                  onTap: () {
                    // Navigate to detail or play video
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
