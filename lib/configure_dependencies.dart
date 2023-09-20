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

import 'package:flutter/scheduler.dart';
import 'package:flutter_course_table/constants.dart';
import 'package:get_it/get_it.dart';
import 'package:github/github.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'configure_dependencies.config.dart';

final getIt = GetIt.instance;

@injectableInit
void configureDependencies() {
  getIt.init();
}

Future<void> init() async {
  initializeGitHub();
  await initializeSharedPreferences();
  await initializeDatabase();
  configureDependencies();
}

void initializeGitHub() {
  final github = GitHub();
  getIt.registerSingleton(github);
}

Future<void> initializeSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  bool isLightMode =
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.light;
  if (!prefs.containsKey("colorSeed")) {
    prefs.setString("colorSeed", ColorSeed.baseColor.label);
  }
  if (!prefs.containsKey("useLightMode")) {
    prefs.setBool("useLightMode", isLightMode);
  }
  if (!prefs.containsKey("currCourseTableName")) {
    prefs.setString("currCourseTableName", "");
  }
  if (!prefs.containsKey("crawlerApiUrl")) {
    prefs.setString("crawlerApiUrl", "");
  }
  getIt.registerSingleton(prefs);
}

Future<void> initializeDatabase() async {
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
  }
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  String databasePath = join(documentsDirectory.path, "flutter_course_table",
      "course_tables_database.db");

  final database = await databaseFactoryFfi.openDatabase(databasePath,
      options: OpenDatabaseOptions(
          version: 1,
          onCreate: (Database database, int version) async {
            await database.execute("CREATE TABLE course_tables_table ("
                "id INTEGER PRIMARY KEY AUTOINCREMENT,"
                "name TEXT UNIQUE NOT NULL,"
                "json TEXT UNIQUE NOT NULL)");
          }));

  getIt.registerSingleton(database, dispose: (db) async => await db.close());
}
