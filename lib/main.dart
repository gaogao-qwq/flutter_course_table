import 'package:flutter/material.dart';
import 'package:flutter_course_table_demo/pages/home_page/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(CourseTableApp(prefs: prefs));
}

class CourseTableApp extends StatelessWidget {
  final SharedPreferences prefs;
  const CourseTableApp({
    super.key,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CourseTableHomePage(prefs: prefs));
  }
}
