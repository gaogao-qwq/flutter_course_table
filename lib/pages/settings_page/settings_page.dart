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
import 'package:flutter_course_table/constants.dart';
import 'package:flutter_course_table/internal/utils/database_utils.dart';
import 'package:flutter_course_table/pages/settings_page/change_current_course_table_dialog.dart';
import 'package:flutter_course_table/pages/settings_page/delete_stored_course_table_dialog.dart';
import 'package:flutter_course_table/pages/settings_page/export_course_table_to_xlsx_dialog.dart';
import 'package:flutter_course_table/utils/show_info_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class SettingsPage extends StatefulWidget {
  final String currCourseTableName;
  final void Function(bool useLightMode) handleBrightnessChange;
  final Future<void> Function(String courseTableName) handleChangeCurrCourseTable;
  final Future<void> Function(String courseTableName) handleDeleteCurrCourseTable;
  final SharedPreferences prefs;
  final Database database;

  const SettingsPage({
    super.key,
    required this.currCourseTableName,
    required this.handleBrightnessChange,
    required this.handleChangeCurrCourseTable,
    required this.handleDeleteCurrCourseTable,
    required this.prefs,
    required this.database,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // TODO: Add API selector support.
  // TODO: Add CourseTable management function.
  @override
  Widget build(BuildContext context) {
    final isBright = Theme.of(context).brightness == Brightness.light;

    return Expanded(
      child: Card(
        child: ListView(
          children: [
            ListTile(
              leading: isBright
                  ? const Icon(Icons.light_mode)
                  : const Icon(Icons.dark_mode),
              title: const Text("更改显示模式"),
              trailing: Switch(
                value: isBright,
                onChanged: (value) {
                  widget.handleBrightnessChange(value);
                }
              ),
              onTap: () {
                widget.handleBrightnessChange(!isBright);
              },
            ),
            ListTile(
              leading: const Icon(Icons.save),
              title: const Text("导出课表"),
              onTap: () async {
                final names = await getCourseTableNames(widget.database);
                if (names.isEmpty) {
                  if (!mounted) return;
                  showInfoDialog(context, "Oops", "没有找到导出的课表");
                  return;
                }
                if (!mounted) return;
                Navigator.push(context, DialogRoute(context: context, builder:
                  (context) => ExportCourseTableToXlsxDialog(
                    database: widget.database,
                    names: names,
                    currCourseTableName: widget.currCourseTableName,
                )));
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text("切换当前课表"),
              onTap: () async {
                final names = await getCourseTableNames(widget.database);
                if (names.isEmpty) {
                  if (!mounted) return;
                  showInfoDialog(context, "Oops", "没有找到导入的课表");
                  return;
                }
                if (!mounted) return;
                Navigator.push(context, DialogRoute(context: context, builder:
                   (context) => ChangeCurrentCourseTable(
                  currCourseTableName: widget.currCourseTableName,
                  names: names,
                  handleChangeCurrCourseTable: widget.handleChangeCurrCourseTable,
                )));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("删除课表"),
              onTap: () async {
                final names = await getCourseTableNames(widget.database);
                if (names.isEmpty) {
                  if (!mounted) return;
                  showInfoDialog(context, "Oops", "没有找到导入的课表");
                  return;
                }
                if (!mounted) return;
                Navigator.push(context, DialogRoute(context: context, builder:
                    (context) => DeleteStoredCourseTable(
                  names: names,
                  currCourseTableName: widget.currCourseTableName,
                  handleDeleteCurrCourseTable: widget.handleDeleteCurrCourseTable,
                  database: widget.database,
                )));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("关于"),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: AppInformation.appName.value,
                  applicationVersion: AppInformation.appVersion.value,
                  applicationLegalese: AppInformation.appLegalese.value,
                );
              },
            ),
          ],
        ),
      )
    );
  }
}
