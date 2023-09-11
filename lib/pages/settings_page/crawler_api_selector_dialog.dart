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
import 'package:flutter_course_table/internal/handlers/response_handlers.dart';
import 'package:flutter_course_table/internal/types/course_table.dart';
import 'package:flutter_course_table/pages/data.dart';
import 'package:flutter_course_table/utils/show_info_dialog.dart';
import 'package:provider/provider.dart';

class CrawlerApiSelectorDialog extends StatefulWidget {
  final String title;

  const CrawlerApiSelectorDialog({super.key, required this.title});

  @override
  State<CrawlerApiSelectorDialog> createState() =>
      _CrawlerApiSelectorDialogState();
}

class _CrawlerApiSelectorDialogState extends State<CrawlerApiSelectorDialog> {
  final _formKey = GlobalKey<FormState>();
  String url = "";
  FocusNode? blankNode = FocusNode();
  FocusNode? urlNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final appSettingData = context.watch<AppSettingData>();

    return SimpleDialog(
      title: Text(widget.title),
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Form(
                  child: TextFormField(
                key: _formKey,
                focusNode: urlNode,
                initialValue: appSettingData.crawlerApiUrl,
                decoration: const InputDecoration(
                  labelText: "爬虫服务地址",
                  hintText: "http://",
                ),
                maxLength: 100,
                onChanged: (value) {
                  setState(() {
                    url = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "请输入爬虫服务地址";
                  }
                  return null;
                },
              )),
              const Padding(padding: EdgeInsets.all(8)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("取消")),
                  ElevatedButton(
                    onPressed: () async {
                      FocusScope.of(context).requestFocus(blankNode);
                      DateTime date = DateTime.now();
                      while (date.day != DateTime.monday) {
                        date = date.add(const Duration(days: 1));
                      }
                      CourseTable? courseTable;
                      try {
                        courseTable = await fetchTestCourseTable(
                            date.toIso8601String(),
                            date.toIso8601String(),
                            url);
                      } catch (e) {
                        if (!mounted) return;
                        showInfoDialog(context, "爬虫服务地址错误或不可用", "$e");
                        return;
                      }
                      if (!mounted) return;
                      if (courseTable == null) {
                        showInfoDialog(
                            context, "爬虫服务端返回了空的验证课表", "请联系爬虫服务器维护者");
                        return;
                      }
                      appSettingData.setCrawlerApiUrl(url);
                      Navigator.pop(context);
                    },
                    child: const Text("确定"),
                  ),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
