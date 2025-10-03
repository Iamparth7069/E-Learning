import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../CourseManagment/AddCourse/Screen/AddCourse.dart';
import '../../showAllLession/screen/ShowAllLession.dart';
import '../controller/homeScreenInstructorController.dart';
import '../widgets/CourseCard.dart';
import '../widgets/SubCategoryFilter.dart';

class HomeInstructor extends StatefulWidget {
  const HomeInstructor({super.key});

  @override
  State<HomeInstructor> createState() => _HomeInstructorState();
}

class _HomeInstructorState extends State<HomeInstructor> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeScreenInstructorController())..loadCourse();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        toolbarHeight: 70,
        leadingWidth: 60,
        titleSpacing: 0,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Hello, ${c.userName.value}",
                  style: const TextStyle(fontSize: 20, color: Color(0xFF2E2E2E)),
                ),
                Obx(() {
                  final stats = c.getCourseStats();
                  return Text(
                    "${stats['total']} courses • ${stats['enabled']} active",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          Obx(() => controller.isRefreshing.value
            ? const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton(
                onPressed: () => controller.refreshData(),
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh',
              )),
          const SizedBox(width: 8),
        ],
      ),


        // ✅ BODY WITH SEARCH AND COURSE MANAGEMENT
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading courses...", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        if (controller.courseList.isEmpty) {
          // 👉 No courses at all, show "Add Course"
          return Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: const Color(0xFF4C5BD4).withOpacity(0.2),
              onTap: () async {
                final result = await Get.to(() => AddCourse());
                if (result == true) {
                  controller.refreshData();
                }
              },
              child: Container(
                width: 280,
                height: 280,
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
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline,
                        size: 60, color: Color(0xFF4C5BD4)),
                    SizedBox(height: 20),
                    Text("Add Your First Course",
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
        }

        return CustomScrollView(
          slivers: [
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => controller.updateSearchQuery(value),
                    decoration: InputDecoration(
                      hintText: 'Search courses...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              controller.updateSearchQuery('');
                            },
                            icon: const Icon(Icons.clear, color: Colors.grey),
                          )
                        : const SizedBox()),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, 
                        vertical: 12
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Course Statistics
            SliverToBoxAdapter(
              child: Obx(() {
                final stats = controller.getCourseStats();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          "Total", 
                          stats['total']!, 
                          Colors.blue,
                          Icons.school
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          "Active", 
                          stats['enabled']!, 
                          Colors.green,
                          Icons.check_circle
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildStatCard(
                          "Inactive", 
                          stats['disabled']!, 
                          Colors.orange,
                          Icons.pause_circle
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // Courses List
            Obx(() {
              final filteredList = controller.filteredCourseList;
              
              if (filteredList.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            controller.searchQuery.value.isNotEmpty 
                              ? Icons.search_off 
                              : Icons.filter_list_off,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            controller.searchQuery.value.isNotEmpty
                              ? "No courses match your search"
                              : "No courses found for this category",
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return SliverPadding(
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
              );
            }),

            const SliverToBoxAdapter(child: SizedBox(height: 80)), // Space for bottom bar
          ],
        );
      }),


      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.to(() => AddCourse());
          if (result == true) {
            controller.refreshData();
          }
        },
        backgroundColor: const Color(0xFF4C5BD4),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add Course"),
        tooltip: "Create a new course",
      ),

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

  Widget _buildStatCard(String title, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}