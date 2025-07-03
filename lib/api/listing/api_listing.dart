import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../SharedPrefrance/SharedPrefrance_helper.dart';
import '../../routes/app_pages.dart';

class NetworkService {
  static Future<Map<String, dynamic>> makeGetRequest({
    required String url,
    Map<String, String>? headers,
  }) async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      return {
        'response': "No internet connection",
        'statusCode': 500,
      };
    }
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      headers ??= {
        'Content-Type': 'application/json',
        // Uncomment if you need a token:
        'Authorization': 'bearerToken ${prefs.getString(SharedPrefHelper.token) ?? ''}',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.body.isNotEmpty &&
          response.headers['content-type']?.contains('application/json') == true) {
        return {
          'response': jsonDecode(response.body),
          'statusCode': response.statusCode,
        };
      } else {
        // Handle non-JSON or empty response gracefully
        return {
          'response': response.body,
          'statusCode': response.statusCode,
        };
      }
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


  static Future<Map<String, dynamic>> makePutRequest({
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

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print("PUT Request to: $url");
      print("Headers: $headers");
      print("Body: $body");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      dynamic parsedBody;
      if (response.body.isNotEmpty &&
          response.headers['content-type']?.contains('application/json') == true) {
        parsedBody = jsonDecode(response.body);
      } else {
        parsedBody = response.body;
      }

      return {
        'response': parsedBody,
        'statusCode': response.statusCode,
      };
    } catch (e) {
      print('Error in PUT request: $e');
      return {
        'response': 'Request failed: $e',
        'statusCode': 500,
      };
    }
  }


}
