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
import 'package:flutter_course_table/animations/fade_page_route.dart';
import 'package:flutter_course_table/constants.dart';
import 'package:flutter_course_table/internal/database/course_table_repository.dart';
import 'package:flutter_course_table/pages/settings_page/change_current_course_table_dialog.dart';
import 'package:flutter_course_table/pages/settings_page/delete_stored_course_table_dialog.dart';
import 'package:flutter_course_table/pages/settings_page/export_course_table_to_xlsx_dialog.dart';
import 'package:flutter_course_table/pages/settings_page/manage_course_table_widget.dart';
import 'package:flutter_course_table/utils/show_info_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final String currCourseTableName;
  final void Function(bool useLightMode) handleBrightnessChange;
  final Future<void> Function(String courseTableName)
      handleCurrCourseTableChange;
  final Future<void> Function(String courseTableName) handleCourseTableDelete;
  final SharedPreferences prefs;
  final CourseTableRepository courseTableRepository;

  const SettingsPage(
      {super.key,
      required this.currCourseTableName,
      required this.handleBrightnessChange,
      required this.handleCurrCourseTableChange,
      required this.handleCourseTableDelete,
      required this.prefs,
      required this.courseTableRepository});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
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
                }),
            onTap: () {
              widget.handleBrightnessChange(!isBright);
            },
          ),
          ListTile(
            leading: const Icon(Icons.manage_search),
            title: const Text("管理课表"),
            onTap: () async {
              final names =
                  await widget.courseTableRepository.getCourseTableNames();
              if (names.isEmpty) {
                if (!mounted) return;
                showInfoDialog(context, "Oops", "没有找到导入的课表");
                return;
              }
              if (!mounted) return;
              Navigator.push(
                  context,
                  FadePageRoute(
                      builder: (context) => ManageCourseTableWidget(
                            currCourseTableName: widget.currCourseTableName,
                            handleCurrCourseTableChanged:
                                widget.handleCurrCourseTableChange,
                            handleCourseTableDeleted:
                                widget.handleCourseTableDelete,
                            courseTableRepository: widget.courseTableRepository,
                            courseTableNames: names,
                          )));
            },
          ),
          ListTile(
            leading: const Icon(Icons.save),
            title: const Text("导出课表"),
            onTap: () async {
              final names =
                  await widget.courseTableRepository.getCourseTableNames();
              if (names.isEmpty) {
                if (!mounted) return;
                showInfoDialog(context, "Oops", "没有找到可导出的课表");
                return;
              }
              if (!mounted) return;
              Navigator.push(
                  context,
                  DialogRoute(
                      context: context,
                      builder: (context) => ExportCourseTableToXlsxDialog(
                          names: names,
                          currCourseTableName: widget.currCourseTableName,
                          courseTableRepository:
                              widget.courseTableRepository)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.table_chart),
            title: const Text("切换当前课表"),
            onTap: () async {
              final names =
                  await widget.courseTableRepository.getCourseTableNames();
              if (names.isEmpty) {
                if (!mounted) return;
                showInfoDialog(context, "Oops", "没有找到导入的课表");
                return;
              }
              if (!mounted) return;
              Navigator.push(
                  context,
                  DialogRoute(
                      context: context,
                      builder: (context) => ChangeCurrentCourseTable(
                            currCourseTableName: widget.currCourseTableName,
                            names: names,
                            handleCurrCourseTableChange:
                                widget.handleCurrCourseTableChange,
                          )));
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text("删除课表"),
            onTap: () async {
              final names =
                  await widget.courseTableRepository.getCourseTableNames();
              if (names.isEmpty) {
                if (!mounted) return;
                showInfoDialog(context, "Oops", "没有找到导入的课表");
                return;
              }
              if (!mounted) return;
              Navigator.push(
                  context,
                  DialogRoute(
                      context: context,
                      builder: (context) => DeleteStoredCourseTable(
                            names: names,
                            currCourseTableName: widget.currCourseTableName,
                            handleCourseTableDelete:
                                widget.handleCourseTableDelete,
                            courseTableRepository: widget.courseTableRepository,
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
    ));
  }
}
