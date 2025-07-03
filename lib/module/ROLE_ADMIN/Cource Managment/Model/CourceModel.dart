class Course {
  final int courseId;
  final String courseName;
  final String courseDescription;
  final bool enabled;
  final ImageData image;
  final int subCategoryId;

  Course({
    required this.courseId,
    required this.courseName,
    required this.courseDescription,
    required this.enabled,
    required this.image,
    required this.subCategoryId,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseId: json['courseId'],
      courseName: json['courseName'],
      courseDescription: json['courseDescription'],
      enabled: json['enabled'],
      image: ImageData.fromJson(json['image']),
      subCategoryId: json['subCategoryId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'courseName': courseName,
      'courseDescription': courseDescription,
      'enabled': enabled,
      'image': image.toJson(),
      'subCategoryId': subCategoryId,
    };
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
