import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_course_table_demo/internal/utils/course_table_json_handlers.dart';
import 'package:flutter_course_table_demo/internal/types/course_table.dart';
import 'package:flutter_course_table_demo/internal/types/semester_info.dart';
import 'package:http/http.dart' as http;

Future<bool> authorizer(String? username, String? password) async {
  http.Response response = await http.get(
    Uri.parse('http://localhost:56789/login'),
    headers: {
      HttpHeaders.authorizationHeader: 'Basic ${utf8.fuse(base64).encode('$username:$password')}'
    },
  );
  if (response.statusCode != 200) {
    return false;
  }
  return true;
}

Future<List<SemesterInfo>?> fetchSemesterList(String? username, String? password) async {
  http.Response response = await http.get(
    Uri.parse('http://localhost:56789/semester-list'),
    headers: {
      HttpHeaders.authorizationHeader: 'Basic ${utf8.fuse(base64).encode('$username:$password')}'
    },
  );

  if (response.statusCode != 200) {
    return null;
  }

  return parseSemesterInfo(response.bodyBytes);
}

Future<List<SemesterInfo>> parseSemesterInfo(Uint8List responseBody) async {
  var responseString = const Utf8Decoder().convert(responseBody);

  final json = jsonDecode(responseString).cast<Map<String, dynamic>>();
  return json.map<SemesterInfo>((json) => SemesterInfo.fromJson(json)).toList();
}

Future<CourseTable?> fetchCourseTable(String? username, String? password, String? semesterId, String? firstWeekDate) async {
  if (username == null || password == null || semesterId == null || firstWeekDate == null) return null;
  http.Response response = await http.get(
    Uri.parse('http://localhost:56789/course-table'),
    headers: {
      HttpHeaders.authorizationHeader: 'Basic ${utf8.fuse(base64).encode('$username:$password')}',
      'semesterId': semesterId,
    },
  );

  if (response.statusCode != 200) return null;

  return await parseCourseInfo(response.bodyBytes, firstWeekDate);
}

Future<CourseTable> parseCourseInfo(Uint8List responseBody, String firstWeekDate) async {
  var responseString = const Utf8Decoder().convert(responseBody);

  return apiJsonToCourseTable(responseString, firstWeekDate);
}
