import 'package:get/get.dart';
import 'package:shaktihub/module/home/screen/homeScreen.dart';
import 'package:shaktihub/module/registerAccount/screen/RegisterScreen.dart';

import '../module/Let’s_you_In_Screen/Screen/Let_you_In_Screen.dart';
import '../module/Onbodding_Screen/Screen/OnBoddingScreen.dart';
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
  ];
}


