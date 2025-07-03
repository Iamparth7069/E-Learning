import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Home/model/subCategoryModel.dart';
import '../controller/CategoryController.dart';

class UpdateSubCategory extends StatelessWidget {
  UpdateSubCategory({super.key});

  final controller = Get.isRegistered<CategoryController>()
      ? Get.find<CategoryController>()
      : Get.put(CategoryController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update SubCategory')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: GetBuilder<CategoryController>(
          builder: (controller) {
            if (controller.isLoading.value && controller.subCategory.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                DropdownButton<int>(
                  isExpanded: true,
                  hint: Text('Select a Category'),
                  value: controller.allCategory
                      .any((cat) => cat.categoryId == controller.selectedCategoryId.value)
                      ? controller.selectedCategoryId.value
                      : null,
                  items: controller.allCategory
                      .map((cat) => DropdownMenuItem<int>(
                    child: Text(cat.name),
                    value: cat.categoryId,
                  ))
                      .toList(),
                  onChanged: (newId) async {
                    controller.selectedCategoryId.value = newId!;
                    await controller.getAllSubCategory(newId); // fetch subcategories

                    // Set first subcategory as selected (if any)
                    if (controller.subCategory.isNotEmpty) {
                      controller.selectSubCategoryId.value = controller.subCategory.first.subCategoryId;
                      controller.updateCategoryController.text = controller.subCategory.first.name;
                    } else {
                      controller.selectSubCategoryId.value = 0;
                      controller.updateCategoryController.clear();
                    }

                    controller.update(); // force UI rebuild
                  },
                ),
                SizedBox(height: 20),

                DropdownButton<int>(
                  isExpanded: true,
                  hint: Text('Select a SubCategory'),
                  value: controller.subCategory.any(
                          (cat) => cat.subCategoryId == controller.selectSubCategoryId.value)
                      ? controller.selectSubCategoryId.value
                      : null,
                  items: controller.subCategory.map((cat) => DropdownMenuItem<int>(
                    child: Text(cat.name),
                    value: cat.subCategoryId,
                  )).toList(),
                  onChanged: (newId) {
                    controller.selectSubCategoryId.value = newId!;
                    final selected = controller.subCategory.firstWhere(
                            (sub) => sub.subCategoryId == newId);
                    controller.updateCategoryController.text = selected.name;
                    controller.update(); // Refresh UI
                  },
                ),

                SizedBox(height: 20),

                TextField(
                  controller: controller.updateCategoryController,
                  decoration: InputDecoration(
                    labelText: 'Update Category',
                    border: OutlineInputBorder(),
                  ),
                  enabled: controller.selectSubCategoryId.value != 0,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: controller.selectSubCategoryId.value != 0 &&
                      controller.updateCategoryController.text.isNotEmpty
                      ? () async {
                    await controller.updateSubCategory();
                    controller.update(); // Refresh UI after update
                  }
                      : null,
                  child: Text('Update SubCategory'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
