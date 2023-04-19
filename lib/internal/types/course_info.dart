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

class CourseInfo {
  final bool isEmpty;
  final String courseId;
  final String courseName;
  final String locationName;
  final int sectionBegin;
  final int sectionLength;
  final int weekNum;
  final int dateNum;

  const CourseInfo({
    this.isEmpty = false,
    required this.courseId,
    required this.courseName,
    required this.locationName,
    required this.sectionBegin,
    required this.sectionLength,
    required this.weekNum,
    required this.dateNum,
  });

  factory CourseInfo.fromJson(Map<String, dynamic> json) => CourseInfo(
    isEmpty: false,
    courseId: json['courseId'].toString(),
    courseName: json['courseName'].toString(),
    locationName: json['locationName'].toString(),
    sectionBegin: json['sectionBegin'] as int,
    sectionLength: json['sectionLength'] as int,
    weekNum: json['weekNum'] as int,
    dateNum: json['dateNum'] as int,
  );

  static Map<String, dynamic> toJson(CourseInfo v) => {
    'isEmpty': v.isEmpty,
    'courseId': v.courseId,
    'courseName': v.courseName,
    'locationName': v.locationName,
    'sectionBegin': v.sectionBegin,
    'sectionLength': v.sectionLength,
    'weekNum': v.weekNum,
    'dateNum': v.dateNum,
  };
}