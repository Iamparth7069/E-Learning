import 'package:get/get.dart';
import '../controller/CourseController.dart';

class CourseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CourseController>(() => CourseController());
  }
}
