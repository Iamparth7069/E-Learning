import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Controller/AddLessonController.dart';

class AddLessonScreen extends StatelessWidget {
  final int courseId;

  const AddLessonScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddLessonController(courseId: courseId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {
          Get.back();
        }, icon: Icon(Icons.arrow_back,color: Colors.white,)),
        title: const Text("Add Lesson",style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 12,
              ),
              TextField(
                onChanged: controller.setLessonName,
                decoration: const InputDecoration(
                  labelText: "Lesson Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: controller.setLessonContent,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Lesson Content",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text("Enable Lesson"),
                  const SizedBox(width: 10),
                  Switch(
                    value: controller.isEnabled.value,
                    onChanged: controller.toggleEnabled,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text("Pick Image"),
                    onPressed: controller.pickImage,
                  ),
                  const SizedBox(width: 10),
                  controller.pickedImage.value != null
                      ? Image.file(
                    controller.pickedImage.value!,
                    width: 60,
                    height: 60,
                  )
                      : const Text("No Image"),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.video_collection),
                    label: const Text("Pick Video"),
                    onPressed: controller.pickVideo,
                  ),
                  const SizedBox(width: 10),
                  controller.pickedVideo.value != null
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Text("No Video"),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(

                  onPressed: () async {
                    await controller.submitLesson();
                  },
                  child: const Text("Submit Lesson"),
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}
