import 'package:flutter/material.dart';

import 'home_page.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const CourseTableApp());
}

class CourseTableApp extends StatelessWidget {
  const CourseTableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CourseTableHomePage(),
    );
  }
}
