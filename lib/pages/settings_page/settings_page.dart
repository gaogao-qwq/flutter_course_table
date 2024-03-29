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
import 'package:flutter_course_table/componets/dialog/crawler_api_selector_dialog.dart';
import 'package:flutter_course_table/componets/dialog/export_course_table_to_xlsx_dialog.dart';
import 'package:flutter_course_table/componets/dialog/info_dialog.dart';
import 'package:flutter_course_table/componets/dialog/select_color_seed_dialog.dart';
import 'package:flutter_course_table/componets/dialog/update_checker_dialog.dart';
import 'package:flutter_course_table/configure_dependencies.dart';
import 'package:flutter_course_table/pages/data.dart';
import 'package:flutter_course_table/pages/settings_page/developer_page.dart';
import 'package:flutter_course_table/pages/settings_page/manage_course_table_widget.dart';
import 'package:github/github.dart';
import 'package:provider/provider.dart';
import 'package:pub_semver/pub_semver.dart';

final github = getIt<GitHub>();

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
    final appInfoData = context.watch<AppInfoData>();
    final appSettingData = context.watch<AppSettingData>();
    final courseTableNames =
        context.select((CourseTableData data) => data.courseTableNames);

    return Expanded(
        child: Card(
      child: ListView(
        children: [
          ListTile(
            leading: appSettingData.isLightMode
                ? const Icon(
                    Icons.light_mode,
                    color: Colors.amber,
                  )
                : const Icon(
                    Icons.dark_mode,
                    color: Colors.indigo,
                  ),
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
            leading: Icon(Icons.palette, color: appSettingData.colorSeed.color),
            title: const Text("更改主题颜色"),
            subtitle: Text(appSettingData.colorSeed.label),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) => const SelectColorSeedDialog());
            },
          ),
          const Divider(),
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
            leading: const Icon(Icons.update),
            title: const Text("检查更新"),
            onTap: () async {
              Release latestRelease;
              try {
                latestRelease = await github.repositories
                    .listReleases(
                        RepositorySlug("gaogao-qwq", "flutter_course_table"))
                    .first;
              } catch (e) {
                if (!mounted) return;
                showInfoDialog(context, "Oops", "$e");
                return;
              }
              if (!mounted) return;
              Version latestVersion =
                  Version.parse(latestRelease.tagName ?? "0.0.0");
              Version currentVersion = Version.parse(appInfoData.version);
              if (currentVersion >= latestVersion) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("当前版本已经是最新版本")));
                return;
              }

              Navigator.push(
                  context,
                  DialogRoute(
                      context: context,
                      builder: (context) =>
                          UpdateCheckerDialog(latestRelease: latestRelease)));
            },
          ),
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
                applicationName: appInfoData.appName,
                applicationVersion:
                    "${appInfoData.version} (${appInfoData.buildNumber})",
                applicationLegalese: appInfoData.legalese,
              );
            },
          ),
        ],
      ),
    ));
  }
}
