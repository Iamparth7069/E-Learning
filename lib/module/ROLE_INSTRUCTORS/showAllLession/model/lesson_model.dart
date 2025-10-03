class Lesson {
  final int lessonId;
  String lessonName;
  String lessonContent;
  final int? sequenceNumber;
  LessonImage image;
  LessonVideo video;
  final int courseId;
  final List<dynamic>? comments;

  Lesson({
    required this.lessonId,
    required this.lessonName,
    required this.lessonContent,
    this.sequenceNumber,
    required this.image,
    required this.video,
    required this.courseId,
    this.comments,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      lessonId: json['lessonId'],
      lessonName: json['lessonName'],
      lessonContent: json['lessonContent'],
      sequenceNumber: json['sequenceNumber'],
      image: LessonImage.fromJson(json['image']),
      video: LessonVideo.fromJson(json['video']),
      courseId: json['courseId'],
      comments: json['comments'] as List<dynamic>?,
    );
  }
}

class LessonImage {
  final int imageId;
  final String fileName;
  final String imageUrl;
  final String contentType;
  final String objectName;

  LessonImage({
    required this.imageId,
    required this.fileName,
    required this.imageUrl,
    required this.contentType,
    required this.objectName,
  });

  factory LessonImage.fromJson(Map<String, dynamic> json) {
    return LessonImage(
      imageId: json['imageId'],
      fileName: json['fileName'],
      imageUrl: json['imageUrl'],
      contentType: json['contentType'],
      objectName: json['objectName'],
    );
  }
}

class LessonVideo {
  final int videoId;
  final String videoUrl;
  final String videoName;
  final String contentType;
  final String processingStatus;

  LessonVideo({
    required this.videoId,
    required this.videoUrl,
    required this.videoName,
    required this.contentType,
    required this.processingStatus,
  });

  factory LessonVideo.fromJson(Map<String, dynamic> json) {
    return LessonVideo(
      videoId: json['videoId'],
      videoUrl: json['videoUrl'],
      videoName: json['videoName'],
      contentType: json['contentType'],
      processingStatus: json['processingStatus'],
    );
  }
}
