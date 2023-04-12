import 'dart:convert';

import 'package:flutter_course_table_demo/internal/types/course_table.dart';

CourseTable apiJsonToCourseTable(String jsonString, String firstWeekDate) {
  return CourseTable.fromJson(jsonString, firstWeekDate);
}

CourseTable jsonToCourseTable(String jsonString) {
  return CourseTable.fromJson(jsonString, null);
}

String courseTableToJson(CourseTable courseTable) {
  String jsonString = jsonEncode(courseTable, toEncodable: (Object? v) => v is CourseTable
      ? CourseTable.toJson(v)
      : throw UnsupportedError('Cannot convert to JSON: $v'));
  return jsonString;
}

