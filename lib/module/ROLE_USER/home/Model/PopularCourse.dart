class PopularCourse {
  final int courseId;
  final String courseName;
  final String courseDescription;
  final bool enabled;
  final ImageData? image;
  final int subCategoryId;
  final int instructorId;
  final int enrollmentCount;
  final double averageRating;

  PopularCourse({
    required this.courseId,
    required this.courseName,
    required this.courseDescription,
    required this.enabled,
    this.image,
    required this.subCategoryId,
    required this.instructorId,
    required this.enrollmentCount,
    required this.averageRating,
  });

  factory PopularCourse.fromJson(Map<String, dynamic> json) {
    final courseJson = json['course'];
    return PopularCourse(
      courseId: courseJson['courseId'],
      courseName: courseJson['courseName'],
      courseDescription: courseJson['courseDescription'],
      enabled: courseJson['enabled'],
      image: courseJson['image'] != null
          ? ImageData.fromJson(courseJson['image'])
          : null,
      subCategoryId: courseJson['subCategoryId'],
      instructorId: courseJson['instructorId'],
      enrollmentCount: json['enrollmentCount'] ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ImageData {
  final int imageId;
  final String fileName;
  final String imageUrl;
  final String contentType;
  final String objectName;

  ImageData({
    required this.imageId,
    required this.fileName,
    required this.imageUrl,
    required this.contentType,
    required this.objectName,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      imageId: json['imageId'],
      fileName: json['fileName'],
      imageUrl: json['imageUrl'],
      contentType: json['contentType'],
      objectName: json['objectName'],
    );
  }
}
