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
import 'package:flutter_course_table/pages/data.dart';
import 'package:provider/provider.dart';

class NameTableDialog extends StatefulWidget {
  final String initName;

  const NameTableDialog({super.key, required this.initName});

  @override
  State<NameTableDialog> createState() => _NameTableDialogState();
}

class _NameTableDialogState extends State<NameTableDialog>
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
    String name = widget.initName;
    bool isNameUsed = false;

    return FadeTransition(
        opacity: FadeAnimation(_controller),
        child: SimpleDialog(
          title: const Text("为课表命名"),
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(10),
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
                        isNameUsed = context
                                .read<CourseTableData>()
                                .courseTableNames
                                .contains(name)
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
                    const Padding(padding: EdgeInsets.all(10)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Padding(padding: EdgeInsets.all(10)),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context, null);
                          },
                          child: const Text("取消"),
                        ),
                        const Padding(padding: EdgeInsets.all(10)),
                        ElevatedButton(
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) return;
                            Navigator.pop(context, name);
                          },
                          child: const Text("保存"),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
