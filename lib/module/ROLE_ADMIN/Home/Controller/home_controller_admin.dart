import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:shaktihub/module/ROLE_ADMIN/Home/model/subCategoryModel.dart';
import 'package:shaktihub/module/login/Model/UserModel.dart';

import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../../../api/listing/api_listing.dart';
import '../../../../api/url/api_url.dart';
import '../../CaregoryManage/screen/Category.dart';
import '../../CaregoryManage/screen/subCategoryManage.dart';
import '../model/categoryAllModel.dart';
import '../model/userModelClass.dart';

class HomeScreenAdminController extends GetxController {
  List<CategoryModel> categoriesAll = [];

  List<UserModelClass> allUserDataClass = [];
  List<UserModelClass> allInstructors = [];
  List<UserModelClass> allStudent = [];
  List<SubCategoryModel> subCategory = [];
  int selectedCategory = 0;
  bool isLoading = false; // NEW

  final List<String> categories = ["Category", "SubCategory" ,"Student", "All User", "Instructors"];

  @override
  Future<void> onInit() async {
    super.onInit();
    await loadCategory(0);
  }

  void selectCategory(int index) async {
    selectedCategory = index;

    await loadCategory(index);
    update();

  }

  Future<void> loadCategory(int index) async {
    isLoading = true;
    update();

    SharedPrefHelper sh1 = SharedPrefHelper();

    String token = sh1.getString(SharedPrefHelper.token)!;

    Map<String,String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };

    String url = "";
    if (index == 0) {
      url = ApiUrl.gatAllCategory;
    } else if (index == 1) {
      url = ApiUrl.getAllSubCategory;
    }
    else if (index == 2) {
      url = ApiUrl.allStudent;
    }else if(index == 3){
      url = ApiUrl.allUser;
    }else{

      url = ApiUrl.allInstructors;
    }
    print("Fetching from $url");

    final response = await NetworkService.makeGetRequest(url: url, headers: headers);
    if (response["statusCode"] == 200) {
      List<dynamic> jsonList = response['response']; // parses the array

      if (index == 0) {
        categoriesAll = jsonList.map((item) => CategoryModel.fromJson(item)).toList();
      }else if (index == 1) {
        subCategory = jsonList.map((e) => SubCategoryModel.fromJson(e)).toList();
      }
      else if (index == 2) {
        allStudent = jsonList.map((item) => UserModelClass.fromJson(item)).toList();

      }else if(index == 3){
        allUserDataClass = jsonList.map((item) => UserModelClass.fromJson(item)).toList();

      }else if(index == 4){
        allInstructors = jsonList.map((item) => UserModelClass.fromJson(item)).toList();
      }
      update();
    } else {
      print('Error loading Categories: ${response['response']}');
    }
    isLoading = false;
    update();
  }
}
