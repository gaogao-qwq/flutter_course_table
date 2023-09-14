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
import 'package:flutter_course_table/componets/dialog/course_info_dialog.dart';
import 'package:flutter_course_table/constants.dart';
import 'package:flutter_course_table/internal/types/course_info.dart';
import 'package:flutter_course_table/pages/data.dart';
import 'package:provider/provider.dart';
import 'package:spannable_grid/spannable_grid.dart';

class CourseTableWidget extends StatefulWidget {
  final PageController pageController;

  const CourseTableWidget({super.key, required this.pageController});

  @override
  State<StatefulWidget> createState() => _CourseTableWidgetState();
}

class _CourseTableWidgetState extends State<CourseTableWidget> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PageView(
        scrollDirection: Axis.horizontal,
        controller: widget.pageController,
        onPageChanged: (value) {
          context.read<CourseTableData>().setCurrWeek(value + 1);
        },
        children: _buildTableList(),
      ),
    );
  }

  List<Widget> _buildTableList() {
    final courseTable =
        context.select((CourseTableData data) => data.courseTable);
    final isBright = context.select((AppSettingData data) => data.isLightMode);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final isLargeLayout =
        MediaQuery.of(context).size.width > largeWidthBreakpoint;

    int weekNums = courseTable!.week ?? 0;
    int row = courseTable.row ?? 0;
    int col = courseTable.col ?? 0;

    DateTime dateIterator = DateTime.parse(courseTable.firstWeekDate);
    List<Widget> weekList = [
      const Text("周一"),
      const Text("周二"),
      const Text("周三"),
      const Text("周四"),
      const Text("周五"),
      const Text("周六"),
      const Text("周日")
    ];

    List<List<CourseInfo>> courseTableData = courseTable.data;
    List<List<List<CourseInfo>>> courseTableList =
        List<List<List<CourseInfo>>>.generate(
            weekNums, (_) => <List<CourseInfo>>[]);
    for (int i = 0; i < courseTableData.length; i++) {
      courseTableList[courseTableData[i][0].weekNum - 1]
          .add(courseTableData[i]);
    }

    List<Widget> courseNums =
        List.generate(courseTable.row!, (index) => Text("${index + 1}"));

    List<Container> tableList = [];
    // 遍历周数
    for (int i = 0; i < weekNums; i++) {
      List<SpannableGridCellData> courseTableGridCells = [];
      List<Widget> calendars = [];

      // 遍历每周课时列表
      for (int j = 0; j < courseTableList[i].length; j++) {
        String id = "id";
        String rawCourseInfo = "";
        String courseInfo = "";
        String location = "";
        String courseId = courseTableList[i][j][0].courseId;
        int sectionBegin = courseTableList[i][j][0].sectionBegin;
        int row = courseTableList[i][j][0].sectionBegin;
        int column = courseTableList[i][j][0].dateNum;
        int rowSpan = courseTableList[i][j][0].sectionLength;

        // 因为会出现课程冲突，所以采用了三维数组，最内层遍历同一课时内的课程
        for (int k = 0; k < courseTableList[i][j].length; k++) {
          id +=
              "_${i}_${courseTableList[i][j][k].dateNum}_${courseTableList[i][j][k].sectionBegin}";
          rawCourseInfo += courseTableList[i][j][k].courseName;
          location += courseTableList[i][j][k].locationName;
        }

        if (isLargeLayout) {
          if (rawCourseInfo.length > largeCourseInfoLength) {
            courseInfo =
                "${rawCourseInfo.substring(0, largeCourseInfoLength)}...";
          } else {
            courseInfo = rawCourseInfo.substring(0, rawCourseInfo.length);
          }
        } else {
          if (rawCourseInfo.length > courseInfoLength) {
            courseInfo = "${rawCourseInfo.substring(0, courseInfoLength)}...";
          } else {
            courseInfo = rawCourseInfo.substring(0, rawCourseInfo.length);
          }
        }

        courseTableGridCells.add(SpannableGridCellData(
          id: id,
          row: row,
          column: column,
          rowSpan: rowSpan,
          child: Hero(
              tag: "courseInfoCard_$id",
              child: GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => CourseInfoDialog(
                            heroTag: "courseInfoCard_$id",
                            rawCourseInfo: rawCourseInfo,
                            location: location,
                            courseId: courseId,
                            sectionBegin: sectionBegin,
                            rowSpan: rowSpan,
                          ));
                },
                child: Card(
                  margin: const EdgeInsets.all(1.5),
                  color: isBright
                      ? colorScheme.background.withOpacity(0.8)
                      : colorScheme.primary.withOpacity(0.35),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Flexible(
                          child: Text(courseInfo,
                              style: const TextStyle(fontSize: 10))),
                      const Divider(thickness: 2),
                      Flexible(
                          child: Text(location,
                              style: const TextStyle(fontSize: 10)))
                    ],
                  ),
                ),
              )),
        ));
      }

      // 遍历每周每天日期
      for (int weekday = 1; weekday <= 7; weekday++) {
        calendars.add(Text("${dateIterator.month}/${dateIterator.day}"));
        dateIterator = dateIterator.add(const Duration(days: 1));
      }

      List<SpannableGridCellData> topListTile = List.generate(
          7,
          (index) => SpannableGridCellData(
                id: index + 1,
                column: index + 1,
                row: 1,
                child: Container(
                  alignment: Alignment.centerRight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      weekList[index],
                      calendars[index],
                    ],
                  ),
                ),
              ));

      tableList.add(Container(
        padding: const EdgeInsets.all(2),
        child: Column(
          children: [
            ListTile(
              minVerticalPadding: 0,
              tileColor: colorScheme.primary.withOpacity(0.25),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              title: SpannableGrid(
                editingStrategy: SpannableGridEditingStrategy.disabled(),
                style: const SpannableGridStyle(spacing: 0),
                gridSize: SpannableGridSize.parentHeight,
                rows: 1,
                columns: 7,
                cells: topListTile,
              ),
            ),
            Expanded(
                child: ListView(children: [
              IntrinsicHeight(
                  child: Row(
                children: [
                  Card(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: courseNums)),
                  Expanded(
                      child: Card(
                    child: SpannableGrid(
                      rows: row,
                      columns: col,
                      style: SpannableGridStyle(
                        backgroundColor: colorScheme.primary.withOpacity(0.1),
                        spacing: 0,
                      ),
                      cells: courseTableGridCells,
                    ),
                  ))
                ],
              )),
            ])),
          ],
        ),
      ));
    }
    return tableList;
  }
}
