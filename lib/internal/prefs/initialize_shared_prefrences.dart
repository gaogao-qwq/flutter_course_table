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

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_course_table/configure_dependencies.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initializeSharedPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  bool isLightMode =
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.light;
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
