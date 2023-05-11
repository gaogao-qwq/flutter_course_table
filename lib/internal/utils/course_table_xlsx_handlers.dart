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

import 'package:excel/excel.dart';
import 'package:flutter_course_table/internal/types/course_info.dart';
import 'package:flutter_course_table/internal/types/course_table.dart';

Future<Excel?> courseTableToXlsx(CourseTable courseTable) async {
  Excel excel = Excel.createExcel();
  final row = courseTable.row;
  final col = courseTable.col;
  final weekNums = courseTable.week;
  final String name = courseTable.name;
  final data = courseTable.data;
  Sheet sheet = excel['Sheet1'];

  if (row == null || col == null || weekNums == null) return null;

  List<List<List<CourseInfo>>> courseTableList = List<List<List<CourseInfo>>>
      .generate(weekNums, (_) => <List<CourseInfo>>[]);
  for (int i = 0; i < data.length; i++) {
    courseTableList[data[i][0].weekNum - 1].add(data[i]);
  }

  const weeksPerRow = 2;
  final columnLength = col*weeksPerRow+weeksPerRow-1;

  int rBegin(int w) { return 3+w~/weeksPerRow*(row+1); }
  int rEnd(int w) { return rBegin(w)+row; }
  int cBegin(int w) { return 1+w%weeksPerRow*(col+1); }
  int cEnd(int w) { return cBegin(w)+col; }

  final titleStyle = CellStyle(
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    fontSize: 18,
    textWrapping: TextWrapping.Clip,
    backgroundColorHex: '#54FF9F',
  ); // SeaGreen1
  final infoStyle = CellStyle(
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    fontSize: 8,
    textWrapping: TextWrapping.WrapText,
    backgroundColorHex: '#00EEEE'
  ); // Cyan2
  final conflictStyle = CellStyle(
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
    fontSize: 8,
    textWrapping: TextWrapping.WrapText,
    backgroundColorHex: '#FF3030'
  ); // Firebrick1
  final backgroundStyle = CellStyle(
    backgroundColorHex: '#BEBEBE'
  ); // Grey

  // Title cell
  sheet.merge(
    CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
    CellIndex.indexByColumnRow(columnIndex: columnLength+1, rowIndex: 1),
    customValue: name,
  );
  sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).cellStyle = titleStyle;

  for (int w = 0; w < weekNums; w++) {
    for(int r = rBegin(w); r < rEnd(w); r++) {
      for (int c = cBegin(w); c < cEnd(w); c++) {
        sheet.setColWidth(c, 20);
        var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r));
        cell.value = "";
        cell.cellStyle = backgroundStyle;
      }
    }
  }

  for (int w = 0; w < weekNums; w++) {
    for (int i = 0; i < courseTableList[w].length; i++) {
      Data cell = sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: cBegin(w)+courseTableList[w][i][0].dateNum-1,
        rowIndex: rBegin(w)+courseTableList[w][i][0].sectionBegin-1
      ));
      sheet.merge(
        CellIndex.indexByColumnRow(
          columnIndex: cBegin(w)+courseTableList[w][i][0].dateNum-1,
          rowIndex: rBegin(w)+courseTableList[w][i][0].sectionBegin-1
        ),
        CellIndex.indexByColumnRow(
          columnIndex: cBegin(w)+courseTableList[w][i][0].dateNum-1,
          rowIndex: rBegin(w)+courseTableList[w][i][0].sectionBegin+courseTableList[w][i][0].sectionLength-2
        ),
      );
      List<String> info = List.generate(courseTableList[w][i].length, (index) =>
          courseTableList[w][i][index].courseName+courseTableList[w][i][index].locationName);
      if (info.length > 1) {
        cell.value = info.join("\n");
        cell.cellStyle = conflictStyle;
        continue;
      }
      cell.value = info.join("\n");
      cell.cellStyle = infoStyle;
    }
  }

  return excel;
}
