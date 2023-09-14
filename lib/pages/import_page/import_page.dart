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
import 'package:flutter_course_table/pages/data.dart';
import 'package:flutter_course_table/pages/import_page/import_from_crawler.dart';
import 'package:flutter_course_table/pages/import_page/import_from_editor.dart';
import 'package:provider/provider.dart';

class ImportTablePage extends StatefulWidget {
  const ImportTablePage({super.key});

  @override
  State<ImportTablePage> createState() => _ImportTablePageState();
}

class _ImportTablePageState extends State<ImportTablePage> {
  @override
  Widget build(BuildContext context) {
    final appSettingData = context.watch<AppSettingData>();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  if (appSettingData.crawlerApiUrl.isEmpty) {
                    showDialog(
                        context: context,
                        builder: (context) => const CrawlerApiSelectorDialog(
                            title: "请先设置爬虫服务地址"));
                  } else {
                    Navigator.push(
                        context,
                        FadePageRoute(
                            builder: (context) => const ImportFromCrawler()));
                  }
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 50),
                    backgroundColor: colorScheme.onSecondary),
                child: const Text("从爬虫服务器导入")),
            const Padding(padding: EdgeInsets.all(8)),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      FadePageRoute(
                          builder: (context) => const ImportFromEditor()));
                },
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 50),
                    backgroundColor: colorScheme.onSecondary),
                child: const Text("手动创建课表")),
          ],
        ),
      ),
    );
  }
}
