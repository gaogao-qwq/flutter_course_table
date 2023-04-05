import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_course_table_demo/internal/handlers/response_handlers.dart';
import 'package:spannable_grid/spannable_grid.dart';

class CourseTableWidget extends StatefulWidget {
  final String courseTableName;
  final int courseTableRow;
  final SharedPreferences prefs;

  const CourseTableWidget({
    super.key,
    required this.courseTableName,
    required this.courseTableRow,
    required this.prefs,
  });

  @override
  State<CourseTableWidget> createState() => _CourseTableWidgetState();
}

class _CourseTableWidgetState extends State<CourseTableWidget> {
  PageController pageController = PageController();
  late int tableRow;
  late String tableName;

  @override
  void initState() {
    super.initState();
    tableRow = widget.courseTableRow;
    tableName = widget.courseTableName;
  }

  @override
  Widget build(BuildContext context) {
    return _buildPageView();
  }

  Widget _buildPageView() {
    return PageView(
      scrollDirection: Axis.horizontal,
      controller: pageController,
      children: _buildTableList(),
    );
  }

  List<Widget> _buildTableList() {
    var json = jsonDecode(widget.prefs.getString(tableName)!);
    final List<dynamic> dataJson = json['data'];
    List<List<CourseInfo>> courseTableData = [[]];
    for (int i = 0; i < dataJson.length; i++) {
      for (int j = 0; j < dataJson[i].length; j++) {
        var tmp = CourseInfo.fromJson(dataJson[i][j]);
        courseTableData[i].add(tmp);
      }
      if (i != dataJson.length-1) courseTableData.add(<CourseInfo>[]);
    }
    int listLen = json['week'];
    int row = json['row'];
    int col = json['col'];

    List<List<List<CourseInfo>>> courseTableList = List<List<List<CourseInfo>>>.generate(listLen, (_) => <List<CourseInfo>>[]);
    for (int i = 0; i < courseTableData.length; i++) {
        courseTableList[courseTableData[i][0].weekNum - 1].add(courseTableData[i]);
    }

    List<Container> tableList = [];
    for (int i = 0; i < listLen; i++) {
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
            child: Container(
              // padding: const EdgeInsets.all(2),
              child: Card(
                child: Center(
                    child: Text(text,
                      style: const TextStyle(fontSize: 8, fontWeight: FontWeight.normal),
                    )
                ),
              ),
            )
        ));
      }
      tableList.add(
        Container(
          padding: const EdgeInsets.all(2),
          child: SpannableGrid(
            cells: gridCells,
            rows: row,
            columns: col,
          ),
        )
      );
    }
    return tableList;
  }
}
