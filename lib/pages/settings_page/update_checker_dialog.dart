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
import 'package:flutter_course_table/pages/data.dart';
import 'package:flutter_course_table/utils/show_info_dialog.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:github/github.dart';
import 'package:provider/provider.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateCheckerDialog extends StatefulWidget {
  final Release latestRelease;
  const UpdateCheckerDialog({super.key, required this.latestRelease});

  @override
  State<UpdateCheckerDialog> createState() => _UpdateCheckerDialogState();
}

class _UpdateCheckerDialogState extends State<UpdateCheckerDialog> {
  @override
  Widget build(BuildContext context) {
    final appInfoData = context.watch<AppInfoData>();
    Version latestVersion =
        Version.parse(widget.latestRelease.tagName ?? "0.0.0");
    Version currentVersion = Version.parse(appInfoData.version);

    if (currentVersion >= latestVersion) {
      return SimpleDialog(
        title: const Text("检查更新"),
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("当前已是最新版本"),
                const Padding(padding: EdgeInsets.all(2)),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("返回"),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return SimpleDialog(
      title: const Text("检查更新"),
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("当前版本：${appInfoData.version}"),
              const Padding(padding: EdgeInsets.all(2)),
              Text("最新版本：${widget.latestRelease.tagName}"),
              const Padding(padding: EdgeInsets.all(6)),
              SizedBox(
                height: 200,
                width: 300,
                child: Markdown(
                  data: widget.latestRelease.body ?? "",
                ),
              ),
              const Padding(padding: EdgeInsets.all(6)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("返回"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (!await launchUrl(
                          Uri.parse(widget.latestRelease.htmlUrl ?? ""))) {
                        if (!mounted) return;
                        showInfoDialog(context, "Oops", "无法打开链接");
                      }
                    },
                    child: const Text("前往下载更新"),
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
