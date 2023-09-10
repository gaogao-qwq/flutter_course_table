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
import 'package:flutter_course_table/configure_dependencies.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

final prefs = getIt<SharedPreferences>();

@singleton
class SharedPreferencesRepository {
  String getCurrentCourseTableName() {
    return prefs.getString("currCourseTableName") ?? "";
  }

  void setCurrentCourseTableName(String name) {
    prefs.setString("currCourseTableName", name);
  }

  bool isLightMode() {
    return prefs.getBool("useLightMode")!;
  }

  ThemeMode getThemeMode() {
    return prefs.getBool("useLightMode")! ? ThemeMode.light : ThemeMode.dark;
  }

  void useLightMode(bool useLightMode) {
    prefs.setBool("useLightMode", useLightMode);
  }
}
