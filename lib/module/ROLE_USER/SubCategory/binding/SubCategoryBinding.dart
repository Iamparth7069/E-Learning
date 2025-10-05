import 'package:get/get.dart';
import '../controller/SubCategoryController.dart';

class SubCategoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubCategoryController>(() => SubCategoryController());
  }
}
