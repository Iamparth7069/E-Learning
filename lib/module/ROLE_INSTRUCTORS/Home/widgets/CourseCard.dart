import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shaktihub/module/ROLE_INSTRUCTORS/CourseManagment/AddCourse/Screen/AddCourse.dart';
import '../Model/CourseModel.dart';
import '../controller/homeScreenInstructorController.dart';

class CourseCardManagment extends StatelessWidget {
  final CourseModel course;

  const CourseCardManagment({super.key, required this.course});

  @override
  Widget build(BuildContext context) {

    final controller = Get.find<HomeScreenInstructorController>();
    final isEnabled = RxBool(course.enabled ?? false);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔽 Course Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              course.image!.imageUrl,
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(
                height: 180,
                child: Center(child: Icon(Icons.broken_image, size: 50)),
              ),
            ),
          ),

          // 🔽 Course Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.courseName!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  course.courseDescription!,
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 12),

                // 🔽 Status Row
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isEnabled.value! ? Icons.check_circle : Icons.cancel,
                          color: isEnabled.value! ? Colors.green : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(isEnabled.value! ? "Enabled" : "Disabled"),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final val = await Get.to(() => AddCourse(course: course,));
                       },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size(70, 30), // square size
                        padding: EdgeInsets.zero, // remove internal padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4), // square-like edges
                          side: const BorderSide(color: Colors.blueAccent),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Edit",
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ),

                  ],
                ),),

                 SizedBox(height: 12),

                // 🔽 Toggle Switch
                Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Toggle Course Status",
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: isEnabled.value,
                      onChanged: (value) async {

                        print("Toggled Course ID: ${course.courseId}");
                        print("New Status: $value");
                        isEnabled.value  = await controller.courseManage(value,course.courseId);

                      },
                      activeColor: Colors.indigo,
                    ),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
