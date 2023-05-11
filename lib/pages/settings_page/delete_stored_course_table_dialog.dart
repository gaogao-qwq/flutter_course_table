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
import 'package:sqflite/sqflite.dart';

class DeleteStoredCourseTable extends StatefulWidget {
  final String currCourseTableName;
  final List<String> names;
  final Future<void> Function(String courseTableName) handleDeleteCurrCourseTable;
  final Database database;

  const DeleteStoredCourseTable({
    super.key,
    required this.names,
    required this.currCourseTableName,
    required this.handleDeleteCurrCourseTable,
    required this.database,
  });

  @override
  State<DeleteStoredCourseTable> createState() => _DeleteStoredCourseTableState();
}

class _DeleteStoredCourseTableState extends State<DeleteStoredCourseTable> {
  String selectedCourseTableName = "";
  List<DropdownMenuEntry<String>> entries = [];

  @override
  void initState() {
    super.initState();
    selectedCourseTableName = widget.currCourseTableName;
    entries = List.generate(widget.names.length, (index) =>
        DropdownMenuEntry(value: widget.names[index], label: widget.names[index]));
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("删除选择的课表"),
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FittedBox(
                child: DropdownMenu(
                  label: const Text("删除课表"),
                  leadingIcon: const Icon(Icons.delete),
                  initialSelection: widget.currCourseTableName,
                  dropdownMenuEntries: entries,
                  onSelected: (value) {
                    selectedCourseTableName = value ?? "";
                  },
                ),
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  ElevatedButton(
                    onPressed: () { Navigator.pop(context); },
                    child: const Text("返回"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (selectedCourseTableName.isEmpty) return;
                      await widget.handleDeleteCurrCourseTable(selectedCourseTableName);
                      if (!mounted) return;
                      Navigator.pop(context);
                    },
                    child: const Text("删除"),
                  ),
              ]),
          ]),
        )
      ],
    );
  }
}


