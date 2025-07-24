class LessionModel {
  int? lessonId;
  String? lessonName;
  String? lessonContent;
  LessonImage? image;
  Video? video;
  int? courseId;
  List<Comment>? comments;

  LessionModel({
    this.lessonId,
    this.lessonName,
    this.lessonContent,
    this.image,
    this.video,
    this.courseId,
    this.comments,
  });

  factory LessionModel.fromJson(Map<String, dynamic> json) => LessionModel(
    lessonId: json['lessonId'],
    lessonName: json['lessonName'],
    lessonContent: json['lessonContent'],
    image: json['image'] != null ? LessonImage.fromJson(json['image']) : null,
    video: json['video'] != null ? Video.fromJson(json['video']) : null,
    courseId: json['courseId'],
    comments: json['comments'] != null
        ? List<Comment>.from(json['comments'].map((x) => Comment.fromJson(x)))
        : [],
  );

  Map<String, dynamic> toJson() => {
    'lessonId': lessonId,
    'lessonName': lessonName,
    'lessonContent': lessonContent,
    'image': image?.toJson(),
    'video': video?.toJson(),
    'courseId': courseId,
    'comments': comments?.map((x) => x.toJson()).toList(),
  };
}

class LessonImage {
  int? imageId;
  String? fileName;
  String? imageUrl;
  String? contentType;
  String? objectName;

  LessonImage({
    this.imageId,
    this.fileName,
    this.imageUrl,
    this.contentType,
    this.objectName,
  });

  factory LessonImage.fromJson(Map<String, dynamic> json) => LessonImage(
    imageId: json['imageId'],
    fileName: json['fileName'],
    imageUrl: json['imageUrl'],
    contentType: json['contentType'],
    objectName: json['objectName'],
  );

  Map<String, dynamic> toJson() => {
    'imageId': imageId,
    'fileName': fileName,
    'imageUrl': imageUrl,
    'contentType': contentType,
    'objectName': objectName,
  };
}

class Video {
  int? videoId;
  String? videoUrl;
  String? videoName;
  String? contentType;
  String? processingStatus;

  Video({
    this.videoId,
    this.videoUrl,
    this.videoName,
    this.contentType,
    this.processingStatus,
  });

  factory Video.fromJson(Map<String, dynamic> json) => Video(
    videoId: json['videoId'],
    videoUrl: json['videoUrl'],
    videoName: json['videoName'],
    contentType: json['contentType'],
    processingStatus: json['processingStatus'],
  );

  Map<String, dynamic> toJson() => {
    'videoId': videoId,
    'videoUrl': videoUrl,
    'videoName': videoName,
    'contentType': contentType,
    'processingStatus': processingStatus,
  };
}

class Comment {
  int? commentId;
  String? content;
  String? createdBy;
  String? createdAt;

  Comment({
    this.commentId,
    this.content,
    this.createdBy,
    this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    commentId: json['commentId'],
    content: json['content'],
    createdBy: json['createdBy'],
    createdAt: json['createdAt'],
  );

  Map<String, dynamic> toJson() => {
    'commentId': commentId,
    'content': content,
    'createdBy': createdBy,
    'createdAt': createdAt,
  };
}
