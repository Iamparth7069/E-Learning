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
                  
                  // Image Section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.image, color: Colors.blue),
                            SizedBox(width: 8),
                            Text("Lesson Image", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              icon: controller.isImageProcessing
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.image),
                              label: Text(controller.isImageProcessing ? "Processing..." : "Pick Image"),
                              onPressed: controller.isImageProcessing ? null : controller.pickImage,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: controller.pickedImage != null
                                  ? Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.file(
                                            controller.pickedImage!,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("New image selected", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                              Text("Ready to upload", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  : controller.imageUrl != null
                                      ? Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                controller.imageUrl!,
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    Container(
                                                      width: 60,
                                                      height: 60,
                                                      color: Colors.grey[300],
                                                      child: Icon(Icons.broken_image),
                                                    ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("Current image", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                                  Text("From server", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text("No image selected", style: TextStyle(color: Colors.grey)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Video Section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.video_collection, color: Colors.red),
                            SizedBox(width: 8),
                            Text("Lesson Video", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Video Processing Progress
                        if (controller.isVideoProcessing) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                controller.videoProcessingStatus,
                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: controller.videoCompressionProgress,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${(controller.videoCompressionProgress * 100).toStringAsFixed(0)}% completed",
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ] else ...[
                          Row(
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.video_collection),
                                label: const Text("Pick Video"),
                                onPressed: controller.pickVideo,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: controller.pickedVideo != null
                                    ? Row(
                                        children: [
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: Colors.red[100],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(Icons.video_file, color: Colors.red, size: 30),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("New video selected", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                                Text("Compressed and ready", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : controller.videoUrl != null
                                        ? Row(
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[100],
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Icon(Icons.cloud_done, color: Colors.blue, size: 30),
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("Current video", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                                                    Text("From server", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text("No video selected", style: TextStyle(color: Colors.grey)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Submit Button with Loading States
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: controller.isLoading
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  lesson != null ? "Updating Lesson..." : "Submitting Lesson...",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        : ElevatedButton(
                            onPressed: controller.isVideoProcessing || controller.isImageProcessing
                                ? null
                                : () async {
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
                                    print("Result is " + result.toString());

                                    if (result) {
                                      Get.back(result: true);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: Colors.grey[300],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              controller.isVideoProcessing || controller.isImageProcessing
                                  ? "Processing media..."
                                  : lesson != null
                                      ? "Update Lesson"
                                      : "Submit Lesson",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                  
                  // Processing Status
                  if (controller.isVideoProcessing || controller.isImageProcessing)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        controller.isVideoProcessing
                            ? "Please wait while the video is being processed..."
                            : "Processing image...",
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
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
