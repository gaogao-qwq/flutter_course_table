import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CourseTable {
  final List<CourseInfo> data;

  const CourseTable({
    required this.data,
  });
}

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

  factory CourseInfo.fromJson(Map<String, dynamic> json) {
    return CourseInfo(
      isEmpty: false,
      courseId: json['courseId'].toString(),
      courseName: json['courseName'].toString(),
      locationName: json['locationName'].toString(),
      sectionBegin: json['sectionBegin'] as int,
      sectionLength: json['sectionLength'] as int,
      weekNum: json['weekNum'] as int,
      dateNum: json['dateNum'] as int,
    );
  }
}

Future<CourseTable> fetchCourseTable(String? username, String? password) async {
  final response = await http.get(
    Uri.parse('http://localhost:56789/login'),
    headers: {
      HttpHeaders.authorizationHeader: 'Basic ${utf8.fuse(base64).encode('$username:$password')}',
    },
  );
  return parseCourseInfo(response.bodyBytes);
}

CourseTable parseCourseInfo(Uint8List responseBody) {
  var responseString = const Utf8Decoder().convert(responseBody);
  final jsonMap = jsonDecode(responseString).cast<Map<String, dynamic>>();
  return CourseTable(
    data: jsonMap.map<CourseInfo>((json) => CourseInfo.fromJson(json)).toList(),
  );
}
