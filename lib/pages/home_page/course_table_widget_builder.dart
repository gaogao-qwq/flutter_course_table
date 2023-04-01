import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_course_table_demo/pages/import_page/import_page.dart';
import 'package:flutter_course_table_demo/internal/handlers/response_handlers.dart';
import 'package:spannable_grid/spannable_grid.dart';

// TODO: implement course table widget

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
    final List<CourseInfo> courseTableData = json['data'].cast<Map<String, dynamic>>().map<CourseInfo>((json) => CourseInfo.fromJson(json)).toList();
    int listLen = json['week'];
    int row = json['row'];
    int col = json['col'];

    List<List<CourseInfo>> courseTableList = List<List<CourseInfo>>.generate(listLen, (_) => []);
    for (int i = 0; i < courseTableData.length; i++) {
      courseTableList[courseTableData[i].weekNum - 1].add(courseTableData[i]);
    }

    List<Container> tableList = [];
    for (int i = 0; i < listLen; i++) {
      List<SpannableGridCellData> gridCells = [];
      for (int j = 0; j < courseTableList[i].length; j++) {
        gridCells.add(SpannableGridCellData(
          id: "id_${i}_${courseTableList[i][j].sectionBegin}_${courseTableList[i][j].dateNum}",
          row: courseTableList[i][j].sectionBegin,
          column: courseTableList[i][j].dateNum,
          rowSpan: courseTableList[i][j].sectionLength,
          child: Container(
            padding: const EdgeInsets.all(2),
            child: Card(
              child: Center(
                child: Text("${courseTableList[i][j].courseName}, ${courseTableList[i][j].locationName}")
              ),
            ),
          )
        ));
      }
      tableList.add(
        Container(
          padding: const EdgeInsets.all(10),
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

  // var emptyPlaceholder = Center(
  //   child: Column(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     children: <Widget>[
  //       const Padding(
  //         padding: EdgeInsets.all(10),
  //         child: Text("There is nothing here, import a course table first"),
  //       ),
  //       ElevatedButton(
  //         onPressed: () async {
  //           final tmp = await Navigator.push(context, MaterialPageRoute(builder: (context) => ImportTablePage(prefs: widget.prefs)));
  //           setState(() { widget.courseTableName = tmp; });
  //         },
  //         child: const Text("Import"),
  //       ),
  //     ],
  //   )
  // );

  // final jsonString = widget.prefs.getString(nameKey!);
  // var json = jsonDecode(jsonString!);
  // final courseTableData = json['data'].cast<Map<String, dynamic>>().map<CourseInfo>((json) => CourseInfo.fromJson(json)).toList();
  // var table = <TableRow>[];
  // for (int r = 0; r < json['row']; r++) {
  //   var list = <TableCell>[];
  //   for (int c = 0; c < json['col']; c++) {
  //     list.add(TableCell(child: Text("row:${r+1} col:${c+1}")));
  //   }
  //   table.add(TableRow(children: list));
  // }
  // var courseTable = Table(border: TableBorder.all(), children: table);
  // return courseTable;
}
