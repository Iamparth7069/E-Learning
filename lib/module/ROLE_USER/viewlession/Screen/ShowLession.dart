import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/ViewLessionController.dart';

class ShowLessionStudent extends StatelessWidget {
  int courseId;
  ShowLessionStudent(this.courseId, {super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<LessionShowController>(
        init: LessionShowController(courseId),
        builder: (controller) {
        return Column();

      },),
    );
  }
}
