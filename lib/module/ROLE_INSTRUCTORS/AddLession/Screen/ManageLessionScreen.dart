import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../showAllLession/model/lesson_model.dart';
import '../Controller/ManageLessionController.dart';

class ManageLessionScreen extends StatelessWidget {
  final int courseId;
  final Lesson? lesson;

  const ManageLessionScreen({
    super.key,
    required this.courseId,
    this.lesson,
  });

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          lesson != null ? "Edit Lesson" : "Add Lesson",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
      ),
      body: GetBuilder<ManageLessionController>(
        init: ManageLessionController(courseId: courseId, lession: lesson),
        builder: (controller) => Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    initialValue: controller.lessonName,
                    onChanged: controller.setLessonName,
                    validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'Lesson name is required'
                        : null,
                    decoration: const InputDecoration(
                      labelText: "Lesson Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: controller.lessonContent,
                    onChanged: controller.setLessonContent,
                    maxLines: 4,
                    validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'Lesson content is required'
                        : null,
                    decoration: const InputDecoration(
                      labelText: "Lesson Content",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text("Enable Lesson"),
                      Switch(
                        value: controller.isEnabled,
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
                      controller.pickedImage != null
                          ? Image.file(controller.pickedImage!,
                          width: 60, height: 60)
                          : controller.imageUrl != null
                          ? Image.network(controller.imageUrl!,
                          width: 60, height: 60)
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
                      controller.pickedVideo != null
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : controller.videoUrl != null
                          ? const Icon(Icons.cloud_done, color: Colors.green)
                          : const Text("No Video"),
                    ],
                  ),
                  const SizedBox(height: 24),
                  controller.isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      if (controller.pickedImage == null &&
                          controller.imageUrl == null) {
                        Get.snackbar("Error", "Please pick an image",
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                        return;
                      }

                      if (controller.pickedVideo == null &&
                          controller.videoUrl == null) {
                        Get.snackbar("Error", "Please pick a video",
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                        return;
                      }

                      bool result = await controller.submitLesson();
                      print("Result  is " + result.toString());

                      if (result) {
                        Get.back(result: true); // ✅ This now works
                      }

                    },
                    child: Text(lesson != null
                        ? "Update Lesson"
                        : "Submit Lesson"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
