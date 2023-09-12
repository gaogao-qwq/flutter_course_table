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
import 'package:flutter_course_table/configure_dependencies.dart';
import 'package:flutter_course_table/internal/database/course_table_repository.dart';
import 'package:flutter_course_table/internal/prefs/shared_preferences_repository.dart';
import 'package:flutter_course_table/pages/data.dart';
import 'package:flutter_course_table/pages/home_page/home_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

final courseTableRepository = getIt<CourseTableRepository>();
final prefsRepository = getIt<SharedPreferencesRepository>();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final packageInfo = await PackageInfo.fromPlatform();
  await init();
  final courseTableNames = await courseTableRepository.getCourseTableNames();
  final currCourseTableName = prefsRepository.getCurrentCourseTableName();
  final courseTable =
      await courseTableRepository.getCourseTableByName(currCourseTableName);
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => AppSettingData()),
    ChangeNotifierProvider(
      create: (context) => CourseTableData(courseTableNames, courseTable),
    ),
    Provider(create: (context) => AppInfoData(packageInfo)),
  ], child: const CourseTableApp()));
}

class CourseTableApp extends StatefulWidget {
  const CourseTableApp({super.key});

  @override
  State<StatefulWidget> createState() => _CourseTableAppState();
}

class _CourseTableAppState extends State<CourseTableApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = context.select((AppSettingData data) => data.isLightMode)
        ? ThemeMode.light
        : ThemeMode.dark;
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
      home: const CourseTableHomePage(),
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
