class UserModel {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final bool enabled;
  final String role;
  final UserImage? image;

  UserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.enabled,
    required this.role,
    this.image,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      enabled: json['enabled'] ?? false,
      role: json['role'] ?? '',
      image: json['image'] != null ? UserImage.fromJson(json['image']) : null,
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
      'image': image?.toJson(),
    };
  }

  String get fullName => '$firstName $lastName';
}

class UserImage {
  final int imageId;
  final String fileName;
  final String imageUrl;
  final String contentType;
  final String objectName;

  UserImage({
    required this.imageId,
    required this.fileName,
    required this.imageUrl,
    required this.contentType,
    required this.objectName,
  });

  factory UserImage.fromJson(Map<String, dynamic> json) {
    return UserImage(
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


