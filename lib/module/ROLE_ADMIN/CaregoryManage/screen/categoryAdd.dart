import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../controller/CategoryController.dart';

class CategoryAdd extends StatelessWidget {


  final controller = Get.put(CategoryController());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Category')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: controller.catgoryController,
              decoration: InputDecoration(
                labelText: 'Category Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Obx(() {
              if (controller.isLoading.value) {
                return ElevatedButton.icon(
                  onPressed: null,
                  icon: Container(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  label: Text('Adding...'),
                );
              }
              return ElevatedButton(
                onPressed: (){
                  controller.addCategory(context);
                },
                child: Text('Add Category'),
              );
            })
          ],
        ),
      ),
    );
  }
}
