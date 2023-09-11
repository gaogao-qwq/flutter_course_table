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
import 'package:flutter_course_table/pages/data.dart';
import 'package:flutter_course_table/pages/settings_page/crawler_api_selector_dialog.dart';
import 'package:flutter_course_table/pages/settings_page/developer_page.dart';
import 'package:flutter_course_table/pages/settings_page/export_course_table_to_xlsx_dialog.dart';
import 'package:flutter_course_table/pages/settings_page/manage_course_table_widget.dart';
import 'package:flutter_course_table/utils/show_info_dialog.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    final appSettingData = context.watch<AppSettingData>();
    final courseTableNames =
        context.select((CourseTableData data) => data.courseTableNames);

    return Expanded(
        child: Card(
      child: ListView(
        children: [
          ListTile(
            leading: appSettingData.isLightMode
                ? const Icon(Icons.light_mode)
                : const Icon(Icons.dark_mode),
            title: const Text("更改显示模式"),
            trailing: Switch(
                value: appSettingData.isLightMode,
                onChanged: (value) {
                  context.read<AppSettingData>().useLightMode(value);
                }),
            onTap: () {
              context
                  .read<AppSettingData>()
                  .useLightMode(!appSettingData.isLightMode);
            },
          ),
          ListTile(
            leading: const Icon(Icons.api_rounded),
            title: const Text("设置爬虫服务地址"),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) =>
                      const CrawlerApiSelectorDialog(title: "设置爬虫服务地址"));
            },
          ),
          ListTile(
            leading: const Icon(Icons.manage_search),
            title: const Text("管理课表"),
            onTap: () {
              if (courseTableNames.isEmpty) {
                if (!mounted) return;
                showInfoDialog(context, "Oops", "没有找到导入的课表");
                return;
              }
              if (!mounted) return;
              Navigator.push(
                  context,
                  FadePageRoute(
                      builder: (context) => Provider(
                          create: (BuildContext context) {
                            final courseTableNames = context
                                .read<CourseTableData>()
                                .courseTableNames;
                            return CourseTableSelectorData(courseTableNames);
                          },
                          child: ChangeNotifierProvider(
                              create: (context) =>
                                  CourseTableSelectorData(courseTableNames),
                              child: const ManageCourseTableWidget()))));
            },
          ),
          ListTile(
            leading: const Icon(Icons.save),
            title: const Text("导出课表"),
            onTap: () async {
              if (courseTableNames.isEmpty) {
                if (!mounted) return;
                showInfoDialog(context, "Oops", "没有找到可导出的课表");
                return;
              }
              if (!mounted) return;
              Navigator.push(
                  context,
                  DialogRoute(
                      context: context,
                      builder: (context) =>
                          const ExportCourseTableToXlsxDialog()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.developer_mode_rounded),
            title: const Text("开发者选项"),
            onTap: () {
              Navigator.push(context,
                  FadePageRoute(builder: (context) => const DeveloperPage()));
            },
          ),
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
