import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeleteStoredCourseTable extends StatefulWidget {
  final SharedPreferences prefs;
  final String? currCourseTableName;

  const DeleteStoredCourseTable({
    super.key,
    required this.prefs,
    this.currCourseTableName,
  });

  @override
  State<DeleteStoredCourseTable> createState() => _DeleteStoredCourseTableState();
}

class _DeleteStoredCourseTableState extends State<DeleteStoredCourseTable> {
  late String? selectedCourseTableName;

  @override
  void initState() {
    super.initState();
    selectedCourseTableName = (widget.currCourseTableName == null || widget.currCourseTableName!.isEmpty) ? null : widget.currCourseTableName;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Delete selected course table"),
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
                    style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll<Color>(Colors.redAccent)),
                    child: const Text("Delete"),
                  ),
              ]),
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
