import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_course_table_demo/pages/home_page/home_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await ScreenUtil.ensureScreenSize();
  runApp(CourseTableApp(prefs: prefs));
}

class CourseTableApp extends StatefulWidget {
  final SharedPreferences prefs;
  const CourseTableApp({
    super.key,
    required this.prefs,
  });

  @override
  State<StatefulWidget> createState() => _CourseTableAppState();
}

class _CourseTableAppState extends State<CourseTableApp> {
  ThemeMode themeMode = ThemeMode.system;

  bool get useLightMode {
    switch (themeMode) {
      case ThemeMode.system:
        return SchedulerBinding.instance.window.platformBrightness == Brightness.light;
      case ThemeMode.light:
        return true;
      case ThemeMode.dark:
        return false;
    }
  }

  void handleBrightnessChange(bool useLightMode) {
    setState(() {
      themeMode = useLightMode ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  void initState() {
    super.initState();
    themeMode = ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: CourseTableAppScrollBehavior(),
      theme: ThemeData(
        colorSchemeSeed: Colors.purpleAccent,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: CourseTableHomePage(
        prefs: widget.prefs,
        handleBrightnessChange: handleBrightnessChange,
      ),
    );
  }
}

class CourseTableAppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
