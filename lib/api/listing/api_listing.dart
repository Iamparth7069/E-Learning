import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../SharedPrefrance/SharedPrefrance_helper.dart';

class NetworkService {
  static final Dio _dio = Dio();

  static Future<Map<String, dynamic>> _checkConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return {'error': true, 'message': 'No Internet Connection'};
    }
    return {'error': false};
  }

  static Future<Map<String, dynamic>> makeGetRequest({
    required String url,
    Map<String, String>? headers,
  }) async {
    final check = await _checkConnection();
    if (check['error']) return {'response': check['message'], 'statusCode': 500};

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      headers ??= {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${prefs.getString(SharedPrefHelper.token) ?? ''}',
      };

      final response = await _dio.get(url, options: Options(headers: headers));

      return {
        'response': response.data,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> makePostRequest({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final check = await _checkConnection();
    if (check['error']) return {'response': check['message'], 'statusCode': 500};

    try {
      headers ??= {'Content-Type': 'application/json'};

      final response = await _dio.post(
        url,
        data: body,
        options: Options(headers: headers),
      );

      return {
        'response': response.data,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> makePutRequest({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final check = await _checkConnection();
    if (check['error']) return {'response': check['message'], 'statusCode': 500};

    try {
      headers ??= {'Content-Type': 'application/json'};

      final response = await _dio.put(
        url,
        data: body,
        options: Options(headers: headers),
      );

      return {
        'response': response.data,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> makePatchRequest({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final check = await _checkConnection();
    if (check['error']) return {'response': check['message'], 'statusCode': 500};

    try {
      headers ??= {'Content-Type': 'application/json'};

      final response = await _dio.patch(
        url,
        data: body,
        options: Options(headers: headers),
      );

      return {
        'response': response.data,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return _handleError(e);
    }
  }

  static Future<Map<String, dynamic>> makeMultipartPostRequest({
    required String url,
    Map<String, String>? headers,
    Map<String, String>? fields,
    List<Map<String, dynamic>>? files,
  }) async {
    final check = await _checkConnection();
    if (check['error']) return {'response': check['message'], 'statusCode': 500};

    try {
      FormData formData = FormData.fromMap(fields ?? {});

      if (files != null) {
        for (var file in files) {
          formData.files.add(
            MapEntry(
              file['name'],
              await MultipartFile.fromFile(file['filePath']),
            ),
          );
        }
      }

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(headers: headers, contentType: 'multipart/form-data'),
      );

      return {
        'response': response.data,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return _handleError(e);
    }
  }

  static Map<String, dynamic> _handleError(dynamic error) {
    if (error is DioError) {
      return {
        'response': error.response?.data ?? error.message,
        'statusCode': error.response?.statusCode ?? 500,
      };
    } else {
      return {
        'response': error.toString(),
        'statusCode': 500,
      };
    }
  }

  static Future<Map<String, dynamic>> makeMultipartPutRequest({
    required String url,
    Map<String, String>? headers,
    Map<String, String>? fields,
    List<Map<String, dynamic>>? files,
  }) async {
    final check = await _checkConnection();
    if (check['error']) return {'response': check['message'], 'statusCode': 500};

    try {
      FormData formData = FormData.fromMap(fields ?? {});

      if (files != null) {
        for (var file in files) {
          formData.files.add(
            MapEntry(
              file['name'],
              await MultipartFile.fromFile(file['filePath']),
            ),
          );
        }
      }

      final response = await _dio.put(
        url,
        data: formData,
        options: Options(
          headers: headers,
          contentType: 'multipart/form-data',
        ),
      );

      return {
        'response': response.data,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return _handleError(e);
    }
  }

}


