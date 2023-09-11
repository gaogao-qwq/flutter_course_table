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

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_course_table/internal/utils/course_table_json_handlers.dart';
import 'package:flutter_course_table/internal/utils/course_table_xlsx_handlers.dart';
import 'package:flutter_course_table/pages/data.dart';
import 'package:flutter_course_table/utils/show_info_dialog.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class ExportCourseTableToXlsxDialog extends StatefulWidget {
  const ExportCourseTableToXlsxDialog({super.key});

  @override
  State<ExportCourseTableToXlsxDialog> createState() =>
      _ExportCourseTableToXlsxDialogState();
}

class _ExportCourseTableToXlsxDialogState
    extends State<ExportCourseTableToXlsxDialog> {
  @override
  Widget build(BuildContext context) {
    String selectedCourseTableName = "";
    final currCourseTableName =
        context.watch<CourseTableData>().courseTable?.name;
    final courseTableNames = context.watch<CourseTableData>().courseTableNames;
    final entries = List.generate(
        courseTableNames.length,
        (index) => DropdownMenuEntry(
            value: courseTableNames[index], label: courseTableNames[index]));

    return SimpleDialog(
      title: const Text("导出选中的课表"),
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FittedBox(
                  clipBehavior: Clip.antiAlias,
                  child: DropdownMenu(
                    label: const Text("导出课表"),
                    leadingIcon: const Icon(Icons.save),
                    initialSelection: currCourseTableName,
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text("返回"),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final courseTable = jsonToCourseTable(
                              await courseTableRepository
                                  .getCourseTableJsonByName(
                                      selectedCourseTableName));
                          if (courseTable == null) return;

                          final excel = await courseTableToXlsx(courseTable);
                          if (excel == null) return;

                          String? selectedDirectory;
                          try {
                            selectedDirectory =
                                await FilePicker.platform.getDirectoryPath(
                              dialogTitle: "选择导出路径",
                              lockParentWindow: true,
                              initialDirectory:
                                  (await getApplicationDocumentsDirectory())
                                      .path,
                            );
                          } catch (e) {
                            if (!mounted) return;
                            showInfoDialog(context, "Oops", "报错了：$e");
                            return;
                          }

                          if (selectedDirectory == null ||
                              selectedDirectory.isEmpty) {
                            if (!mounted) return;
                            showInfoDialog(context, "Oops", "文件路径为空");
                            return;
                          }

                          var fileBytes = excel.save();
                          if (fileBytes == null) {
                            if (!mounted) return;
                            showInfoDialog(context, "Oops", "导出了空表，很神秘");
                            return;
                          }

                          File(join(selectedDirectory,
                              "$selectedCourseTableName.xlsx"))
                            ..createSync(recursive: true)
                            ..writeAsBytesSync(fileBytes);

                          if (!mounted) return;
                          Navigator.pop(context);
                          showInfoDialog(context, "喜报", "导出成功");
                        },
                        child: const Text("导出"),
                      ),
                    ]),
              ]),
        )
      ],
    );
  }
}
