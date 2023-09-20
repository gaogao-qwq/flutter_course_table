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
import 'package:flutter_course_table/animations/fade_animation.dart';
import 'package:flutter_course_table/internal/types/semester_info.dart';

class SelectSemesterDialog extends StatefulWidget {
  final List<SemesterInfo> semesterList;

  const SelectSemesterDialog({
    super.key,
    required this.semesterList,
  });

  @override
  State<SelectSemesterDialog> createState() => _SelectSemesterDialogState();
}

class _SelectSemesterDialogState extends State<SelectSemesterDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int selectedYearIndex;
  late String selectedSemester;
  late String selectedYear;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 200),
    );
    selectedYearIndex = widget.semesterList.length - 1;
    selectedSemester = widget.semesterList[selectedYearIndex].semesterId1;
    selectedYear = widget.semesterList[selectedYearIndex].value;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_controller.status != AnimationStatus.forward) {
      _controller.forward();
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.reverse();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
        opacity: FadeAnimation(_controller),
        child: SimpleDialog(
          title: const Text("选择学期"),
          children: [
            Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    DropdownMenu(
                      initialSelection: selectedYearIndex.toString(),
                      dropdownMenuEntries: yearEntries,
                      onSelected: (value) {
                        int? year = int.parse(value ?? "-1");
                        setState(() {
                          selectedYearIndex =
                              year == -1 ? selectedYearIndex : year;
                        });
                        selectedSemester =
                            widget.semesterList[selectedYearIndex].semesterId1;
                      },
                    ),
                    DropdownMenu(
                        initialSelection: selectedSemester,
                        dropdownMenuEntries: semesterEntries,
                        onSelected: (value) {
                          setState(() {
                            selectedSemester = value ?? "";
                          });
                        }),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, {
                          'selectedSemester': selectedSemester,
                          'selectedYear': selectedYear
                        });
                      },
                      child: const Text("Import"),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ));
  }

  List<DropdownMenuEntry<String>> get yearEntries {
    var items = <DropdownMenuEntry<String>>[];
    for (int i = 0; i < widget.semesterList.length; i++) {
      items.add(DropdownMenuEntry(
        value: i.toString(),
        label: "${widget.semesterList[i].value}学年",
      ));
    }
    return items;
  }

  List<DropdownMenuEntry<String>> get semesterEntries {
    var items = <DropdownMenuEntry<String>>[];
    if (widget.semesterList[selectedYearIndex].semesterId1.isNotEmpty) {
      items.add(DropdownMenuEntry(
          value: widget.semesterList[selectedYearIndex].semesterId1,
          label: "第1学期"));
    }
    if (widget.semesterList[selectedYearIndex].semesterId2.isNotEmpty) {
      items.add(DropdownMenuEntry(
          value: widget.semesterList[selectedYearIndex].semesterId2,
          label: "第2学期"));
    }
    return items;
  }
}
