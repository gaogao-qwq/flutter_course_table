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