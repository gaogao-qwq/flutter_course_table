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

class CourseInfoDialog extends StatefulWidget {
  final String heroTag;
  final String rawCourseInfo;
  final String location;
  final String courseId;
  final int sectionBegin;
  final int rowSpan;

  const CourseInfoDialog(
      {super.key,
      required this.heroTag,
      required this.rawCourseInfo,
      required this.location,
      required this.courseId,
      required this.sectionBegin,
      required this.rowSpan});

  @override
  State<CourseInfoDialog> createState() => _CourseInfoDialogState();
}

class _CourseInfoDialogState extends State<CourseInfoDialog> {
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      children: [
        Container(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  defaultColumnWidth: const IntrinsicColumnWidth(),
                  children: [
                    TableRow(children: [
                      const Text("课程编号：", textAlign: TextAlign.right),
                      Text(widget.courseId)
                    ]),
                    TableRow(children: [
                      const Text("课程名称：", textAlign: TextAlign.right),
                      Text(widget.rawCourseInfo)
                    ]),
                    TableRow(children: [
                      const Text("上课教室：", textAlign: TextAlign.right),
                      Text(widget.location)
                    ]),
                    TableRow(children: [
                      const Text("课程节数：", textAlign: TextAlign.right),
                      Text(
                          "${widget.sectionBegin}-${widget.sectionBegin + widget.rowSpan - 1}")
                    ]),
                  ],
                )))
      ],
    );
  }
}
