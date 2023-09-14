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

class FirstWeekDateSelector extends StatefulWidget {
  final String selectedYear;

  const FirstWeekDateSelector({
    super.key,
    required this.selectedYear,
  });

  @override
  State<FirstWeekDateSelector> createState() => _FirstWeekDateSelectorState();
}

class _FirstWeekDateSelectorState extends State<FirstWeekDateSelector>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int currYear;
  late DateTime currWeek;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 200),
    );
    final yearString =
        widget.selectedYear.substring(0, widget.selectedYear.indexOf('-'));
    currYear = int.parse(yearString);
    currWeek = DateTime(currYear, DateTime.august, 1);
    while (currWeek.weekday != DateTime.monday) {
      currWeek = currWeek.add(const Duration(days: 1));
    }
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
          title: const Text('选择学期第一周日期'),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: DropdownButton(
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                value: currYear,
                items: getYearItems(),
                onChanged: (value) {
                  setState(() {
                    currYear = value ?? currYear;
                    currWeek = DateTime(currYear, DateTime.august, 1);
                    while (currWeek.weekday != DateTime.monday) {
                      currWeek = currWeek.add(const Duration(days: 1));
                    }
                  });
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: DropdownButton(
                icon: const Icon(Icons.arrow_downward),
                elevation: 16,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                value: currWeek,
                items: getWeekItems(currYear),
                onChanged: (value) {
                  setState(() {
                    currWeek = value ?? currWeek;
                  });
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Back"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, currWeek.toIso8601String());
                      },
                      child: const Text("Select"),
                    ),
                  ]),
            ),
          ],
        ));
  }

  List<DropdownMenuItem<int>> getYearItems() {
    List<DropdownMenuItem<int>> items = [];
    for (int i = 2000; i < 2101; i++) {
      items.add(DropdownMenuItem(
        value: i,
        child: Text("${i.toString()}-${(i + 1).toString()}学年"),
      ));
    }
    return items;
  }

  List<DropdownMenuItem<DateTime>> getWeekItems(int year) {
    List<DropdownMenuItem<DateTime>> items = [];
    List<DateTime> weekList = getWeekList(year);
    for (DateTime d in weekList) {
      DateTime dEnd = d.add(const Duration(days: 6));
      items.add(DropdownMenuItem(
        value: d,
        child: Text(
            "${d.year}.${d.month}.${d.day}-${dEnd.year}.${dEnd.month}.${dEnd.day}"),
      ));
    }
    return items;
  }

  List<DateTime> getWeekList(int year) {
    DateTime start = DateTime(year, DateTime.august, 1),
        end = DateTime(year + 1, DateTime.july, 31);
    final days = end.difference(start).inDays;
    List<DateTime> weeks = [];
    for (int i = 0; i < days; i++, start = start.add(const Duration(days: 1))) {
      if (start.weekday == DateTime.monday) {
        weeks.add(DateTime(start.year, start.month, start.day));
      }
    }
    return weeks;
  }
}
