import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:sizer/sizer.dart';

import 'app_color.dart';


extension SizedExtension on double {
  addHSpace() {
    return SizedBox(height: this);
  }

  addWSpace() {
    return SizedBox(width: this);
  }
}

extension AppDivider on double {
  Widget appDivider({Color? color}) {
    return Divider(
      thickness: this,
      color: color ?? Colors.white,
    );
  }
}

extension AppValidation on String {
  isValidEmail() {
    return RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(this);
  }
}

hideKeyBoard(BuildContext context) {
  return FocusScope.of(context).unfocus();
}

printData({required dynamic tittle, dynamic val}) {
  debugPrint(tittle + ":-" + val.toString());
}

extension ReadexPro on String {
  Widget regularReadex({
    Color? fontColor,
    double? fontSize,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow,
    TextAlign? textAlign,
  }) {
    return Text(
      this,
      overflow: textOverflow,
      style: TextStyle(
          color: fontColor ?? AppColor.appBackColor,
          fontSize: fontSize ?? 16,
          fontWeight: FontWeight.w300,
          decoration: textDecoration ?? TextDecoration.none,
          fontFamily: 'ReadexPro'),
      textAlign: textAlign,
    );
  }

  Widget mediumReadex(
      {Color? fontColor,
        double? fontSize,
        TextDecoration? textDecoration,
        TextOverflow? textOverflow,
        TextAlign? textAlign,
        int? maxLine}) {
    return Text(
      this,
      overflow: textOverflow,
      style: TextStyle(
          color: fontColor ?? AppColor.appBackColor,
          fontSize: fontSize ?? 16,
          fontWeight: FontWeight.w400,
          decoration: textDecoration ?? TextDecoration.none,
          fontFamily: 'ReadexPro'),
      textAlign: textAlign,
      maxLines: maxLine,
    );
  }

  Widget semiBoldReadex({
    Color? fontColor,
    double? fontSize,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow,
    TextAlign? textAlign,
  }) {
    return Text(
      this,
      overflow: textOverflow,
      style: TextStyle(
          color: fontColor ?? AppColor.appBackColor,
          fontSize: fontSize ?? 16,
          fontWeight: FontWeight.w600,
          decoration: textDecoration ?? TextDecoration.none,
          fontFamily: 'ReadexPro'),
      textAlign: textAlign,
    );
  }

  Widget boldReadex({
    Color? fontColor,
    double? fontSize,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow,
    TextAlign? textAlign,
  }) {
    return Text(
      this,
      overflow: textOverflow,
      style: TextStyle(
          color: fontColor ?? AppColor.appBackColor,
          fontSize: fontSize ?? 16,
          fontWeight: FontWeight.w700,
          decoration: textDecoration ?? TextDecoration.none,
          fontFamily: 'ReadexPro'),
      textAlign: textAlign,
    );
  }

  Widget extraBoldReadex({
    Color? fontColor,
    double? fontSize,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow,
    TextAlign? textAlign,
  }) {
    return Text(
      this,
      overflow: textOverflow,
      style: TextStyle(
          color: fontColor ?? AppColor.appBackColor,
          fontSize: fontSize ?? 16,
          fontWeight: FontWeight.w900,
          decoration: textDecoration ?? TextDecoration.none,
          fontFamily: 'ReadexPro'),
      textAlign: textAlign,
    );
  }
}

extension AlegreyaSC on String {
  Widget regularAlegreyaSC({
    Color? fontColor,
    double? fontSize,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow,
    TextAlign? textAlign,
    FontWeight? fontWeight,
  }) {
    return Text(
      this,
      overflow: textOverflow,
      style: TextStyle(
          color: fontColor ?? AppColor.appBackColor,
          fontSize: fontSize ?? 16,
          fontWeight: fontWeight ?? FontWeight.w300,
          decoration: textDecoration ?? TextDecoration.none,
          fontFamily: 'AlegreyaSC'),
      textAlign: textAlign,
    );
  }

  Widget mediumAlegreyaSC({
    Color? fontColor,
    double? fontSize,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow,
    TextAlign? textAlign,
  }) {
    return Text(
      this,
      overflow: textOverflow,
      style: TextStyle(
          color: fontColor ?? AppColor.appBackColor,
          fontSize: fontSize ?? 16,
          fontWeight: FontWeight.w400,
          decoration: textDecoration ?? TextDecoration.none,
          fontFamily: 'AlegreyaSC'),
      textAlign: textAlign,
    );
  }

  Widget boldAlegreyaSC({
    Color? fontColor,
    double? fontSize,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow,
    TextAlign? textAlign,
  }) {
    return Text(
      this,
      overflow: textOverflow,
      style: TextStyle(
          color: fontColor ?? AppColor.appBackColor,
          fontSize: fontSize ?? 16,
          fontWeight: FontWeight.w700,
          decoration: textDecoration ?? TextDecoration.none,
          fontFamily: 'AlegreyaSC'),
      textAlign: textAlign,
    );
  }
}

extension Roboto on String {
  Widget regularRoboto({
    Color? fontColor,
    double? fontSize,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow,
    TextAlign? textAlign,
  }) {
    return Text(
      this,
      overflow: textOverflow,
      style: TextStyle(
        color: fontColor ?? AppColor.appBackColor,
        fontSize: fontSize ?? 16,
        fontWeight: FontWeight.w300,
        decoration: textDecoration ?? TextDecoration.none,
      ),
      textAlign: textAlign,
    );
  }

  Widget mediumRoboto({
    Color? fontColor,
    double? fontSize,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow,
    TextAlign? textAlign,
  }) {
    return Text(
      this,
      overflow: textOverflow,
      style: TextStyle(
        color: fontColor ?? AppColor.appBackColor,
        fontSize: fontSize ?? 16,
        fontWeight: FontWeight.w400,
        decoration: textDecoration ?? TextDecoration.none,
      ),
      textAlign: textAlign,
    );
  }

  Widget boldRoboto({
    Color? fontColor,
    double? fontSize,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow,
    TextAlign? textAlign,
  }) {
    return Text(
      this,
      overflow: textOverflow,
      style: TextStyle(
        color: fontColor ?? AppColor.appBackColor,
        fontSize: fontSize ?? 16,
        fontWeight: FontWeight.w400,
        decoration: textDecoration ?? TextDecoration.none,
      ),
      textAlign: textAlign,
    );
  }
}

enum LoginType {
  Google,
  Facebook,
  App,
}

Widget createLoginButton({
  required Function()? onPressed,
  required String text,
  required String imagePath, // Accept image asset path
  Color? color,
  required Color borderColor,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: borderColor, // Set the color of the border
          width: 1, // Set the width of the border
        ),
      ),
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.white,
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Fixed size for image
          SizedBox(
            width: 30,
            height: 30,
            child: Image.asset(imagePath),
          ),

          // Adjust spacing dynamically
          SizedBox(width: text == "Continue with Facebook" ? 15 : 30),

          // Prevents text overflow and keeps button layout clean
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis, // Prevents overflow
              maxLines: 1, // Ensures it stays in one line
              softWrap: false, // Avoids multi-line wrapping
              style: TextStyle(fontSize: 14), // Adjust font size if needed
            ),
          ),
        ],
      ),
    ),
  );
}

Widget appButton(
    {double? height,
      double? width,
      required var onTap,
      Color? color,
      String? text,
      double? fontSize,
      Color? fontColor}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: height ?? 6.5.h,
      width: width ?? 90.w,
      decoration: BoxDecoration(
          color: color ?? AppColor.appBackColor, borderRadius: BorderRadius.circular(50)),
      child: Center(
          child: (text ?? "").semiOpenSans(
              fontColor: fontColor ?? AppColor.whiteColor, fontSize: fontSize ?? 14.sp)),
    ),
  );
}

Widget customSquareButton({
  required var onTap,
  Color? color,
  required IconData icon,
  String? text,
  double? fontSize,
  double? iconSize,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      height: 7.h,
      width: 15.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        color: color,
        size: iconSize,
      ),
    ),
  );
}

extension OpenSans on String {
  Widget regularOpenSans({
    Color? fontColor,
    double? fontSize,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow,
    TextAlign? textAlign,
  }) {
    return Text(
      this,
      overflow: textOverflow,
      style: TextStyle(
          color: fontColor ?? AppColor.appBackColor,
          fontSize: fontSize ?? 16,
          fontWeight: FontWeight.w300,
          decoration: textDecoration ?? TextDecoration.none,
          fontFamily: 'OpenSans'),
      textAlign: textAlign,
    );
  }

  Widget mediumOpenSans(
      {Color? fontColor,
        double? fontSize,
        TextDecoration? textDecoration,
        TextOverflow? textOverflow,
        TextAlign? textAlign,
        int? maxLine}) {
    return Text(
      this,
      overflow: textOverflow,
      style: TextStyle(
          color: fontColor ?? AppColor.appBackColor,
          fontSize: fontSize ?? 16,
          fontWeight: FontWeight.w400,
          decoration: textDecoration ?? TextDecoration.none,
          fontFamily: 'OpenSans'),
      textAlign: textAlign,
      maxLines: maxLine,
    );
  }

  Widget semiOpenSans({
    Color? fontColor,
    double? fontSize,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow,
    TextAlign? textAlign,
    int? maxLines,
  }) {
    return Text(
      this,
      maxLines: maxLines ?? 1,
      overflow: textOverflow,
      style: TextStyle(
          color: fontColor ?? AppColor.appBackColor,
          fontSize: fontSize ?? 16,
          fontWeight: FontWeight.w600,
          decoration: textDecoration ?? TextDecoration.none,
          fontFamily: 'OpenSans'),
      textAlign: textAlign,
    );
  }

  Widget boldOpenSans({
    Color? fontColor,
    double? fontSize,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow,
    TextAlign? textAlign,
  }) {
    return Text(
      this,
      overflow: textOverflow,
      style: TextStyle(
          color: fontColor ?? AppColor.appBackColor,
          fontSize: fontSize ?? 16,
          fontWeight: FontWeight.w700,
          decoration: textDecoration ?? TextDecoration.none,
          fontFamily: 'OpenSans'),
      textAlign: textAlign,
    );
  }

  Widget extraBoldOpenSans({
    Color? fontColor,
    double? fontSize,
    int? maxLine,
    TextDecoration? textDecoration,
    TextOverflow? textOverflow,
    TextAlign? textAlign,
  }) {
    return Text(
      this,
      maxLines: maxLine,
      overflow: textOverflow,
      style: TextStyle(
          color: fontColor ?? AppColor.appBackColor,
          fontSize: fontSize ?? 16,
          fontWeight: FontWeight.w700,
          decoration: textDecoration ?? TextDecoration.none,
          fontFamily: 'OpenSans'),
      textAlign: textAlign,
    );
  }
}

Widget roundCornurButton(
    {double? height,
      double? width,
      Color? color,
      BorderRadiusGeometry? radiusGeometry,
      void Function()? onTap,
      String? text,
      Color? textColor}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: height ?? 7.h,
      width: width ?? 100.w,
      decoration: BoxDecoration(
        color: color ?? AppColor.appBackColor,
        borderRadius: radiusGeometry ?? BorderRadius.circular(70),
      ),
      child: Center(
          child:
          (text ?? "").semiOpenSans(fontSize: 18.sp, fontColor: textColor)),
    ),
  );
}

Widget customTextFormField(
    {TextEditingController? textEditingController,
      Color? fillColor,
      String? Function(String?)? validator,
      Widget? suffix,
      Widget? prefix,
      int? maxLines,
      List<TextInputFormatter>? data,
      String? hintText}) {
  return TextFormField(
    validator: validator ?? (string) => null,
    controller: textEditingController,
    minLines: 1,
    maxLines: maxLines,
    inputFormatters: data,
    decoration: InputDecoration(
      contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
        fillColor: fillColor ?? const Color(0xfffafafa),
        hintText: hintText ?? "",
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.transparent)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.transparent)),
        prefixIcon: prefix,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 50,  // Adjust this value to control spacing
          minHeight: 20,
        ),
        suffixIcon: suffix ?? const SizedBox(),
        filled: true),
  );
}


// void showMessege({String? title, String? messege}) {
//   Get.snackbar(title ?? "", messege ?? "", backgroundColor: AppColor.lightPurple);
// }

// Widget loadingEffect({double? width, double? height, double? radius}) {
//   return SizedBox(
//     height: height ?? 20,
//     width: width ?? 50,
//     child: Shimmer.fromColors(
//       baseColor: Colors.grey.shade200,
//       highlightColor: AppColor.lightPurple.withOpacity(0.8),
//       enabled: true,
//       direction: ShimmerDirection.ltr,
//       child: Container(
//         height: height ?? 20,
//         width: width ?? 50,
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(radius ?? 5),
//             color: Colors.white),
//       ),
//     ),
//   );
// }


Widget assetImage(String image, {double? height, double? width, Color? color,BoxFit? fit}) {
  return Image.asset(
    image,
    height: height,
    width: width,
    color: color,
    fit:fit ?? BoxFit.contain,
  );
}
