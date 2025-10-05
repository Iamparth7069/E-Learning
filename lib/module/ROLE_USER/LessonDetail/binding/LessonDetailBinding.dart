import 'package:get/get.dart';
import '../controller/LessonDetailController.dart';

class LessonDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LessonDetailController>(() => LessonDetailController());
  }
}
