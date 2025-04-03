import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/homeScreenController.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> userList = ["F","Skill","Category"];
    return GetBuilder<HomeScreenController>(
      init: HomeScreenController(),
      builder: (controller) {
        return Scaffold(
          appBar:  AppBar(title: Text("Home"),),
          body: GridView.builder(
            itemCount: userList.length,
            physics: AlwaysScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          itemBuilder: (context, index) {
              return Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade500),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                        spreadRadius: 1,
                        color: Theme.of(context).primaryColor.withOpacity(.125),
                      ),
                    ]
                ),
                height: 300,
                width: 200,
                child: Center(child: Text("${userList[index]}")),

              );
          },
          ),
        );
      },
    );
  }
}
