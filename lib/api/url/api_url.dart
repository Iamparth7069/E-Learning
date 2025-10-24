class ApiUrl {
  //static const baseUrl = 'https://knapsacked-flor-hilariously.ngrok-free.dev/';
  static const baseUrl = 'http://10.157.143.160:8080/';
  static const loginApi = '${baseUrl}api/v1/auth/login';
  static const registerApi = '${baseUrl}api/v1/auth/register';

  static const googleLogin = '${baseUrl}api/v1/auth/google-login';
  static const gatAllCategory = '${baseUrl}api/v1/categories/all';
  static const addCategory = '${baseUrl}api/v1/categories/';
  static const addSubCategoryId = '${baseUrl}api/v1/subcategories/';

  static const allUser = '${baseUrl}api/v1/users/all';
  static const allInstructors = '${baseUrl}api/v1/users/instructors';
  static const allStudent = '${baseUrl}api/v1/users/students';
  static const getAllSubCategory = '${baseUrl}api/v1/subcategories/all';
  static const updateCategory = '${baseUrl}api/v1/categories/';
  static const updateSubCategory = '${baseUrl}api/v1/subcategories/';
  static const getAllSubCategoryById = '${baseUrl}api/v1/subcategories/category/';
  static const getAllCourseByInstructor = '${baseUrl}api/v1/courses/instructor/my-courses';
  static const AddCourse = '${baseUrl}api/v1/courses/';
  static const CourseEnableApi = '${baseUrl}api/v1/courses/';

  static const addLession = '${baseUrl}api/v1/lessons/async';

  static const getAllLession = '${baseUrl}api/v1/lessons/course/';
  static const getLessionDetails = '${baseUrl}api/v1/lessons/';
  static const getStremeUrl =  '${baseUrl}api/v1/videos/stream/';
  static const lessionDelete = '${baseUrl}api/v1/lessons/';

  static const getStremeUsingRange = '${baseUrl}api/v1/videos/stream/range/';
  static const updateLession = '${baseUrl}api/v1/lessons/';
  static const getUserByCourse = '${baseUrl}api/v1/enrollments/';
  static const enrollInCourse = '${baseUrl}api/v1/enrollments';
  static const getMyEnrollments = '${baseUrl}api/v1/enrollments/my-enrollment';
  static const getEnrollmentProgress = '${baseUrl}api/v1/enrollments/progress/';
  static const completeEnrollment = '${baseUrl}api/v1/enrollments/';
  static const getUserById = '${baseUrl}api/v1/users/';
  static const getUserProfile = '${baseUrl}api/v1/users/profile';
  static const changePassword = '${baseUrl}api/v1/users/change-password';
  static const getAllCourse =  '${baseUrl}api/v1/courses/all';
  static const getCourseById = '${baseUrl}api/v1/courses/';
  static const getLessonsByCourseId = '${baseUrl}api/v1/courses/';
  static const getLessonsByCourseIdAlternative = '${baseUrl}api/v1/lessons/course/';
  static const getAllPopularCourse =  '${baseUrl}api/v1/courses/popular';
  static const getCoursesBySubCategory = '${baseUrl}api/v1/courses/subcategory/';
  
  // Settings API endpoints
  static const updateProfile = '${baseUrl}api/v1/users/profile';
  static const getProfile = '${baseUrl}api/v1/users/profile';
  static const notificationSettings = '${baseUrl}api/v1/users/notification-settings';
  static const privacySettings = '${baseUrl}api/v1/users/privacy-settings';
  static const appSettings = '${baseUrl}api/v1/users/app-settings';
  static const clearCache = '${baseUrl}api/v1/users/clear-cache';
  static const contactSupport = '${baseUrl}api/v1/support/contact';
}
