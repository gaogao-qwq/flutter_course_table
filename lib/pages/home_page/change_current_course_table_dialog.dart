import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangeCurrentCourseTable extends StatefulWidget {
  final SharedPreferences prefs;
  final String? currCourseTableName;

  const ChangeCurrentCourseTable({
    super.key,
    required this.prefs,
    this.currCourseTableName,
  });

  @override
  State<ChangeCurrentCourseTable> createState() => _ChangeCurrentCourseTableState();
}

class _ChangeCurrentCourseTableState extends State<ChangeCurrentCourseTable> {
  late String? selectedCourseTableName;

  @override
  void initState() {
    super.initState();
    selectedCourseTableName = (widget.currCourseTableName == null || widget.currCourseTableName!.isEmpty) ? null : widget.currCourseTableName;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Change selected course table"),
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DropdownButton(
                items: getStoredCourseTableItems(widget.prefs),
                value: selectedCourseTableName,
                onChanged: (value) { setState(() { selectedCourseTableName = value ?? ""; }); }
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () { Navigator.pop(context); },
                    style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.blueAccent)),
                    child: const Text("Back"),
                  ),
                  ElevatedButton(
                    onPressed: () { Navigator.pop(context, selectedCourseTableName); },
                    style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.greenAccent)),
                    child: const Text("Change"),
                  ),
              ])
          ]),
        )
      ],
    );
  }
}

List<DropdownMenuItem<String>> getStoredCourseTableItems(SharedPreferences prefs) {
  List<DropdownMenuItem<String>> items = [];
  Set<String> keys = prefs.getKeys();
  for (var element in keys) { items.add(DropdownMenuItem(value: element, child: Text(element))); }
  return items;
}
