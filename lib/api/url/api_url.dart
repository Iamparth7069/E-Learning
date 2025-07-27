class ApiUrl {
  static const baseUrl = 'https://foal-true-supposedly.ngrok-free.app/';
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
  static const getAllCourse = '${baseUrl}api/v1/courses/instructor/my-courses';
  static const AddCourse = '${baseUrl}api/v1/courses/';
  static const CourseEnableApi = '${baseUrl}api/v1/courses/';

  static const addLession = '${baseUrl}api/v1/lessons/';

  static const getAllLession = '${baseUrl}api/v1/lessons/course/';
  static const getLessionDetails = '${baseUrl}api/v1/lessons/';
  static const getStremeUrl =  '${baseUrl}api/v1/videos/stream/';
  static const lessionDelete = '${baseUrl}api/v1/lessons/';

  static const getStremeUsingRange = '${baseUrl}api/v1/videos/stream/range/';
  static const updateLession = '${baseUrl}api/v1/lessons/';
  static const getUserByCourse = '${baseUrl}api/v1/enrollments/';
}
