import 'package:flutter/cupertino.dart';

class AppAssets {
  static const imagePath = "assets/images/";
  static const svgImagePath = "assets/images/svg/";

  static const google = "${imagePath}google.png";
  static const svgLogo="${svgImagePath}app_logo.svg";
  static const appLogo="${imagePath}app_logo.png";
  static const onBording1="${imagePath}onbording1.png";
  static const onBording2="${imagePath}onBording2.png";
  static const onBording3="${imagePath}onBording3.png";static const loginLogo = "${svgImagePath}undraw_welcome_re_h3d9.svg";
  static final _emailregex  = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  static final _passregex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$'); // should contain at least one Special character.{8,}");

  static bool isvalidemail(String email){
    return _emailregex.hasMatch(email);
  }
  static bool isvalidpassword(String password){
    return _passregex.hasMatch(password);
  }
  static bool isvalidmobile(String values){
    if(values.length != 10){
      values = "'Mobile Number must be of 10 digit'";
      return false;
    }else{
      return true;
    }
  }
}

Widget assetImage(String image, {double? height, double? width, Color? color,BoxFit? fit}) {
  return Image.asset(
    image,
    height: height,
    width: width,
    color: color,
    fit:fit ?? BoxFit.contain,
  );
}

AssetImage assetsImage2(String image,
    {double? height, double? width, Color? color}) {
  return AssetImage(image);
}
