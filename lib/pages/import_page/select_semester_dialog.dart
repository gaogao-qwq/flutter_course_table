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
import 'package:flutter_course_table/internal/types/semester_info.dart';

class SelectSemesterDialog extends StatefulWidget{
  final List<SemesterInfo> semesterList;

  const SelectSemesterDialog({
    super.key,
    required this.semesterList,
  });

  @override
  State<SelectSemesterDialog> createState() => _SelectSemesterDialogState();
}

class _SelectSemesterDialogState extends State<SelectSemesterDialog> {
  late int selectedYearIndex;
  late String selectedSemester;
  late String selectedYear;

  @override
  void initState() {
    selectedYearIndex = widget.semesterList.length - 1;
    selectedSemester = widget.semesterList[selectedYearIndex].semesterId1;
    selectedYear = widget.semesterList[selectedYearIndex].value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("选择学期"),
      children: <Widget>[
        Column(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                DropdownButton(
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  items: getYearItems(),
                  value: selectedYearIndex.toString(),
                  onChanged: (value) {
                    int? year = int.parse(value ?? "-1");
                    setState(() { selectedYearIndex = year == -1 ? selectedYearIndex : year; });
                    selectedSemester = widget.semesterList[selectedYearIndex].semesterId1;
                  },
                ),
                DropdownButton(
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  items: getSemesterItems(),
                  value: selectedSemester,
                  onChanged: (value) {
                    setState(() {
                      selectedSemester = value ?? "";
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {'selectedSemester': selectedSemester, 'selectedYear': selectedYear});
                  },
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll<Color>(Colors.green),
                  ),
                  child: const Text("Import"),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> getYearItems() {
    var items = <DropdownMenuItem<String>>[];
    for (int i = 0; i < widget.semesterList.length; i++) {
      items.add(DropdownMenuItem(value: i.toString(), child: Text("${widget.semesterList[i].value}学年"),));
    }
    return items;
  }

  List<DropdownMenuItem<String>> getSemesterItems() {
    var items = <DropdownMenuItem<String>>[];
    items.add(DropdownMenuItem(value: widget.semesterList[selectedYearIndex].semesterId1, child: const Text("第1学期")));
    items.add(DropdownMenuItem(value: widget.semesterList[selectedYearIndex].semesterId2, child: const Text("第2学期")));
    return items;
  }
}