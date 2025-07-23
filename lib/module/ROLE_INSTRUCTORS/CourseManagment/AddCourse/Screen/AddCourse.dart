import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:shaktihub/Constraint/extension.dart';
import '../Controller/AddCourseController.dart';

class AddCourse extends StatelessWidget {
  const AddCourse({super.key});

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<FormState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Add Course')),
      body: SingleChildScrollView(
        child: GetBuilder<AddCourseController>(
          init: AddCourseController(),
          builder: (controller) {
            if (controller.isLoading.value && controller.subCategory.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: key,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Title
                    Text(
                      "Select the Category",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
        
                    // Category Dropdown with decoration
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          isExpanded: true,
                          value: controller.allCategory.any(
                                  (cat) => cat.categoryId == controller.selectedCategoryId.value)
                              ? controller.selectedCategoryId.value
                              : null,
                          hint: const Text("Choose a Category"),
                          items: controller.allCategory.map((cat) {
                            return DropdownMenuItem<int>(
                              value: cat.categoryId,
                              child: Text(cat.name),
                            );
                          }).toList(),
                          onChanged: (newId) async {
                            controller.selectedCategoryId.value = newId!;
                            await controller.getAllSubCategory(newId);
        
                            if (controller.subCategory.isNotEmpty) {
                              controller.selectSubCategoryId.value = controller.subCategory.first.subCategoryId;
        
                            } else {
                              controller.selectSubCategoryId.value = 0;
        
                            }
        
                            controller.update();
                          },
                        ),
                      ),
                    ),
        
                    const SizedBox(height: 24),
        
                    // Subcategory Section Title
                    Text(
                      "Select the SubCategory",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
        
                    // SubCategory Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          borderRadius: BorderRadius.circular(12),
                          isExpanded: true,
                          hint: const Text('Choose a SubCategory'),
                          value: controller.subCategory.any(
                                  (sub) => sub.subCategoryId == controller.selectSubCategoryId.value)
                              ? controller.selectSubCategoryId.value
                              : null,
                          items: controller.subCategory.map((sub) {
                            return DropdownMenuItem<int>(
                              value: sub.subCategoryId,
                              child: Text(sub.name),
                            );
                          }).toList(),
                          onChanged: (newId) {
                            controller.selectSubCategoryId.value = newId!;
                            controller.update();
                          },
                        ),
                      ),
                    ),
        
                    // if (controller.subCategory.isEmpty)
                    //   Padding(
                    //     padding: const EdgeInsets.only(top: 10),
                    //     child: Text(
                    //       "No subcategories found for this category.",
                    //       style: TextStyle(fontSize: 14, color: Colors.redAccent),
                    //     ),
                    //   ),
                    //
                    // const SizedBox(height: 20),
                    //
        
                    SizedBox(
                      height: 12,
                    ),
                    controller.selectedImage.value != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        controller.selectedImage.value!,
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                        : const Text("No image selected"),
        
                    const SizedBox(height: 10),
        
                    // Row for button and file name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: controller.pickJpegFile,
                          icon: const Icon(Icons.photo),
                          label: const Text("Pick from Gallery"),
                        ),
                        const SizedBox(width: 10),
                        if (controller.selectedImage.value != null)
                          Expanded(
                            child: Text(
                              controller.selectedImage.value!.path.split('/').last, // Get file name
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                          ),
                      ],
                    ),
        
                    const SizedBox(height: 10),
        
                    if (controller.selectedImage.value != null)
                      TextButton(
                        onPressed: controller.clearImage,
                        child: const Text("Clear Image"),
                      ),
        
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: controller.courseName,
                      validator: (value) {
                        if(value != null && value.isNotEmpty){
                          return null;
                        }else{
                          return "Enter the Course Name";
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "courseName",
                        labelText: "courseName",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        )
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: controller.courseDescription,
                      validator: (value) {
                        if(value != null && value.isNotEmpty){
                          return null;
                        }else{
                          return "Enter the CourseDescription";
                        }
                      },
                      maxLines: 3,
                      decoration: InputDecoration(
                          alignLabelWithHint: true,
                          hintText: "courseDescription",
                          labelText: "courseDescription",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          )
                      ),
                    ),
        
                    const SizedBox(height: 10),


                    Obx(() => Container(
                      width: double.infinity,
                      child: MaterialButton(
                        height: 40,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.yellow,
                        onPressed: controller.uploading.value
                            ? null
                            : () async {
                          if (key.currentState!.validate()) {
                            await controller.uploadFile();
                            Get.back();
                          } else {
                            print("Error");
                          }
                        },
                        child: controller.isLoading.value
                            ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text("Add Course"),
                      ),
                    ))


                  ],
                ),
              ),
            );
        
        
        
          },
        ),
      ),
    );
  }
}
