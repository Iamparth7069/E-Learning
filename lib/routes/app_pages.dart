import 'package:get/get.dart';
import 'package:shaktihub/module/ROLE_ADMIN/CaregoryManage/screen/subCategoryManage.dart';
import 'package:shaktihub/module/ROLE_ADMIN/bottomNav/Screen/bottom_navbar_screen.dart';

import '../module/Let’s_you_In_Screen/Screen/Let_you_In_Screen.dart';
import '../module/Onbodding_Screen/Screen/OnBoddingScreen.dart';
import '../module/ROLE_ADMIN/CaregoryManage/screen/categoryAdd.dart';
import '../module/ROLE_ADMIN/Home/screen/home_Admin.dart';
import '../module/ROLE_INSTRUCTORS/BottomNavBar/Screen/bottomNavBarinInstructor.dart';
import '../module/ROLE_USER/dashboard/screen/deskBoardScreen.dart';
import '../module/ROLE_USER/home/screen/homeScreen.dart';
import '../module/ROLE_USER/registerAccount/screen/RegisterScreen.dart';
import '../module/ROLE_USER/SubCategory/screen/SubCategoryScreen.dart';
import '../module/ROLE_USER/SubCategory/binding/SubCategoryBinding.dart';
import '../module/ROLE_USER/Course/screen/CourseScreen.dart';
import '../module/ROLE_USER/Course/binding/CourseBinding.dart';
import '../module/ROLE_USER/Lesson/screen/LessonScreen.dart';
import '../module/ROLE_USER/Lesson/binding/LessonBinding.dart';
import '../module/ROLE_USER/LessonDetail/screen/LessonDetailScreen.dart';
import '../module/ROLE_USER/LessonDetail/binding/LessonDetailBinding.dart';
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

    GetPage(
      name: _Paths.USER_SUB_CATEGORY,
      page: () => const SubCategoryScreen(),
      binding: SubCategoryBinding(),
    ),

    GetPage(
      name: _Paths.USER_COURSE,
      page: () => const CourseScreen(),
      binding: CourseBinding(),
    ),

    GetPage(
      name: _Paths.USER_LESSON,
      page: () => const LessonScreen(),
      binding: LessonBinding(),
    ),

    GetPage(
      name: _Paths.USER_LESSON_DETAIL,
      page: () => const LessonDetailScreen(),
      binding: LessonDetailBinding(),
    ),

    GetPage(
      name: _Paths.INSTRUCTORSCREEN,
      page: () => BottomNavScreen(),
    ),

  ];
}


