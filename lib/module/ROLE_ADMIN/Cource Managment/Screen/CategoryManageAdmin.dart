import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shaktihub/module/ROLE_ADMIN/Cource%20Managment/Model/CourceModel.dart';

import '../Controller/CateogryController.dart';

class CategoryManagmentAdmin extends StatelessWidget {
   CategoryManagmentAdmin({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Courses',style: TextStyle(fontSize: 30,fontWeight: FontWeight.w500),)),
      body: GetBuilder<CourseManagment>(
        init: CourseManagment(),
        builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Text('Popular Courses',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
                // Horizontal row for the first few courses
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 270,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.getAllCouceData.length, // First 3 horizontally
                    itemBuilder: (context, index) {
                      return CourseCard( controller.getAllCouceData[index]);
                    },
                  ),
                ),
                SizedBox(height: 16),
                Text('All Courses',style: TextStyle(fontSize: 20,fontWeight: FontWeight.w500),),
                SizedBox(height: 16),

                // Vertical list for the rest
                Expanded(
                  child: GridView.builder(

                    itemCount: controller.getAllCouceData.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 columns
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 15,
                      childAspectRatio: 3 / 3.7,
                    ),
                    itemBuilder: (context, index) {
                      return CourseCard(controller.getAllCouceData[index]);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}




class CourseCard extends StatelessWidget {
  final Course coursel;
  final VoidCallback? onTap;

  const CourseCard(this.coursel, {this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Optional: add navigation or detail view
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 200,
        height: 550,
        margin: const EdgeInsets.only(right: 12, bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Image
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                coursel.image.imageUrl,
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // Course Title and Description
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coursel.courseName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    coursel.courseDescription,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

