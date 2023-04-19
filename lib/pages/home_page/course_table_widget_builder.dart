import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_course_table_demo/internal/types/course_table.dart';
import 'package:flutter_course_table_demo/internal/utils/course_table_json_handlers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_course_table_demo/internal/types/course_info.dart';
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
  late int currPage;
  late PageController pageController;
  late String tableName;
  late CourseTable courseTable;

  @override
  void initState() {
    super.initState();
    tableName = widget.courseTableName;
    courseTable = jsonToCourseTable(widget.prefs.getString(tableName)!);
    currPage = getInitialPage();
    pageController = PageController(initialPage: currPage);
  }

  @override
  Widget build(BuildContext context) {
    return _buildPageView();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  Widget _buildPageView() {
    return Expanded(
      child: Card(
        child: PageView(
          scrollDirection: Axis.horizontal,
          controller: pageController,
          onPageChanged: (index) {
            setState(() { currPage = index + 1; });
          },
          children: _buildTableList(),
        ),
      ),
    );
  }

  List<Widget> _buildTableList() {
    final isBright = Theme.of(context).brightness == Brightness.light;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    var json = jsonDecode(widget.prefs.getString(tableName)!);
    final List<dynamic> dataJson = jsonDecode(json['data']);
    List<List<CourseInfo>> courseTableData = [[]];
    for (int i = 0; i < dataJson.length; i++) {
      for (int j = 0; j < dataJson[i].length; j++) {
        var tmp = CourseInfo.fromJson(dataJson[i][j]);
        courseTableData[i].add(tmp);
      }
      if (i != dataJson.length-1) courseTableData.add(<CourseInfo>[]);
    }
    int weekNums = json['week'];
    int row = json['row'];
    int col = json['col'];

    List<List<List<CourseInfo>>> courseTableList = List<List<List<CourseInfo>>>.generate(weekNums, (_) => <List<CourseInfo>>[]);
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

  int getInitialPage() {
    DateTime firstWeekDateTime = DateTime.parse(courseTable.firstWeekDate);
    if (DateTime.now().isBefore(firstWeekDateTime)) return 0;
    int currWeek = DateTime.now().difference(firstWeekDateTime).inDays ~/ 7;
    if (currWeek > (courseTable.week!)) {
      return courseTable.week!;
    }
    return currWeek;
  }
}
