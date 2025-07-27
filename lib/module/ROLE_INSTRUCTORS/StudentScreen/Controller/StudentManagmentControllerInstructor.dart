import 'package:get/get.dart';
import 'package:shaktihub/module/ROLE_INSTRUCTORS/StudentScreen/Model/StudentModel.dart';
import '../../../ROLE_ADMIN/Cource Managment/Model/CourceModel.dart';
import '../../../../api/listing/api_listing.dart';
import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../../api/url/api_url.dart';

class StudentManagmentController extends GetxController {
  RxList<StudentModel> getAllCouceData = <StudentModel>[].obs;
  RxInt selectedCourseId = 0.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCourse();
  }

  Future<void> loadCourse() async {
    try {
      String url = ApiUrl.getAllCourse;
      String? token = SharedPrefHelper().getString(SharedPrefHelper.token);

      print("🔑 Token value: $token");

      if (token == null) {
        throw Exception("Token is null! Check SharedPreferences.");
      }

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await NetworkService.makeGetRequest(
        url: url,
        headers: headers,
      );

      print("📥 Response: $response");

      if (response["statusCode"] == 200) {
        getAllCouceData.value = (response["response"] as List)
            .map((data) => StudentModel.fromJson(data))
            .toList();

        if (getAllCouceData.isNotEmpty) {
          selectedCourseId.value = getAllCouceData.first.courseId!;
        }
      } else {
        Get.snackbar('Error', 'Failed to load courses');
      }
    } catch (e, stack) {
      print("❌ Error: $e");
      print("📍 StackTrace: $stack");
    }
  }

  Future<void> getUser(int value) async {
    String? token = SharedPrefHelper().getString(SharedPrefHelper.token);

    print("Course Id " + value.toString());

    if (token == null) {
      throw Exception("Token is null! Check SharedPreferences.");
    }

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    try{
      isLoading.value = true;

      String url = ApiUrl.getUserByCourse;
      final response = await NetworkService.makeGetRequest(url: url,
      headers: headers,
      );

      if(response["statusCode"] == 200){
        isLoading.value = false;

      }
    }catch(e) {
      print("Error is ${e.toString()}");
      isLoading.value = false;
    }finally{
      isLoading.value = false;
    }
  }

}
