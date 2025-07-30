// lesson_model.dart

class UserLessionModel {
  final int lessonId;
  final String lessonName;
  final String lessonContent;
  final UserLessonImage? image;
  final UserLessonVideo? video;
  final int courseId;

  UserLessionModel({
    required this.lessonId,
    required this.lessonName,
    required this.lessonContent,
    required this.courseId,
    this.image,
    this.video,
  });

  factory UserLessionModel.fromJson(Map<String, dynamic> json) {
    return UserLessionModel(
      lessonId: json['lessonId'],
      lessonName: json['lessonName'],
      lessonContent: json['lessonContent'],
      courseId: json['courseId'],
      image: json['image'] != null ? UserLessonImage.fromJson(json['image']) : null,
      video: json['video'] != null ? UserLessonVideo.fromJson(json['video']) : null,
    );
  }
}

class UserLessonImage {
  final int imageId;
  final String fileName;
  final String imageUrl;
  final String contentType;
  final String objectName;

  UserLessonImage({
    required this.imageId,
    required this.fileName,
    required this.imageUrl,
    required this.contentType,
    required this.objectName,
  });

  factory UserLessonImage.fromJson(Map<String, dynamic> json) {
    return UserLessonImage(
      imageId: json['imageId'],
      fileName: json['fileName'],
      imageUrl: json['imageUrl'],
      contentType: json['contentType'],
      objectName: json['objectName'],
    );
  }
}

class UserLessonVideo {
  final int videoId;
  final String videoUrl;
  final String videoName;
  final String contentType;
  final String processingStatus;

  UserLessonVideo({
    required this.videoId,
    required this.videoUrl,
    required this.videoName,
    required this.contentType,
    required this.processingStatus,
  });

  factory UserLessonVideo.fromJson(Map<String, dynamic> json) {
    return UserLessonVideo(
      videoId: json['videoId'],
      videoUrl: json['videoUrl'],
      videoName: json['videoName'],
      contentType: json['contentType'],
      processingStatus: json['processingStatus'],
    );
  }
}
