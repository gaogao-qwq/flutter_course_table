import 'dart:convert';

import 'course_info.dart';

class CourseTable {
  String firstWeekDate;
  final int? row;
  final int? col;
  final int? week;
  final List<List<CourseInfo>> data;

  CourseTable({
    required this.firstWeekDate,
    this.row,
    this.col,
    this.week,
    required this.data,
  });

  factory CourseTable.fromJson(String jsonString, String? firstWeekDate) {
    final jsonMap = jsonDecode(jsonString);
    List<dynamic> jsonData;
    jsonMap['data'] is String
        ? jsonData = jsonDecode(jsonMap['data'])
        : jsonData = jsonMap['data'];
    List<List<CourseInfo>> data = [[]];
    for (int i = 0; i < jsonData.length; i++) {
      for (int j = 0; j < jsonData[i].length; j++) {
        var tmp = CourseInfo.fromJson(jsonData[i][j]);
        data[i].add(tmp);
      }
      if (i != jsonData.length-1) data.add(<CourseInfo>[]);
    }
    return CourseTable(
      firstWeekDate: firstWeekDate ?? jsonMap['firstWeekDate'],
      row: jsonMap['row'],
      col: jsonMap['col'],
      week: jsonMap['week'],
      data: data,
    );
  }

  static Map<String, dynamic> toJson(CourseTable v) => {
    'firstWeekDate': v.firstWeekDate,
    'row': v.row,
    'col': v.col,
    'week': v.week,
    'data': jsonEncode(v.data, toEncodable: (Object? v) => v is CourseInfo
        ? CourseInfo.toJson(v)
        : throw UnsupportedError('Cannot convert to JSON: $v'))
  };
}