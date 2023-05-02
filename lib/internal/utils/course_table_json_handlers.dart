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

import 'dart:convert';
import 'package:flutter_course_table_demo/internal/types/course_table.dart';

CourseTable? apiJsonToCourseTable(String? jsonString, String firstWeekDate, String name) {
  if (jsonString == null || jsonString.isEmpty) return null;
  return CourseTable.fromJson(jsonString, firstWeekDate, name);
}

CourseTable? jsonToCourseTable(String? jsonString) {
  if (jsonString == null || jsonString.isEmpty) return null;
  return CourseTable.fromJson(jsonString, null, null);
}

String courseTableToJson(CourseTable courseTable) {
  String jsonString = jsonEncode(courseTable, toEncodable: (Object? v) => v is CourseTable
      ? CourseTable.toJson(v)
      : throw UnsupportedError('Cannot convert to JSON: $v'));
  return jsonString;
}

