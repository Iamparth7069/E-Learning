import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controller/CategoryController.dart';

class UpdateCategory extends StatelessWidget {
   UpdateCategory({super.key});
   final controller = Get.isRegistered<CategoryController>()
       ? Get.find<CategoryController>()
       : Get.put(CategoryController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Category')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.allCategory.isEmpty) {
            return Center(child: CircularProgressIndicator()); // Loading first
          }
          return Column(
            children: [
              // 1️⃣ Select Category first
              DropdownButton<int>(
                isExpanded: true,
                hint: Text('Select a Category'),
                value: controller.selectedCategoryId.value == 0
                    ? null
                    : controller.selectedCategoryId.value,
                items: controller.allCategory
                    .map((cat) => DropdownMenuItem<int>(
                  child: Text(cat.name),
                  value: cat.categoryId,
                ))
                    .toList(),
                onChanged: (newId) {
                  controller.selectedCategoryId.value = newId!;
                },
              ),
              SizedBox(height: 20),
              // 2️⃣ Enable TextField only if a category is selected
              TextField(
                controller: controller.updateCategoryController,
                decoration: InputDecoration(
                    labelText: 'Update Category',
                    border: OutlineInputBorder()
                ),
                enabled: controller.updateCategoryController.value != 0,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.selectedCategoryId.value != 0 &&
                    controller.updateCategoryController.text.isNotEmpty
                    ? () async {
                  await controller.updateCategory();
                }
                    : null,
                child: Text('Update Category'),
              ),
            ],
          );
        }),
      ),

    );

  }
}
