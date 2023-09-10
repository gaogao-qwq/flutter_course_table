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
import 'package:provider/provider.dart';

class ManageCourseTableWidget extends StatefulWidget {
  const ManageCourseTableWidget({super.key});

  @override
  State<ManageCourseTableWidget> createState() =>
      _ManageCourseTableWidgetState();
}

class _ManageCourseTableWidgetState extends State<ManageCourseTableWidget> {
  @override
  Widget build(BuildContext context) {
    final isSelectionMode =
        context.select((CourseTableSelectorData data) => data.isSelectionMode);
    final isSelectAll =
        context.select((CourseTableSelectorData data) => data.isSelectAll);

    return Scaffold(
        appBar: AppBar(
            leading: isSelectionMode
                ? IconButton(
                    onPressed: () {
                      context
                          .read<CourseTableSelectorData>()
                          .setSelectionMode(false);
                    },
                    icon: const Icon(Icons.close))
                : null,
            title: const Text("管理课表"),
            actions: [
              if (isSelectionMode) ...[
                TextButton(
                    onPressed: () {
                      context
                          .read<CourseTableSelectorData>()
                          .setSelectAll(!isSelectAll);
                    },
                    child: isSelectAll ? const Text("全不选") : const Text("全选")),
                IconButton(
                    onPressed: () {
                      context
                          .read<CourseTableSelectorData>()
                          .removeSelectedItems();
                    },
                    icon: const Icon(Icons.delete_rounded))
              ] else
                IconButton(
                  onPressed: () {
                    context
                        .read<CourseTableSelectorData>()
                        .setSelectionMode(true);
                  },
                  icon: const Icon(Icons.list_alt_rounded),
                )
            ]),
        body: const CourseTableListBuilder());
  }
}

class CourseTableListBuilder extends StatefulWidget {
  const CourseTableListBuilder({super.key});

  @override
  State<CourseTableListBuilder> createState() => _CourseTableListBuilderState();
}

class _CourseTableListBuilderState extends State<CourseTableListBuilder> {
  @override
  Widget build(BuildContext context) {
    final isSelectionMode =
        context.watch<CourseTableSelectorData>().isSelectionMode;
    final selected = context.watch<CourseTableSelectorData>().selected;
    final courseTableNames = context.watch<CourseTableData>().courseTableNames;

    return ListView.builder(
        itemCount: courseTableNames.length,
        itemBuilder: (_, int index) {
          return Card(
              child: ListTile(
                  title: Text(courseTableNames[index]),
                  trailing: isSelectionMode
                      ? Checkbox(
                          value: selected[index],
                          onChanged: (_) => context
                              .read<CourseTableSelectorData>()
                              .toggle(index),
                        )
                      : PopupMenuButton(
                          itemBuilder: (BuildContext context) => [
                                PopupMenuItem(
                                  child: const Text("设为目前课程表"),
                                  onTap: () async {
                                    await context
                                        .read<CourseTableData>()
                                        .changeByName(courseTableNames[index]);
                                  },
                                ),
                                PopupMenuItem(
                                  child: const Text("删除该课程表"),
                                  onTap: () async {
                                    await context
                                        .read<CourseTableData>()
                                        .deleteByName(courseTableNames[index]);
                                  },
                                )
                              ]),
                  onTap: () =>
                      context.read<CourseTableSelectorData>().toggle(index),
                  onLongPress: () {
                    context
                        .read<CourseTableSelectorData>()
                        .setSelectionMode(true);
                    context.read<CourseTableSelectorData>().toggle(index);
                  }));
        });
  }
}
