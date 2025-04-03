import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:shaktihub/module/ROLE_ADMIN/Home/Controller/home_controller_admin.dart';

import '../Widgets/AppDrawer.dart';
import '../Widgets/CategoryItem.dart';

class HomeAdmin extends StatelessWidget {
  final HomeScreenAdminController controller = Get.put(HomeScreenAdminController()); // Inject Controller
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Add this key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign the key to Scaffold
      drawer: AppDrawer(), // Drawer widget
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar and Menu Button (Fixed)
            _buildSearchBar(),

            // Expanded CustomScrollView for the List
            Expanded(
              child: CustomScrollView(
                slivers: [
                  _buildCategorySection(),
                  _buildItemList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // **Updated Search Bar**
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(), // Open drawer using key
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // **Category Section**
  Widget _buildCategorySection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 50,
            child: GetBuilder<HomeScreenAdminController>(
              builder: (controller) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => controller.selectCategory(index),
                      child: CategoryItem(
                        title: controller.categories[index],
                        isSelected: controller.selectedCategory == index,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // **Item List**
  Widget _buildItemList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return InkWell(
            onTap: () => Get.snackbar("Info", "Clicked on Item ${index + 1}"),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Icon(Icons.image, color: Colors.blue),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Item ${index + 1}", style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text("Subtitle for item ${index + 1}", style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
          );
        },
        childCount: 20, // Number of items in the list
      ),
    );
  }
}
