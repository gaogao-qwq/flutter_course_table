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

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_course_table/internal/database/course_table_repository.dart';
import 'package:flutter_course_table/internal/database/initialize_database.dart';
import 'package:flutter_course_table/internal/types/course_table.dart';
import 'package:flutter_course_table/internal/utils/course_table_json_handlers.dart';
import 'package:flutter_course_table/pages/home_page/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  CourseTableRepository courseTableRepository =
      CourseTableRepository(db: await initializeDatabase());

  String? currCourseTableName =
      sharedPreferences.getString('currCourseTableName');

  List<String> courseTableNames =
      await courseTableRepository.getCourseTableNames();

  CourseTable? initCourseTable;
  if (currCourseTableName != null) {
    initCourseTable = jsonToCourseTable(await courseTableRepository
        .getCourseTableJsonByName(currCourseTableName));
  }

  runApp(CourseTableApp(
    initCourseTable: initCourseTable,
    names: courseTableNames,
    prefs: sharedPreferences,
    courseTableRepository: courseTableRepository,
  ));
}

class CourseTableApp extends StatefulWidget {
  final CourseTable? initCourseTable;
  final List<String> names;
  final SharedPreferences prefs;
  final CourseTableRepository courseTableRepository;

  const CourseTableApp(
      {super.key,
      required this.initCourseTable,
      required this.names,
      required this.prefs,
      required this.courseTableRepository});

  @override
  State<StatefulWidget> createState() => _CourseTableAppState();
}

class _CourseTableAppState extends State<CourseTableApp> {
  ThemeMode themeMode = ThemeMode.system;

  bool get useLightMode {
    switch (themeMode) {
      case ThemeMode.system:
        return SchedulerBinding
                .instance.platformDispatcher.platformBrightness ==
            Brightness.light;
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
    widget.prefs.setBool("useLightMode", useLightMode);
  }

  @override
  void initState() {
    super.initState();
    if (!widget.prefs.containsKey("useLightMode")) {
      widget.prefs.setBool("useLightMode", useLightMode);
    } else {
      themeMode = widget.prefs.getBool("useLightMode")!
          ? ThemeMode.light
          : ThemeMode.dark;
    }
  }

  @override
  void dispose() {
    widget.courseTableRepository.db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: CourseTableAppScrollBehavior(),
      themeMode: themeMode,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xff6750a4),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xff503d7e),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: CourseTableHomePage(
        initCourseTable: widget.initCourseTable,
        names: widget.names,
        useLightMode: useLightMode,
        handleBrightnessChange: handleBrightnessChange,
        prefs: widget.prefs,
        courseTableRepository: widget.courseTableRepository,
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
