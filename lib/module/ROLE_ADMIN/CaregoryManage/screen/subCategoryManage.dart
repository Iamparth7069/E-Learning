import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/CategoryController.dart';

class SubCategory extends StatelessWidget {
  final controller = Get.put(CategoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Subcategory')),
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
                controller: controller.subCategoryController,
                decoration: InputDecoration(
                    labelText: 'Subcategory Name',
                    border: OutlineInputBorder()
                ),
                enabled: controller.selectedCategoryId.value != 0,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: controller.selectedCategoryId.value != 0 &&
                    controller.subCategoryController.text.isNotEmpty
                    ? () {
                  controller.addSubCategory(context);
                }
                    : null,
                child: Text('Add Subcategory'),
              ),
            ],
          );
        }),
      ),
    );
  }
}
