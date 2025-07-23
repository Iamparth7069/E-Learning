// course_model.dart

class CourseModel {
  final int courseId;
  final String courseName;
  final String courseDescription;
  final bool enabled;
  final CourseImage image;
  final int subCategoryId;

  CourseModel({
    required this.courseId,
    required this.courseName,
    required this.courseDescription,
    required this.enabled,
    required this.image,
    required this.subCategoryId,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      courseId: json['courseId'],
      courseName: json['courseName'],
      courseDescription: json['courseDescription'],
      enabled: json['enabled'],
      image: CourseImage.fromJson(json['image']),
      subCategoryId: json['subCategoryId'],
    );
  }
}

class CourseImage {
  final int imageId;
  final String fileName;
  final String imageUrl;
  final String? contentType;
  final String objectName;

  CourseImage({
    required this.imageId,
    required this.fileName,
    required this.imageUrl,
    required this.contentType,
    required this.objectName,
  });

  factory CourseImage.fromJson(Map<String, dynamic> json) {
    return CourseImage(
      imageId: json['imageId'],
      fileName: json['fileName'],
      imageUrl: json['imageUrl'],
      contentType: json['contentType'],
      objectName: json['objectName'],
    );
  }
}
