import 'package:get/get.dart';
import '../controller/LessonController.dart';

class LessonBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LessonController>(() => LessonController());
  }
}
