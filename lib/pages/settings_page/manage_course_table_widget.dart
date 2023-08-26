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

class ManageCourseTableWidget extends StatefulWidget {
  final String currCourseTableName;
  final Future<void> Function(String courseTableName)
      handleCurrCourseTableChanged;
  final Future<void> Function(String courseTableName) handleCourseTableDeleted;
  final CourseTableRepository courseTableRepository;
  final List<String> courseTableNames;

  const ManageCourseTableWidget(
      {super.key,
      required this.currCourseTableName,
      required this.handleCurrCourseTableChanged,
      required this.handleCourseTableDeleted,
      required this.courseTableRepository,
      required this.courseTableNames});

  @override
  State<ManageCourseTableWidget> createState() =>
      _ManageCourseTableWidgetState();
}

class _ManageCourseTableWidgetState extends State<ManageCourseTableWidget> {
  bool isSelectionMode = false;
  bool isSelectAll = false;
  late List<bool> _selected;

  void initializeSelection() {
    _selected =
        List<bool>.generate(widget.courseTableNames.length, (_) => false);
  }

  @override
  void initState() {
    super.initState();
    initializeSelection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            leading: isSelectionMode
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        isSelectionMode = false;
                      });
                      initializeSelection();
                    },
                    icon: const Icon(Icons.close))
                : null,
            title: const Text("管理课表"),
            actions: [
              if (isSelectionMode)
                TextButton(
                    onPressed: () {
                      isSelectAll = !isSelectAll;
                      setState(() {
                        _selected =
                            List.generate(_selected.length, (_) => isSelectAll);
                      });
                    },
                    child: !isSelectAll ? const Text("全选") : const Text("全不选"))
              else
                IconButton(
                  onPressed: () {
                    setState(() {
                      isSelectionMode = true;
                    });
                  },
                  icon: const Icon(Icons.list_alt_rounded),
                )
            ]),
        body: CourseTableListBuilder(
          courseTableNames: widget.courseTableNames,
          selectedList: _selected,
          isSelectionMode: isSelectionMode,
          onSelectionChange: (bool x) {
            setState(() {
              isSelectionMode = x;
            });
          },
          handleCurrCourseTableChanged: widget.handleCurrCourseTableChanged,
          handleCourseTableDeleted: widget.handleCourseTableDeleted,
          courseTableRepository: widget.courseTableRepository,
        ));
  }
}

class CourseTableListBuilder extends StatefulWidget {
  final bool isSelectionMode;
  final List<String> courseTableNames;
  final List<bool> selectedList;
  final void Function(bool) onSelectionChange;
  final Future<void> Function(String courseTableName)
      handleCurrCourseTableChanged;
  final Future<void> Function(String courseTableName) handleCourseTableDeleted;
  final CourseTableRepository courseTableRepository;

  const CourseTableListBuilder(
      {super.key,
      required this.courseTableNames,
      required this.selectedList,
      required this.isSelectionMode,
      required this.onSelectionChange,
      required this.handleCurrCourseTableChanged,
      required this.handleCourseTableDeleted,
      required this.courseTableRepository});

  @override
  State<CourseTableListBuilder> createState() => _CourseTableListBuilderState();
}

class _CourseTableListBuilderState extends State<CourseTableListBuilder> {
  void _toggle(int index) {
    if (widget.isSelectionMode) {
      setState(() {
        widget.selectedList[index] = !widget.selectedList[index];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.selectedList.length,
        itemBuilder: (_, int index) {
          return Card(
              child: ListTile(
                  title: Text(widget.courseTableNames[index]),
                  trailing: widget.isSelectionMode
                      ? Checkbox(
                          value: widget.selectedList[index],
                          onChanged: (bool? x) => _toggle(index),
                        )
                      : PopupMenuButton(
                          itemBuilder: (BuildContext context) => [
                                PopupMenuItem(
                                  child: const Text("设为目前课程表"),
                                  onTap: () async {
                                    await widget.handleCurrCourseTableChanged(
                                        widget.courseTableNames[index]);
                                  },
                                ),
                                PopupMenuItem(
                                  child: const Text("删除该课程表"),
                                  onTap: () async {
                                    await widget.handleCourseTableDeleted(
                                        widget.courseTableNames[index]);
                                    setState(() {
                                      widget.courseTableNames.removeAt(index);
                                    });
                                  },
                                )
                              ]),
                  onTap: () => _toggle(index),
                  onLongPress: () {
                    if (!widget.isSelectionMode) {
                      setState(() {
                        widget.selectedList[index] = true;
                      });
                      widget.onSelectionChange(true);
                    }
                  }));
        });
  }
}
