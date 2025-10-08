class Course {
  final int courseId;
  final String courseName;
  final String courseDescription;
  final bool enabled;
  final ImageData image;
  final int subCategoryId;
  final int instructorId;

  Course({
    required this.courseId,
    required this.courseName,
    required this.courseDescription,
    required this.enabled,
    required this.image,
    required this.subCategoryId,
    required this.instructorId,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      courseId: json['courseId'],
      courseName: json['courseName'],
      courseDescription: json['courseDescription'],
      enabled: json['enabled'],
      image: ImageData.fromJson(json['image']),
      subCategoryId: json['subCategoryId'],
      instructorId: json['instructorId'],
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
      'instructorId': instructorId,
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

class Enrollment {
  final int enrollmentId;
  final int userId;
  final int courseId;
  final bool completed;

  Enrollment({
    required this.enrollmentId,
    required this.userId,
    required this.courseId,
    required this.completed,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      enrollmentId: json['enrollmentId'],
      userId: json['userId'],
      courseId: json['courseId'],
      completed: json['completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enrollmentId': enrollmentId,
      'userId': userId,
      'courseId': courseId,
      'completed': completed,
    };
  }
}

class User {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final bool enabled;
  final String role;
  final ImageData image;

  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.enabled,
    required this.role,
    required this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      enabled: json['enabled'],
      role: json['role'],
      image: ImageData.fromJson(json['image']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'enabled': enabled,
      'role': role,
      'image': image.toJson(),
    };
  }

  String get fullName => '$firstName $lastName';
}
