import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sizer/sizer.dart';

import '../Model/UserLessionModel.dart';

class LessonCard extends StatelessWidget {
  final UserLessionModel lesson;

  const LessonCard({super.key, required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: CachedNetworkImage(
              imageUrl: lesson.image?.imageUrl ?? '',
              width: double.infinity,
              height: 180.h,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Image.asset("assets/images/search.png", fit: BoxFit.cover),
              errorWidget: (context, url, error) =>
              const Icon(Icons.broken_image),
            ),
          ),
          // ✅ Text Info
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.lessonName,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: Colors.black),
                ),
                SizedBox(height: 6.h),
                Text(
                  lesson.lessonContent,
                  style: TextStyle(
                      fontSize: 14.sp, color: Colors.grey.shade700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.videocam, size: 18, color: Colors.deepPurple),
                        const SizedBox(width: 6),
                        Text(
                          lesson.video?.processingStatus ?? 'No Video',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to detail / video player
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Watch"),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
