import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controller/StudentManagmentControllerInstructor.dart';

class StudentManagment extends StatelessWidget {
  const StudentManagment({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StudentManagmentController());

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(19.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Students", style: TextStyle(fontSize: 29)),
              const SizedBox(height: 23),
              const Text("Select Course", style: TextStyle(fontSize: 18)),

              Obx(() {
                final courses = controller.getAllCouceData;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      isExpanded: true,
                      // ✅ Set the selected value here
                      value: controller.selectedCourseId.value != 0
                          ? controller.selectedCourseId.value
                          : null,
                      hint: const Text("Choose a Course"),
                      items: courses.map((cat) {
                        return DropdownMenuItem<int>(
                          value: cat.courseId,
                          child: Text(cat.courseName!),
                        );
                      }).toList(),
                      onChanged: (newId) {
                        controller.selectedCourseId.value = newId!;
                        controller.getUser(controller.selectedCourseId.value);
                      },
                    ),
                  ),
                );
              }),
              Obx(() => controller.isLoading.value
                  ? const Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: 2,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("Index $index"),
                  );
                },
              ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
