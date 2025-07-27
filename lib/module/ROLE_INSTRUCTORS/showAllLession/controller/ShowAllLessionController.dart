import 'dart:convert';

import 'package:get/get.dart';
import 'package:shaktihub/api/listing/api_listing.dart';
import 'package:shaktihub/api/url/api_url.dart';

import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../model/LessionModel.dart';

class ShowAllLessionController extends GetxController{

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    loadAllLession();
  }

  final int courseId;
  List<LessionModel> allLessons = [];


  ShowAllLessionController(this.courseId);

  SharedPrefHelper sharedPrefHelper = SharedPrefHelper();
  bool isLoadding = false;




  Future<void> loadAllLession() async {
    String api = ApiUrl.getAllLession + courseId.toString();
    String? token = sharedPrefHelper.getString(SharedPrefHelper.token);
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
        allLessons = parsedResponse
            .map((item) => LessionModel.fromJson(item as Map<String, dynamic>))
            .toList();
        print("✅ Loaded ${allLessons.length} lessons");
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