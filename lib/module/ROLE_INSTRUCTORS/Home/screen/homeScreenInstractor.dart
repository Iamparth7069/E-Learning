import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../AddLession/Screen/AddLessonScreen.dart';
import '../../CourseManagment/AddCourse/Screen/AddCourse.dart';
import '../../showAllCourse/screen/ShowAllLession.dart';
import '../controller/homeScreenInstructorController.dart';
import '../widgets/CourseCard.dart';
import '../widgets/SubCategoryFilter.dart';

class HomeInstructor extends StatefulWidget {
  const HomeInstructor({super.key});

  @override
  State<HomeInstructor> createState() => _HomeInstructorState();
}

class _HomeInstructorState extends State<HomeInstructor> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeScreenInstructorController())..loadCourse();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        toolbarHeight: 60,
        leadingWidth: 60, // Increased to accommodate padding
        titleSpacing: 0, // We'll handle spacing manually
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: CircleAvatar(
            backgroundColor: Color(0xFF4C5BD4),
            child: Icon(Icons.person, color: Colors.white, size: 24),
          ),
        ),
        title: GetBuilder<HomeScreenInstructorController>(
          builder: (c) => Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              "Hello, ${c.userName}",
              style: const TextStyle(fontSize: 22, color: Color(0xFF2E2E2E)),
            ),
          ),
        ),
      ),


        // ✅ BODY WITH OBSERVABLE COURSE FILTER
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

      final filteredList = controller.selectedSubCategoryId.value == 0
          ? controller.courseList
          : controller.courseList
          ?.where((course) =>
      course.subCategoryId == controller.selectedSubCategoryId.value)
          .toList();

      if (controller.courseList.isEmpty) {
        // 👉 No courses at all, show "Add Course"
        return Center(
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: const Color(0xFF4C5BD4).withOpacity(0.2),
            onTap: () {
              Get.to(AddCourse());
            },
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_circle_outline,
                      size: 60, color: Color(0xFF4C5BD4)),
                  SizedBox(height: 20),
                  Text("Add Course",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4C5BD4))),
                  SizedBox(height: 8),
                  Text("Tap to create a new course",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF777777),
                      )),
                ],
              ),
            ),
          ),
        );
      } else if (filteredList == null || filteredList.isEmpty) {
        // 👉 Courses exist, but none match the selected filter
        return const Center(
          child: Text(
            "No courses found for this subcategory.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }
      else {
        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final course = filteredList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Get.to(() => ShowLession(courseId: course.courseId));
                        },
                        child: CourseCardManagment(course: course),
                      ),
                    );
                  },
                  childCount: filteredList.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)), // optional spacing after chips


            // space for bottom bar
          ],
        );
      }
    }),


      bottomNavigationBar: SubCategoryFilterBar(

        selectedId: controller.selectedSubCategoryId,
        subCategories: controller.subCategory,
        onSelected: (id) {
          setState(() {
            controller.setSelectedSubCategory(id);
          });

        },
      ),

    );
  }
}
