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
import 'package:flutter_course_table_demo/constants.dart';
import 'package:flutter_course_table_demo/internal/utils/database_utils.dart';
import 'package:flutter_course_table_demo/pages/settings_page/change_current_course_table_dialog.dart';
import 'package:flutter_course_table_demo/pages/settings_page/delete_stored_course_table_dialog.dart';
import 'package:flutter_course_table_demo/utils/show_info_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

class SettingsPage extends StatefulWidget {
  final String currCourseTableName;
  final Future<void> Function(String courseTableName) handleChangeCurrCourseTable;
  final Future<void> Function(String courseTableName) handleDeleteCurrCourseTable;
  final SharedPreferences prefs;
  final Database database;

  const SettingsPage({
    super.key,
    required this.currCourseTableName,
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
  double? width;

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

  @override
  void didUpdateWidget(covariant SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      width = MediaQuery.of(context).size.width;
    });
  }

  // TODO: Add API selector support.
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text("切换当前课表"),
              onTap: () async {
                final names = await getCourseTableNames(widget.database);
                if (names.isEmpty) {
                  if (!mounted) return;
                  showInfoDialog(context, "Oops", "没有找到导入的课程表");
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
              title: const Text("删除课程表"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
              ),
              onTap: () async {
                final names = await getCourseTableNames(widget.database);
                if (names.isEmpty) {
                  if (!mounted) return;
                  showInfoDialog(context, "Oops", "没有找到导入的课程表");
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
