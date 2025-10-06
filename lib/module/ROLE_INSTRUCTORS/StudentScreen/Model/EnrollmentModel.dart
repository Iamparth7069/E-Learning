class EnrollmentModel {
  final int enrollmentId;
  final int userId;
  final int courseId;
  final bool completed;

  EnrollmentModel({
    required this.enrollmentId,
    required this.userId,
    required this.courseId,
    required this.completed,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json) {
    return EnrollmentModel(
      enrollmentId: json['enrollmentId'] ?? 0,
      userId: json['userId'] ?? 0,
      courseId: json['courseId'] ?? 0,
      completed: json['completed'] ?? false,
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


