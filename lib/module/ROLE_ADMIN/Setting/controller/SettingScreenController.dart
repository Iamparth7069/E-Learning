import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';




class SettingsControllers extends GetxController {
  var isLoading = false.obs;

  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    loadUserData();
  }

  void loadUserData() async {
    try{
      isLoading.value = true;
      isLoading.value = false;
    }catch(e){
      isLoading.value = false;
    }
  }
  Future<void> signOut() async {
  }

}