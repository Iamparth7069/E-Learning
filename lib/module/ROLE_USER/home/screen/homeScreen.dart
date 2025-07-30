import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';

import '../../viewlession/Screen/ShowLession.dart';
import '../controller/homeScreenController.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenController>(
      init: HomeScreenController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 2,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            ),
            title: Row(
              children: [
                Icon(Icons.menu_book, color: Colors.deepPurple,size: 34,),
                const SizedBox(width: 8),
                const Text(
                  "Courses",
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.black,size: 24),
                onPressed: () {

                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.black,size: 24),
                onPressed: () {

                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          body: controller.isLoading ? Center(
            child: SpinKitFadingCircle(
              color: Theme.of(context).primaryColor,
              size: 50.0,
            ),
          ) :ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text("Popular Courses", style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 1),
              SizedBox(
                height: 35.h,
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.allPopularCourse.length,
                  itemBuilder: (context, index) {
                    final course = controller.allPopularCourse[index];
                    final imageUrl = course.image?.imageUrl;

                    return GestureDetector(
                      onTap: () {

                      },
                      child: Container(
                        width: 50.w,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 6,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl ?? '',
                                height: 14.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Image.asset("assets/images/search.png", fit: BoxFit.cover),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                course.courseName ?? "Untitled",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                course.courseDescription ?? '',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.people, size: 23, color: Colors.grey[600]),
                                  SizedBox(width: 4),
                                  Text(
                                    '${course.enrollmentCount} enrolled',
                                    style: TextStyle(fontSize: 15.sp, color: Colors.grey[700]),
                                  ),
                                  Spacer(),
                                  Icon(Icons.star, size: 23, color: Colors.amber),
                                  SizedBox(width: 4),
                                  Text(
                                    course.averageRating.toStringAsFixed(1),
                                    style: TextStyle(fontSize: 15.sp, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ),

                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(double.infinity, 36),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Get.to(() => ShowLessionStudent(controller.allCourses[index].courseId!));
                                },
                                child: const Text("View"),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text("All Courses", style: TextStyle(fontSize: 19.sp, fontWeight: FontWeight.bold)),
              ),

              GridView.builder(
                shrinkWrap: true,
                itemCount: controller.allCourses.length,
                padding: const EdgeInsets.all(12),
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  final course = controller.allCourses[index];
                  final imageUrl = course.image?.imageUrl;

                  return GestureDetector(
                    onTap: () {
                      Get.to(() => ShowLessionStudent(controller.allCourses[index].courseId!));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(2, 2),
                            blurRadius: 6,
                            spreadRadius: 1,
                            color: Colors.black.withOpacity(0.05),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl ?? '',
                              height: 15.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Image.asset(
                                "assets/images/search.png",
                                fit: BoxFit.cover,
                              ),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              course.courseName ?? "Untitled",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              course.courseDescription ?? '',
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: Size(double.infinity, 36),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                // Action (e.g., Enroll or View)
                              },
                              child: const Text("View"),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
