import 'package:get/get.dart';
import 'package:shaktihub/module/ROLE_ADMIN/CaregoryManage/screen/subCategoryManage.dart';
import 'package:shaktihub/module/ROLE_ADMIN/bottomNav/Screen/bottom_navbar_screen.dart';

import '../module/Let’s_you_In_Screen/Screen/Let_you_In_Screen.dart';
import '../module/Onbodding_Screen/Screen/OnBoddingScreen.dart';
import '../module/ROLE_ADMIN/CaregoryManage/screen/categoryAdd.dart';
import '../module/ROLE_ADMIN/Home/screen/home_Admin.dart';
import '../module/ROLE_USER/dashboard/screen/deskBoardScreen.dart';
import '../module/ROLE_USER/home/screen/homeScreen.dart';
import '../module/ROLE_USER/registerAccount/screen/RegisterScreen.dart';
import '../module/login/screen/login.dart';
import '../module/splashscreen/Screen/SplashScreen.dart';


part 'app_routes.dart';
class AppPages {
  AppPages._();

  static const initial = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () =>  SplashScreen(),
    ),
    GetPage(
      name: _Paths.ONBODDINGSCREEN,
      page: () => const OnBordingScreen(),
    ),
    GetPage(
      name: _Paths.LETYOUINSCREEN,
      page: () =>  LetsYouInScreen(),
    ),
    GetPage(
      name: _Paths.REGISTERSCREEN,
      page: () => const RegisterScreen(),
    ),
    GetPage(
      name: _Paths.LOGINSCREEN,
      page: () =>  Login(),
    ),
    GetPage(
      name: _Paths.HOMESCREEN,
      page: () =>const HomeScreen(),
    ),
    GetPage(
      name: _Paths.deskBoard,
      page: () =>const DeskBoardScreen(),
    ),
    GetPage(
      name: _Paths.AdminHomeScreen,
      page: () => HomeAdmin(),
    ),

    GetPage(
      name: _Paths.DESKBOARDFORADMIN,
      page: () =>const DeskBoardScreenAdmin(),
    ),

    GetPage(
      name: _Paths.ADMINCATEGORYADD,
      page: () => CategoryAdd(),
    ),
    GetPage(
      name: _Paths.subCategoryPage,
      page: () => SubCategory(),
    ),


  ];
}


