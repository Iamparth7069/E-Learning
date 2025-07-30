class StudentCourse {
  int? courseId;
  String? courseName;
  String? courseDescription;
  bool? enabled;
  ImageClass? image;
  int? subCategoryId;
  int? instructorId;
  double? avgRatting;

  StudentCourse({
    this.courseId,
    this.courseName,
    this.courseDescription,
    this.enabled,
    this.image,
    this.subCategoryId,
    this.avgRatting,
    this.instructorId,
  });

  factory StudentCourse.fromJson(Map<String, dynamic> json) {
    return StudentCourse(
      courseId: json['courseId'],
      courseName: json['courseName'],
      avgRatting: json['averageRating'] ?? 0.0,
      courseDescription: json['courseDescription'],
      enabled: json['enabled'],
      image: json['image'] != null ? ImageClass.fromJson(json['image']) : null,
      subCategoryId: json['subCategoryId'],
      instructorId: json['instructorId'],
    );
  }

  Map<String, dynamic> toJson() => {
    'courseId': courseId,
    'courseName': courseName,
    'courseDescription': courseDescription,
    'enabled': enabled,
    if (image != null) 'image': image!.toJson(),
    'subCategoryId': subCategoryId,
    'instructorId': instructorId,
  };
}


class ImageClass {
  int? imageId;
  String? fileName;
  String? imageUrl;
  String? contentType;
  String? objectName;

  ImageClass({
    this.imageId,
    this.fileName,
    this.imageUrl,
    this.contentType,
    this.objectName,
  });

  factory ImageClass.fromJson(Map<String, dynamic> json) {
    print("📷 Image URL loaded: ${json['imageUrl']}");
    return ImageClass(
      imageId: json['imageId'],
      fileName: json['fileName'],
      imageUrl: json['imageUrl'],
      contentType: json['contentType'],
      objectName: json['objectName'],
    );
  }

  Map<String, dynamic> toJson() => {
    'imageId': imageId,
    'fileName': fileName,
    'imageUrl': imageUrl,
    'contentType': contentType,
    'objectName': objectName,
  };
}

