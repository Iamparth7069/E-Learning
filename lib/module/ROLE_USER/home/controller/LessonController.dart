import 'package:get/get.dart';
import 'package:shaktihub/api/listing/api_listing.dart';
import 'package:shaktihub/api/url/api_url.dart';
import 'package:shaktihub/module/ROLE_USER/home/Model/LessonModel.dart';

import '../../../../SharedPrefrance/SharedPrefrance_helper.dart';

class LessonController extends GetxController {
  List<LessonModel> lessons = <LessonModel>[];
  bool isLoading = false;
  String? errorMessage;
  int? currentCourseId;

  SharedPrefHelper sharedPrefHelper = SharedPrefHelper();

  Future<void> loadLessonsByCourseId(int courseId) async {
    try {
      isLoading = true;
      errorMessage = null;
      currentCourseId = courseId;
      update();

      final token = sharedPrefHelper.getString(SharedPrefHelper.token);
      if (token == null || token.isEmpty) {
        errorMessage = 'Authentication token not found';
        return;
      }

      Map<String, String> header = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      print("📚 Fetching lessons for course ID: $courseId");

      // Try the primary endpoint first
      String uri = '${ApiUrl.getLessonsByCourseId}$courseId';
      print("🌐 Trying primary API URL: $uri");

      var response = await NetworkService.makeGetRequest(url: uri, headers: header);
      
      // If primary endpoint fails or returns unexpected format, try alternative
      if (response['statusCode'] != 200 || 
          (response["response"] is Map && !response["response"].containsKey('lessons'))) {
        print("🔄 Primary endpoint failed or returned unexpected format, trying alternative...");
        String alternativeUri = '${ApiUrl.getLessonsByCourseIdAlternative}$courseId';
        print("🌐 Trying alternative API URL: $alternativeUri");
        
        response = await NetworkService.makeGetRequest(url: alternativeUri, headers: header);
      }
      
      print("📊 Lessons response: ${response['statusCode']}");
      
      if (response['statusCode'] == 200) {
        print("📋 Raw response: ${response['response']}");
        
        // Check if response is a Map (single course object) or List (lessons array)
        if (response["response"] is Map<String, dynamic>) {
          // Response is a course object, extract lessons from it
          Map<String, dynamic> courseData = response["response"];
          print("📚 Response is a course object, looking for lessons...");
          
          // Check if lessons are in a 'lessons' field
          if (courseData.containsKey('lessons') && courseData['lessons'] is List) {
            List<dynamic> lessonData = courseData['lessons'];
            print("✅ Found ${lessonData.length} lessons in course object");
            
            lessons = lessonData.map((json) => LessonModel.fromJson(json)).toList();
          } else {
            // If no lessons field, check if the course object itself contains lesson data
            print("❌ No 'lessons' field found in course object");
            print("📋 Available fields: ${courseData.keys.toList()}");
            
            // Try to find lessons in other possible field names
            List<String> possibleLessonFields = ['lessonList', 'lessonsList', 'courseLessons', 'content'];
            bool foundLessons = false;
            
            for (String field in possibleLessonFields) {
              if (courseData.containsKey(field) && courseData[field] is List) {
                List<dynamic> lessonData = courseData[field];
                print("✅ Found lessons in field '$field': ${lessonData.length} lessons");
                lessons = lessonData.map((json) => LessonModel.fromJson(json)).toList();
                foundLessons = true;
                break;
              }
            }
            
            if (!foundLessons) {
              print("❌ No lessons found in any expected field");
              lessons = [];
            }
          }
        } else if (response["response"] is List) {
          // Response is directly a list of lessons
          List<dynamic> lessonData = response["response"];
          print("✅ Found ${lessonData.length} lessons in direct list");
          
          lessons = lessonData.map((json) => LessonModel.fromJson(json)).toList();
        } else {
          print("❌ Unexpected response format: ${response["response"].runtimeType}");
          lessons = [];
        }
        
        // Sort lessons by sequence number
        lessons.sort((a, b) => a.sequenceNumber.compareTo(b.sequenceNumber));
        
        print("🎉 Successfully loaded ${lessons.length} lessons");
        errorMessage = null;
      } else {
        errorMessage = 'Failed to load lessons: ${response['statusCode']}';
        print("❌ Failed to fetch lessons: ${response['statusCode']}");
        print("📋 Response: ${response['response']}");
      }
    } catch (e) {
      errorMessage = 'Error loading lessons: ${e.toString()}';
      print("❌ Error loading lessons: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  void clearLessons() {
    lessons.clear();
    errorMessage = null;
    currentCourseId = null;
    update();
  }

  // Helper method to get lesson by ID
  LessonModel? getLessonById(int lessonId) {
    try {
      return lessons.firstWhere((lesson) => lesson.lessonId == lessonId);
    } catch (e) {
      return null;
    }
  }

  // Helper method to get next lesson
  LessonModel? getNextLesson(int currentLessonId) {
    try {
      final currentIndex = lessons.indexWhere((lesson) => lesson.lessonId == currentLessonId);
      if (currentIndex != -1 && currentIndex < lessons.length - 1) {
        return lessons[currentIndex + 1];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Helper method to get previous lesson
  LessonModel? getPreviousLesson(int currentLessonId) {
    try {
      final currentIndex = lessons.indexWhere((lesson) => lesson.lessonId == currentLessonId);
      if (currentIndex > 0) {
        return lessons[currentIndex - 1];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
