import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

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
