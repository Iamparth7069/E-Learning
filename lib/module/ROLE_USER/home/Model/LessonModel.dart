class LessonModel {
  final int lessonId;
  final String lessonName;
  final String lessonContent;
  final int sequenceNumber;
  final LessonImage? image;
  final LessonVideo? video;
  final int courseId;
  final List<dynamic> comments;

  LessonModel({
    required this.lessonId,
    required this.lessonName,
    required this.lessonContent,
    required this.sequenceNumber,
    this.image,
    this.video,
    required this.courseId,
    required this.comments,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      lessonId: json['lessonId'] ?? 0,
      lessonName: json['lessonName'] ?? '',
      lessonContent: json['lessonContent'] ?? '',
      sequenceNumber: json['sequenceNumber'] ?? 0,
      image: json['image'] != null ? LessonImage.fromJson(json['image']) : null,
      video: json['video'] != null ? LessonVideo.fromJson(json['video']) : null,
      courseId: json['courseId'] ?? 0,
      comments: json['comments'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lessonId': lessonId,
      'lessonName': lessonName,
      'lessonContent': lessonContent,
      'sequenceNumber': sequenceNumber,
      'image': image?.toJson(),
      'video': video?.toJson(),
      'courseId': courseId,
      'comments': comments,
    };
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
      imageId: json['imageId'] ?? 0,
      fileName: json['fileName'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      contentType: json['contentType'] ?? '',
      objectName: json['objectName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageId': imageId,
      'fileName': fileName,
      'imageUrl': imageUrl,
      'contentType': contentType,
      'objectName': objectName,
    };
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
      videoId: json['videoId'] ?? 0,
      videoUrl: json['videoUrl'] ?? '',
      videoName: json['videoName'] ?? '',
      contentType: json['contentType'] ?? '',
      processingStatus: json['processingStatus'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'videoUrl': videoUrl,
      'videoName': videoName,
      'contentType': contentType,
      'processingStatus': processingStatus,
    };
  }
}

