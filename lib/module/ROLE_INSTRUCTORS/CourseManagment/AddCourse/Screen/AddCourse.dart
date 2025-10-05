import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:shaktihub/module/ROLE_INSTRUCTORS/Home/Model/CourseModel.dart';
import '../Controller/AddCourseController.dart';

class AddCourse extends StatelessWidget {
  final CourseModel? course;

  const AddCourse({this.course, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<FormState>();

    return Scaffold(
      appBar:
          AppBar(title: Text(course != null ? "Edit Course" : "Add Course")),
      body: SingleChildScrollView(
        child: GetBuilder<AddCourseController>(
          init: AddCourseController(course: course),
          builder: (controller) {
            // Show loading indicator while loading categories
            if (controller.isLoadingCategories.value && controller.allCategory.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      "Loading categories...",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Show error state if there's an error
            if (controller.hasError.value && controller.allCategory.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Failed to load categories",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.red[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        controller.getAllCategory();
                      },
                      icon: Icon(Icons.refresh),
                      label: Text("Retry"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
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
                          value: controller.allCategory.any((cat) =>
                                  cat.categoryId ==
                                  controller.selectedCategoryId.value)
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
                            if (newId != null) {
                              controller.selectedCategoryId.value = newId;
                              await controller.getAllSubCategory(newId);
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

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
                      child: controller.isLoadingSubCategories.value
                          ? Container(
                              height: 56,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      "Loading subcategories...",
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                borderRadius: BorderRadius.circular(12),
                                isExpanded: true,
                                hint: const Text('Choose a SubCategory'),
                                value: controller.subCategory.any((sub) =>
                                        sub.subCategoryId ==
                                        controller.selectSubCategoryId.value)
                                    ? controller.selectSubCategoryId.value
                                    : null,
                                items: controller.subCategory.map((sub) {
                                  return DropdownMenuItem<int>(
                                    value: sub.subCategoryId,
                                    child: Text(sub.name),
                                  );
                                }).toList(),
                                onChanged: (newId) {
                                  if (newId != null) {
                                    controller.selectSubCategoryId.value = newId;
                                    controller.update();
                                  }
                                },
                              ),
                            ),
                    ),

                    SizedBox(
                      height: 12,
                    ),
                    // IMAGE DISPLAY
                    (controller.selectedImage.value != null)
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              controller.selectedImage.value!,
                              height: 200,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (controller.course != null &&
                                controller.course!.image != null)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  controller.course!.image.imageUrl!,
                                  // Assuming this holds full URL
                                  height: 200,
                                  width: 200,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Text("No image selected"),

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: controller.isProcessingImage.value
                              ? null
                              : controller.pickJpegFile,
                          icon: controller.isProcessingImage.value
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.photo),
                          label: Text(
                            controller.isProcessingImage.value
                                ? "Processing..."
                                : "Pick from Gallery",
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (controller.selectedImage.value != null)
                          Expanded(
                            child: Text(
                              controller.selectedImage.value!.path
                                  .split('/')
                                  .last,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                          ),
                        if (controller.selectedImage.value != null)
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.red),
                            onPressed: controller.clearImage,
                            tooltip: "Clear selected image",
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
                        if (value == null || value.trim().isEmpty) {
                          return "Course name is required";
                        }
                        if (value.trim().length < 3) {
                          return "Course name must be at least 3 characters";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: "Enter course name",
                        labelText: "Course Name *",
                        prefixIcon: Icon(Icons.school),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: controller.courseDescription,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Course description is required";
                        }
                        if (value.trim().length < 10) {
                          return "Course description must be at least 10 characters";
                        }
                        return null;
                      },
                      maxLines: 3,
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        hintText: "Enter course description",
                        labelText: "Course Description *",
                        prefixIcon: Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      child: MaterialButton(
                        height: 50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.blue,
                        onPressed: controller.isUploading.value
                            ? null
                            : () async {
                                if (key.currentState!.validate()) {
                                  await controller.ManageCourse();
                                }
                              },
                        child: controller.isUploading.value
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    course != null ? "Updating Course..." : "Adding Course...",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                course != null ? "Update Course" : "Add Course",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    )
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
