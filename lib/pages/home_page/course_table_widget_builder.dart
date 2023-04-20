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
import 'package:flutter_course_table_demo/internal/types/course_table.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_course_table_demo/internal/types/course_info.dart';
import 'package:spannable_grid/spannable_grid.dart';

class CourseTableWidget extends StatefulWidget {
  final SharedPreferences prefs;
  final int currPage;
  final CourseTable courseTable;

  const CourseTableWidget({
    super.key,
    required this.currPage,
    required this.courseTable,
    required this.prefs,
  });

  @override
  State<CourseTableWidget> createState() => _CourseTableWidgetState();
}

class _CourseTableWidgetState extends State<CourseTableWidget> {
  late int courseTableRow;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    courseTableRow = widget.courseTable.row ?? 0;
    pageController = PageController(initialPage: widget.currPage, keepPage: false);
  }

  @override
  void didUpdateWidget(covariant CourseTableWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.courseTable != oldWidget.courseTable) {
      courseTableRow = widget.courseTable.row ?? 0;
      pageController = PageController(initialPage: widget.currPage, keepPage: false);
    }
    WidgetsBinding.instance
        .addPostFrameCallback((_) => animateToTargetPage(widget.currPage));
  }

  @override
  Widget build(BuildContext context) {
    return _buildPageView();
  }

  Widget _buildPageView() {
    Widget pageView = Expanded(
      child: Card(
        child: PageView(
          scrollDirection: Axis.horizontal,
          controller: pageController,
          children: _buildTableList(),
        ),
      ),
    );
    return pageView;
  }

  List<Widget> _buildTableList() {
    final isBright = Theme.of(context).brightness == Brightness.light;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    int weekNums = widget.courseTable.week ?? 0;
    int row = widget.courseTable.row ?? 0;
    int col = widget.courseTable.col ?? 0;
    List<List<CourseInfo>> courseTableData = widget.courseTable.data;

    List<List<List<CourseInfo>>> courseTableList = List<List<List<CourseInfo>>>
        .generate(weekNums, (_) => <List<CourseInfo>>[]);
    for (int i = 0; i < courseTableData.length; i++) {
        courseTableList[courseTableData[i][0].weekNum - 1].add(courseTableData[i]);
    }

    List<Container> tableList = [];
    for (int i = 0; i < weekNums; i++) {
      List<SpannableGridCellData> gridCells = [];
      for (int j = 0; j < courseTableList[i].length; j++) {
        String id = "id";
        String text = "";
        int row = courseTableList[i][j][0].sectionBegin;
        int column = courseTableList[i][j][0].dateNum;
        int rowSpan = courseTableList[i][j][0].sectionLength;
        for (int k = 0; k < courseTableList[i][j].length; k++) {
          id += "_${i}_${courseTableList[i][j][k].dateNum}_${courseTableList[i][j][k].sectionBegin}";
          text += "${courseTableList[i][j][k].courseName}, ${courseTableList[i][j][k].locationName}";
        }
        gridCells.add(SpannableGridCellData(
            id: id,
            row: row,
            column: column,
            rowSpan: rowSpan,
            child: Card(
              color: isBright ? colorScheme.primary.withOpacity(0.5) : colorScheme.primary.withOpacity(0.35),
              child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(2),
                      child: Text(text,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                    )
                  ),
              ),
            )
        ));
      }

      tableList.add(
        Container(
          padding: const EdgeInsets.all(2),
          child: ListView(
            controller: ScrollController(),
            children: [
              Column(
                children: [
                  SpannableGrid(
                    cells: gridCells,
                    rows: row,
                    columns: col,
                  )
                ],
              ),
            ],
          ),
        )
      );
    }
    return tableList;
  }

  void animateToTargetPage(int targetPage) {
    pageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut);
  }
}
