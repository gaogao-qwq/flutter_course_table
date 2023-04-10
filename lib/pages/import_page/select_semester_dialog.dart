import 'package:flutter/material.dart';
import 'package:flutter_course_table_demo/internal/handlers/response_handlers.dart';

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
  int? selectedYearIndex;
  String? selectedSemester;

  @override
  void initState() {
    selectedYearIndex = widget.semesterList.length - 1;
    selectedSemester = widget.semesterList[selectedYearIndex!].semesterId1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text("Choose semester"),
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
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  items: getYearItems(),
                  value: selectedYearIndex.toString(),
                  onChanged: (value) {
                    int? year = int.parse(value ?? "-1");
                    setState(() { selectedYearIndex = year == -1 ? selectedYearIndex : year; });
                    selectedSemester = widget.semesterList[selectedYearIndex!].semesterId1;
                  },
                ),
                DropdownButton(
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
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
                    Navigator.pop(context, selectedSemester);
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
    items.add(DropdownMenuItem(value: widget.semesterList[selectedYearIndex!].semesterId1, child: const Text("第1学期")));
    items.add(DropdownMenuItem(value: widget.semesterList[selectedYearIndex!].semesterId2, child: const Text("第2学期")));
    return items;
  }
}