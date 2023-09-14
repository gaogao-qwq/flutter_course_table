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
import 'package:flutter_course_table/animations/fade_animation.dart';
import 'package:flutter_course_table/componets/dialog/crawler_api_selector_dialog.dart';
import 'package:flutter_course_table/internal/handlers/response_handlers.dart';
import 'package:flutter_course_table/internal/utils/course_table_json_handlers.dart';
import 'package:flutter_course_table/pages/data.dart';
import 'package:provider/provider.dart';

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({super.key});

  @override
  State<DeveloperPage> createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> {
  @override
  Widget build(BuildContext context) {
    final appSettingsData = context.watch<AppSettingData>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("开发者选项"),
      ),
      body: Card(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text("导入测试课表"),
              onTap: () async {
                if (appSettingsData.crawlerApiUrl.isEmpty) {
                  showDialog(
                      context: context,
                      builder: (context) =>
                          const CrawlerApiSelectorDialog(title: "请先设置爬虫服务地址"));
                  return;
                }
                showDialog(
                    context: context,
                    builder: (context) =>
                        const ImportTestTableDialog(initName: "Debug"));
              },
            )
          ],
        ),
      ),
    );
  }
}

class ImportTestTableDialog extends StatefulWidget {
  final String initName;

  const ImportTestTableDialog({super.key, required this.initName});

  @override
  State<ImportTestTableDialog> createState() => _ImportTestTableDialogState();
}

class _ImportTestTableDialogState extends State<ImportTestTableDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 200),
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_controller.status != AnimationStatus.forward) {
      _controller.forward();
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.reverse();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseTableData = context.watch<CourseTableData>();
    final appSettingData = context.watch<AppSettingData>();
    String name = widget.initName;
    bool isNameUsed =
        courseTableData.courseTableNames.contains(name) ? true : false;

    return FadeTransition(
        opacity: FadeAnimation(_controller),
        child: SimpleDialog(
          title: const Text("为课表命名"),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(64),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      autofocus: true,
                      initialValue: widget.initName,
                      maxLength: 50,
                      onChanged: (text) {
                        name = text;
                        isNameUsed =
                            courseTableData.courseTableNames.contains(name)
                                ? true
                                : false;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) return "课表名不能为空";
                        if (isNameUsed) return "该课表名已被占用";
                        return null;
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.note_alt_rounded),
                        border: UnderlineInputBorder(),
                        labelText: "输入课表名",
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                              padding: const EdgeInsets.all(10),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("取消"),
                              )),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (!_formKey.currentState!.validate()) return;
                                DateTime date = DateTime.now();
                                while (date.day != DateTime.monday) {
                                  date = date.add(const Duration(days: 1));
                                }
                                final courseTable = await fetchTestCourseTable(
                                    date.toIso8601String(),
                                    name,
                                    appSettingData.crawlerApiUrl);
                                final jsonString =
                                    courseTableToJson(courseTable!);
                                if (!mounted) return;
                                courseTableData.add(name, jsonString);
                                Navigator.pop(context);
                              },
                              child: const Text("保存"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
