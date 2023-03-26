import 'package:flutter/material.dart';
import 'package:flutter_course_table_demo/internal/handlers/response_handlers.dart';

class SemesterDropdownButton extends StatefulWidget{
  final List<SemesterInfo> semesterList;

  const SemesterDropdownButton({
    super.key,
    required this.semesterList,
  });

  @override
  State<SemesterDropdownButton> createState() => _SemesterDropdownButtonState();
}

class _SemesterDropdownButtonState extends State<SemesterDropdownButton> {
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        DropdownButton(
          items: getYearItems(),
          value: selectedYearIndex.toString(),
          onChanged: (value) {
            setState(() {
              selectedYearIndex = (value ?? 0) as int?;
            });
          },
        ),
        DropdownButton(
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
    items.add(DropdownMenuItem(value: widget.semesterList[selectedYearIndex!].semesterId1, child: const Text("第1学期"),));
    items.add(DropdownMenuItem(value: widget.semesterList[selectedYearIndex!].semesterId2, child: const Text("第2学期"),));
    return items;
  }
}