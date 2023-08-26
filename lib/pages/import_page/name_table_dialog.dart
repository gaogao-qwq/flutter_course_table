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
import 'package:flutter_course_table/internal/database/course_table_repository.dart';

class NameTableDialog extends StatefulWidget {
  final String initName;
  final CourseTableRepository courseTableRepository;

  const NameTableDialog({
    super.key,
    required this.initName,
    required this.courseTableRepository,
  });

  @override
  State<NameTableDialog> createState() => _NameTableDialogState();
}

class _NameTableDialogState extends State<NameTableDialog> {
  final _formKey = GlobalKey<FormState>();
  String? name;
  late bool isContainedName;

  Future<void> _load() async {
    isContainedName =
        await widget.courseTableRepository.containName(name ?? "");
  }

  @override
  void initState() {
    name = widget.initName;
    _load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
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
                  onChanged: (text) async {
                    setState(() async {
                      isContainedName =
                          await widget.courseTableRepository.containName(text);
                      name = text;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) return "课表名不能为空";
                    if (isContainedName) return "该课表名已被占用";
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
                              Navigator.pop(context, null);
                            },
                            child: const Text("取消"),
                          )),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: () {
                            if (!_formKey.currentState!.validate()) return;
                            Navigator.pop(context, name);
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
    );
  }
}
