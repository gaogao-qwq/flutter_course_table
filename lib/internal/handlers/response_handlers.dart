// A simple course table app
// Copyright (C) 2023 Zhihao Zhou
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_course_table/internal/types/course_table.dart';
import 'package:flutter_course_table/internal/types/semester_info.dart';
import 'package:flutter_course_table/internal/utils/course_table_json_handlers.dart';
import 'package:http/http.dart' as http;

Future<List<SemesterInfo>?> fetchSemesterList(
    String? username, String? password) async {
  http.Response response = await http.get(
    Uri.parse('http://localhost:56789/v1/semester-list'),
    headers: {
      HttpHeaders.authorizationHeader:
          'Basic ${utf8.fuse(base64).encode('$username:$password')}'
    },
  );

  if (response.statusCode >= 500 && response.statusCode < 600) {
    throw const HttpException("服务端错误，请联系维护者");
  }
  if (response.statusCode == HttpStatus.unauthorized) {
    throw const HttpException("身份验证失败");
  }
  if (response.statusCode != HttpStatus.ok) {
    throw const HttpException("未知错误发生");
  }

  return parseSemesterInfo(response.bodyBytes);
}

Future<List<SemesterInfo>> parseSemesterInfo(Uint8List responseBody) async {
  var responseString = const Utf8Decoder().convert(responseBody);

  final json = jsonDecode(responseString).cast<Map<String, dynamic>>();
  return json.map<SemesterInfo>((json) => SemesterInfo.fromJson(json)).toList();
}

Future<CourseTable?> fetchCourseTable(String? username, String? password,
    String? semesterId, String? firstWeekDate, String? name) async {
  if (username == null ||
      password == null ||
      semesterId == null ||
      firstWeekDate == null ||
      name == null) return null;
  http.Response response = await http.get(
    Uri.parse('http://localhost:56789/v1/course-table'),
    headers: {
      HttpHeaders.authorizationHeader:
          'Basic ${utf8.fuse(base64).encode('$username:$password')}',
      'semesterId': semesterId,
    },
  );

  if (response.statusCode >= 500 && response.statusCode < 600) {
    throw const HttpException("服务端错误，请联系维护者");
  }
  if (response.statusCode == HttpStatus.unauthorized) {
    throw const HttpException("身份验证失败");
  }
  if (response.statusCode != HttpStatus.ok) {
    throw const HttpException("未知错误发生");
  }

  return await parseCourseInfo(response.bodyBytes, firstWeekDate, name);
}

Future<CourseTable?> fetchTestCourseTable(
    String firstWeekDate, String name) async {
  http.Response response = await http.get(
    Uri.parse('http://localhost:56789/v1/test'),
  );
  return await parseCourseInfo(response.bodyBytes, firstWeekDate, name);
}

Future<CourseTable?> parseCourseInfo(
    Uint8List responseBody, String firstWeekDate, String name) async {
  var responseString = const Utf8Decoder().convert(responseBody);

  return apiJsonToCourseTable(responseString, firstWeekDate, name);
}
