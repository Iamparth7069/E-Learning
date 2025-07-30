import 'package:get/get.dart';

import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../../api/listing/api_listing.dart';
import '../../../../api/url/api_url.dart';

class LessionShowController extends GetxController{
  int courseId;
  LessionShowController(this.courseId);

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    print("Course Id $courseId" );
    loadLession();
  }

  SharedPrefHelper sharedPrefHelper = SharedPrefHelper();
  bool isLoadding = false;


  Future<void> loadLession() async {
    String api = ApiUrl.getAllLession + courseId.toString();
    String? token = sharedPrefHelper.getString(SharedPrefHelper.token);
    print("Token Number $token");

    isLoadding = true;
    update();
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await NetworkService.makeGetRequest(
        url: api,
        headers: headers,
      );

      print("📥 Raw Response: $response");

      dynamic parsedResponse = response["response"];

      // Now check and parse
      if (parsedResponse is List) {

        update();

      } else {
        update();
        print("❌ Expected List but got: ${parsedResponse.runtimeType}");
      }
    } catch (e, stackTrace) {
      update();
      print("❌ Exception while loading lessons: $e");
      print("🧵 StackTrace:\n$stackTrace");
    }finally{
      isLoadding = false;
      update();
    }
  }
}