
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shaktihub/routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Constraint/app_color.dart';
import 'package:sizer/sizer.dart';

import 'SharedPrefrance/SharedPrefrance_helper.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefHelper.init();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (p0, p1, p2) {
        return GetMaterialApp(
          color: AppColor.whiteColor,
          debugShowCheckedModeBanner: true,
          initialRoute: AppPages.initial,
          getPages: AppPages.routes,
        );
      },

    );
  }
}
