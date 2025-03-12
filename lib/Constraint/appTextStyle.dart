import 'package:flutter/material.dart';

import 'app_color.dart';

class AppStyle {

  static TextStyle textStyleOutfit({Color? color, double? fontSize, FontWeight? fontWeight, FontStyle? fontStyle, TextDecoration? textDecoration}) {
    return TextStyle(
      color: color ?? AppColor.mainTextColor,
      fontSize: fontSize ?? 16,
      fontFamily: "Outfit",
      fontWeight: fontWeight ?? FontWeight.normal,
      fontStyle: fontStyle ?? FontStyle.normal,
      decoration: textDecoration ?? TextDecoration.none,
    );
  }

}