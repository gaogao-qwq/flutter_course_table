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

import 'package:flutter/cupertino.dart';
import 'package:flutter_course_table/configure_dependencies.dart';
import 'package:flutter_course_table/internal/database/course_table_repository.dart';
import 'package:flutter_course_table/internal/prefs/shared_preferences_repository.dart';
import 'package:flutter_course_table/internal/types/course_table.dart';
import 'package:package_info_plus/package_info_plus.dart';

final courseTableRepository = getIt<CourseTableRepository>();
final prefsRepository = getIt<SharedPreferencesRepository>();

class CourseTableData with ChangeNotifier {
  CourseTable? _courseTable;
  List<String> _courseTableNames;
  late int _currWeek;

  CourseTableData(this._courseTableNames, this._courseTable) {
    _currWeek = getInitWeek();
  }

  CourseTable? get courseTable => _courseTable;
  List<String> get courseTableNames => _courseTableNames;
  int get currWeek => _currWeek;

  int getInitWeek() {
    if (courseTable == null) return 1;
    DateTime firstWeekDateTime = DateTime.parse(courseTable!.firstWeekDate);
    if (DateTime.now().isBefore(firstWeekDateTime)) return 1;
    int initWeek = DateTime.now().difference(firstWeekDateTime).inDays ~/ 7;
    if (initWeek > (courseTable!.week!)) {
      return courseTable!.week!;
    }
    return initWeek + 1;
  }

  Future<void> add(String name, String json) async {
    await courseTableRepository.insertCourseTable(name, json);
    _courseTableNames = await courseTableRepository.getCourseTableNames();
    await changeByName(name);
    notifyListeners();
  }

  Future<void> changeByName(String name) async {
    if (!_courseTableNames.contains(name)) {
      throw Exception("Course table not exist");
    }
    _courseTable = await courseTableRepository.getCourseTableByName(name);
    prefsRepository.setCurrentCourseTableName(name);
    _currWeek = getInitWeek();
    notifyListeners();
  }

  Future<void> deleteByName(String name) async {
    if (!_courseTableNames.contains(name)) {
      throw Exception("Course table not exist");
    }
    final currentName = prefsRepository.getCurrentCourseTableName();
    if (currentName == name) {
      await courseTableRepository.deleteCourseTableByName(name);
      _courseTableNames.remove(name);
      _courseTable = _courseTableNames.isEmpty
          ? null
          : await courseTableRepository
              .getCourseTableByName(_courseTableNames.first);
      _currWeek = getInitWeek();
      notifyListeners();
      return;
    }
    await courseTableRepository.deleteCourseTableByName(name);
    _courseTableNames.remove(name);
    notifyListeners();
  }

  Future<void> deleteByNames(List<String> names) async {
    for (var e in names) {
      if (!_courseTableNames.contains(e)) {
        throw Exception("Course table $e not exist");
      }
      await courseTableRepository.deleteCourseTableByName(e);
      _courseTableNames.remove(e);
    }
    if (_courseTableNames.isEmpty) {
      _courseTable = null;
      prefsRepository.setCurrentCourseTableName("");
      _currWeek = getInitWeek();
      notifyListeners();
      return;
    }
    final currentName = prefsRepository.getCurrentCourseTableName();
    if (!_courseTableNames.contains(currentName)) {
      _courseTable = await courseTableRepository
          .getCourseTableByName(_courseTableNames.first);
    }
    _currWeek = getInitWeek();
    notifyListeners();
  }

  void setCurrWeek(int week) {
    _currWeek = week;
    notifyListeners();
  }
}

class CourseTableSelectorData with ChangeNotifier {
  List<String> courseTableNames;
  bool _isSelectionMode = false;
  bool _isSelectAll = false;
  late List<bool> _selected;

  CourseTableSelectorData(this.courseTableNames) {
    _selected = List<bool>.generate(courseTableNames.length, (_) => false);
  }

  bool get isSelectionMode => _isSelectionMode;
  bool get isSelectAll => _isSelectAll;
  List<bool> get selected => _selected;

  void toggle(int index) {
    _selected[index] = !_selected[index];
    if (_selected.every((element) => element == true)) {
      _isSelectAll = true;
    } else {
      _isSelectAll = false;
    }
    notifyListeners();
  }

  void setSelectionMode(bool isSelectionMode) {
    _isSelectionMode = isSelectionMode;
    if (!isSelectionMode) {
      _selected = List<bool>.generate(courseTableNames.length, (_) => false);
    }
    notifyListeners();
  }

  void setSelectAll(bool isSelectAll) {
    _isSelectAll = isSelectAll;
    if (isSelectAll) {
      _selected = List<bool>.generate(courseTableNames.length, (_) => true);
    } else {
      _selected = List<bool>.generate(courseTableNames.length, (_) => false);
    }
    notifyListeners();
  }

  void removeSelectedItems() {
    courseTableNames.removeWhere((element) {
      int index = courseTableNames.indexOf(element);
      bool isSelected =
          index >= 0 && index < _selected.length && _selected[index];
      return isSelected;
    });
    _isSelectionMode = false;
    notifyListeners();
  }
}

class AppSettingData with ChangeNotifier {
  late bool _isLightMode;
  late String _currCourseTableName;
  late String _crawlerApiUrl;

  AppSettingData() {
    _isLightMode = prefsRepository.isLightMode();
    _currCourseTableName = prefsRepository.getCurrentCourseTableName();
    _crawlerApiUrl = prefsRepository.getCrawlerApiUrl();
  }

  bool get isLightMode => _isLightMode;
  String get currCourseTableName => _currCourseTableName;
  String get crawlerApiUrl => _crawlerApiUrl;

  void useLightMode(bool useLightMode) {
    _isLightMode = useLightMode;
    prefs.setBool("useLightMode", useLightMode);
    notifyListeners();
  }

  void setCrawlerApiUrl(String url) {
    _crawlerApiUrl = url;
    prefs.setString("crawlerApiUrl", url);
    notifyListeners();
  }
}

class AppInfoData {
  final PackageInfo _packageInfo;

  AppInfoData(this._packageInfo);

  String get appName => _packageInfo.appName;
  String get packageName => _packageInfo.packageName;
  String get version => _packageInfo.version;
  String get buildNumber => _packageInfo.buildNumber;
  String get buildSignature => _packageInfo.buildSignature;
  String get legalese => "Copyright © 2023 Zhihao Zhou under GPL-3.0 license";
}
