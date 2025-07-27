/// courseId : 2
/// courseName : "trsy itdy adad"
/// courseDescription : "nulla occaecat minim"
/// enabled : true
/// image : {"imageId":55,"fileName":"compressed_IMG_20250726_222124.jpg","imageUrl":"https://storage.googleapis.com/we_image_bucket/course/5a7636aa-1aef-4f4c-88c3-a40c30d55cec-compressed_IMG_20250726_222124.jpg","contentType":"application/octet-stream","objectName":"course/5a7636aa-1aef-4f4c-88c3-a40c30d55cec-compressed_IMG_20250726_222124.jpg"}
/// subCategoryId : 4
/// instructorId : 7

class StudentModel {
  StudentModel({
      this.courseId, 
      this.courseName, 
      this.courseDescription, 
      this.enabled, 
      this.image, 
      this.subCategoryId, 
      this.instructorId,});

  StudentModel.fromJson(dynamic json) {
    courseId = json['courseId'];
    courseName = json['courseName'];
    courseDescription = json['courseDescription'];
    enabled = json['enabled'];
    image = json['image'] != null ? Image.fromJson(json['image']) : null;
    subCategoryId = json['subCategoryId'];
    instructorId = json['instructorId'];
  }
  int? courseId;
  String? courseName;
  String? courseDescription;
  bool? enabled;
  Image? image;
  int? subCategoryId;
  int? instructorId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['courseId'] = courseId;
    map['courseName'] = courseName;
    map['courseDescription'] = courseDescription;
    map['enabled'] = enabled;
    if (image != null) {
      map['image'] = image?.toJson();
    }
    map['subCategoryId'] = subCategoryId;
    map['instructorId'] = instructorId;
    return map;
  }

}


class Image {
  Image({
      this.imageId, 
      this.fileName, 
      this.imageUrl, 
      this.contentType, 
      this.objectName,});

  Image.fromJson(dynamic json) {
    imageId = json['imageId'];
    fileName = json['fileName'];
    imageUrl = json['imageUrl'];
    contentType = json['contentType'];
    objectName = json['objectName'];
  }
  int? imageId;
  String? fileName;
  String? imageUrl;
  String? contentType;
  String? objectName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['imageId'] = imageId;
    map['fileName'] = fileName;
    map['imageUrl'] = imageUrl;
    map['contentType'] = contentType;
    map['objectName'] = objectName;
    return map;
  }

}