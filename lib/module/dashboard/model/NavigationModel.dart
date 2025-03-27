import 'package:flutter/material.dart';

class NavigationModel {
  String name;
  String icon;
  String iconFilled;
  Widget screen;
  NavigationModel({required this.name, required this.icon, required this.iconFilled, required this.screen});
}
