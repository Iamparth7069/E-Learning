import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shaktihub/module/ROLE_ADMIN/Home/Controller/home_controller_admin.dart';
import '../Widgets/AppDrawer.dart';

class HomeAdmin extends StatelessWidget {
  final HomeScreenAdminController controller = Get.put(HomeScreenAdminController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeScreenAdminController>(
      builder: (controller) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: AppDrawer(),
          body: SafeArea(
            child: Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await controller.loadCategory(controller.selectedCategory); // Call your refresh logic here
                    },
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(), // Required
                      slivers: [
                        _buildCategorySection(),
                        _buildItemList(controller),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
            height: 40,
            child: GetBuilder<HomeScreenAdminController>(
              builder: (controller) {
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final isSelected = controller.selectedCategory == index;
                    return GestureDetector(
                      onTap: () => controller.selectCategory(index),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 2)],
                        ),
                        child: Text(
                          controller.categories[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildItemList(HomeScreenAdminController controller) {
    if (controller.isLoading) {
      return SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    switch (controller.selectedCategory) {
      case 0:
        return _buildCategoryList(controller);
      case 1:
        return _buildSubCategoryList(controller);
      case 2:
        return _buildStudentList(controller);
      case 3:
        return _buildUserList(controller);
      case 4:
        return _buildInstructorList(controller);
      default:
        return SliverFillRemaining(
          child: Center(child: Text("Not implemented")),
        );
    }
  }

  Widget _buildCategoryList(HomeScreenAdminController controller) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final category = controller.categoriesAll[index];
          return _buildCard(
            icon: Icons.category,
            color: Colors.blue,
            title: category.name,
            subtitle: "Id: ${category.categoryId}",
            onTap: () => Get.snackbar('Category', 'Clicked on ${category.name}'),
          );
        },
        childCount: controller.categoriesAll.length,
      ),
    );
  }

  Widget _buildSubCategoryList(HomeScreenAdminController controller) {
    if (controller.subCategory.isEmpty) {
      return _emptyMessage("No Implement SubCategory");
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final sub = controller.subCategory[index];
          return _buildCard(
            icon: Icons.person,
            color: Colors.green,
            title: sub.name ?? '',
            subtitle: "SubCategory Id: ${sub.subCategoryId}",
            onTap: () => Get.snackbar('User', 'Username ${sub.name}'),
          );
        },
        childCount: controller.subCategory.length,
      ),
    );
  }

  Widget _buildStudentList(HomeScreenAdminController controller) {
    if (controller.allStudent.isEmpty) {
      return _emptyMessage("No Register Student");
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final student = controller.allStudent[index];
          return _buildCard(
            icon: Icons.person,
            color: Colors.green,
            title: student.firstName ?? '',
            subtitle: "Student: ${student.email}",
            onTap: () => Get.snackbar('Student', 'Username ${student.firstName}'),
          );
        },
        childCount: controller.allStudent.length,
      ),
    );
  }

  Widget _buildInstructorList(HomeScreenAdminController controller) {
    if (controller.allInstructors.isEmpty) {
      return _emptyMessage("No Instructor Found");
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final instructor = controller.allInstructors[index];
          return _buildCard(
            icon: Icons.person,
            color: Colors.green,
            title: instructor.firstName ?? 'null',
            subtitle: "Email: ${instructor.email}",
            onTap: () => Get.snackbar('Instructors', 'Username ${instructor.firstName}'),
          );
        },
        childCount: controller.allInstructors.length,
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(subtitle, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyMessage(String message) {
    return SliverFillRemaining(
      child: Center(
        child: Text(message, style: TextStyle(fontSize: 18, color: Colors.grey)),
      ),
    );
  }

  Widget _buildUserList(HomeScreenAdminController controller) {

    if (controller.allUserDataClass.isEmpty) {
      return _emptyMessage("No available User");
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final user = controller.allUserDataClass[index];
          return _buildCard(
            icon: Icons.person,
            color: Colors.green,
            title: user.firstName ?? '',
            subtitle: "User: ${user.email}",
            onTap: () => Get.snackbar('Student', 'Username ${user.firstName}'),
          );
        },
        childCount: controller.allUserDataClass.length,
      ),
    );

  }
}
