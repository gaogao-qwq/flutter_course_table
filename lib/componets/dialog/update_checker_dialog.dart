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
import 'package:flutter_course_table/componets/dialog/info_dialog.dart';
import 'package:flutter_course_table/pages/data.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:github/github.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateCheckerDialog extends StatefulWidget {
  final Release latestRelease;
  const UpdateCheckerDialog({super.key, required this.latestRelease});

  @override
  State<UpdateCheckerDialog> createState() => _UpdateCheckerDialogState();
}

class _UpdateCheckerDialogState extends State<UpdateCheckerDialog>
    with SingleTickerProviderStateMixin {
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
    final appInfoData = context.watch<AppInfoData>();

    return FadeTransition(
        opacity: FadeAnimation(_controller),
        child: SimpleDialog(
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
        ));
  }
}
