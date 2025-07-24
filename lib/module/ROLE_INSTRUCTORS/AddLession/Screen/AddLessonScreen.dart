import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../Controller/AddLessonController.dart';

class AddLessonScreen extends StatelessWidget {
  final int courseId;
  const AddLessonScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text("Add Lesson", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo,
      ),
      body: GetBuilder<AddLessonController>(
        init: AddLessonController(courseId: courseId),
        builder: (controller) => Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
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
                      const SizedBox(width: 10),
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
                          ? Image.file(
                        controller.pickedImage!,
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
                      controller.pickedVideo != null
                          ? const Icon(Icons.check_circle,
                          color: Colors.green)
                          : const Text("No Video"),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: controller.isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;

                        if (controller.pickedImage == null) {
                          Get.snackbar("Error", "Please pick an image",
                              backgroundColor: Colors.red,
                              colorText: Colors.white);
                          return;
                        }

                        if (controller.pickedVideo == null) {
                          Get.snackbar("Error", "Please pick a video",
                              backgroundColor: Colors.red,
                              colorText: Colors.white);
                          return;
                        }

                        bool result = await controller.submitLesson();
                        if (result) {
                          Navigator.pop(context);
                          
                        }
                      },
                      child: const Text("Submit Lesson"),
                    ),
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
