import 'StudentCourse.dart';
import 'EnrollmentModel.dart';

class EnrolledCourseModel {
  final EnrollmentModel enrollment;
  final StudentCourse course;
  final String? userName;
  final String? userEmail;

  EnrolledCourseModel({
    required this.enrollment,
    required this.course,
    this.userName,
    this.userEmail,
  });

  // Helper getters
  int get enrollmentId => enrollment.enrollmentId;
  int get userId => enrollment.userId;
  int get courseId => enrollment.courseId;
  bool get isCompleted => enrollment.completed;
  
  String get courseName => course.courseName ?? 'Untitled Course';
  String get courseDescription => course.courseDescription ?? '';
  String? get courseImageUrl => course.image?.imageUrl;
  bool get isEnabled => course.enabled ?? false;
}

