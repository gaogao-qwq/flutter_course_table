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

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_course_table/internal/types/course_table.dart';
import 'package:flutter_course_table/internal/utils/course_table_json_handlers.dart';
import 'package:flutter_course_table/internal/utils/database_utils.dart';
import 'package:flutter_course_table/pages/home_page/home_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  if (Platform.isWindows || Platform.isLinux) {
    // Initialize FFI
    sqfliteFfiInit();
  }

  var databaseFactory = databaseFactoryFfi;
  var databasePath = await getApplicationDocumentsDirectory();
  var path = join(databasePath.path, "flutter_course_table","course_tables_database.db");
  OpenDatabaseOptions();
  final db = await databaseFactory.openDatabase(path, options: OpenDatabaseOptions(
    version: 1,
    onCreate: (Database database, int version) async {
        await database.execute("CREATE TABLE course_tables_table (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT UNIQUE NOT NULL, json TEXT UNIQUE NOT NULL)");
    }
  ));

  final List<String> names = await getCourseTableNames(db);
  final String currCourseTableName = prefs.getString('currCourseTableName') ?? "";
  final CourseTable? initCourseTable = currCourseTableName.isEmpty
      ? null
      : jsonToCourseTable(await getCourseTableJsonByName(db, currCourseTableName));
  runApp(CourseTableApp(initCourseTable: initCourseTable, names: names, prefs: prefs, database: db));
}

class CourseTableApp extends StatefulWidget {
  final CourseTable? initCourseTable;
  final List<String> names;
  final SharedPreferences prefs;
  final Database database;

  const CourseTableApp({
    super.key,
    required this.initCourseTable,
    required this.names,
    required this.prefs,
    required this.database,
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
    widget.prefs.setBool("useLightMode", useLightMode);
  }

  @override
  void initState() {
    super.initState();
    if (!widget.prefs.containsKey("useLightMode")) {
      widget.prefs.setBool("useLightMode", useLightMode);
    } else {
      themeMode = widget.prefs.getBool("useLightMode")! ? ThemeMode.light : ThemeMode.dark;
    }
  }

  @override
  void dispose() {
    widget.database.close();
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
        database: widget.database,
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
