import 'package:flutter/material.dart';

class FirstWeekDateSelector extends StatefulWidget {
  const FirstWeekDateSelector({Key? key}) : super(key: key);

  @override
  State<FirstWeekDateSelector> createState() => _FirstWeekDateSelectorState();
}

class _FirstWeekDateSelectorState extends State<FirstWeekDateSelector> {
  final DateTime currTime = DateTime.now();
  late int currYear;
  late DateTime currWeek;

  @override
  void initState() {
    super.initState();
    currYear = currTime.year;
    currWeek = DateTime(currYear);
    while (currWeek.weekday != DateTime.monday) {
      currWeek = currWeek.add(const Duration(days: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Select first week date'),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: DropdownButton(
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            value: currYear,
            items: getYearItems(),
            onChanged: (value) { setState(() {
              currYear = value ?? currYear;
              currWeek = DateTime(currYear);
              while (currWeek.weekday != DateTime.monday) {
                currWeek = currWeek.add(const Duration(days: 1));
              }
            }); },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          child: DropdownButton(
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            value: currWeek,
            items: getWeekItems(currYear),
            onChanged: (value) { setState(() { currWeek = value ?? currWeek; }); },
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
                  Navigator.pop(context, "${currWeek.year}-${currWeek.month}-${currWeek.day}");
                },
                child: const Text("Select"),
              ),
            ]
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<int>> getYearItems() {
    List<DropdownMenuItem<int>> items = [];
    for (int i = 2000; i < 2101; i++) {
      items.add(DropdownMenuItem(
        value: i,
        child: Text("${i.toString()}-${(i+1).toString()}学年"),
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
        child: Text("${d.year}.${d.month}.${d.day}-${dEnd.year}.${dEnd.month}.${dEnd.day}"),
      ));
    }
    return items;
  }

  List<DateTime> getWeekList(int year) {
    DateTime start = DateTime(year, 1, 1), end = DateTime(year+1, 12, 31);
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
