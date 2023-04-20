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

Future<CourseTable?> parseCourseInfo(Uint8List responseBody, String firstWeekDate) async {
  var responseString = const Utf8Decoder().convert(responseBody);

  return apiJsonToCourseTable(responseString, firstWeekDate);
}
