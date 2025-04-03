import 'package:get/get.dart';

class HomeScreenAdminController extends GetxController{

  int selectedCategory = 0;
  final List<String> categories = ["All", "Popular", "Recent", "Trending"];

  void selectCategory(int index) {
    selectedCategory = index;
    update(); // This will update the UI
  }
}