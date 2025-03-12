import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../routes/app_pages.dart';

class NetworkService {
  static Future<Map<String, dynamic>> makeGetRequest({
    required String url,
    Map<String, String>? headers,
  }) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return {
        'response': "",
        'statusCode': 500,
      };
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // String? token = prefs.getString(PrefConstantsKey.token);

      headers ??= {
        'Content-Type': 'application/json',
        // 'Authorization': 'Bearer ${token ?? ""}',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      return {
        'response': jsonDecode(response.body),
        'statusCode': response.statusCode,
      };
    } catch (e) {
      print('Error: $e');
      return {
        'response': e.toString(),
        'statusCode': 500,
      };
    }
  }

  static Future<Map<String, dynamic>> makePostRequest({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return {
        'response': "No Internet Connection",
        'statusCode': 500,
      };
    }

    try {
      headers ??= {'Content-Type': 'application/json'};
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      return {
        'response': jsonDecode(response.body),
        'statusCode': response.statusCode,
      };
    } catch (e) {
      print('Error: $e');
      return {
        'response': 'Request failed: $e',
        'statusCode': 500,
      };
    }
  }

  static Future<Map<String, dynamic>> makeMultipartPostRequest({
    required String url,
    Map<String, String>? headers,
    Map<String, String>? fields,
    List<Map<String, dynamic>>? files,
  }) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return {
        'response': "",
        'statusCode': 500,
      };
    }
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));
      headers?.forEach((key, value) {
        request.headers[key] = value;
      });

      fields?.forEach((key, value) {
        request.fields[key] = value;
      });

      if (files != null) {
        for (var file in files) {
          request.files.add(
            await http.MultipartFile.fromPath(
              file['name'],
              file['filePath'],
            ),
          );
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return {
        'response': jsonDecode(response.body),
        'statusCode': response.statusCode,
      };
    } catch (e) {
      print('Error: $e');
      return {
        'response': e.toString(),
        'statusCode': 500,
      };
    }
  }
}
