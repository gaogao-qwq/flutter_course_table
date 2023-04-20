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
import 'package:shared_preferences/shared_preferences.dart';

class DeleteStoredCourseTable extends StatefulWidget {
  final SharedPreferences prefs;
  final String? currCourseTableName;
  final void Function(String courseTableName) handleDeleteCurrCourseTable;

  const DeleteStoredCourseTable({
    super.key,
    required this.prefs,
    this.currCourseTableName,
    required this.handleDeleteCurrCourseTable,
  });

  @override
  State<DeleteStoredCourseTable> createState() => _DeleteStoredCourseTableState();
}

class _DeleteStoredCourseTableState extends State<DeleteStoredCourseTable> {
  late String? selectedCourseTableName;

  @override
  void initState() {
    super.initState();
    selectedCourseTableName = widget.currCourseTableName;
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
              DropdownMenu(
                label: const Text("Delete course table"),
                leadingIcon: const Icon(Icons.delete),
                initialSelection: widget.currCourseTableName,
                dropdownMenuEntries: getStoredCourseTableEntries(),
                onSelected: (value) {
                  selectedCourseTableName = value;
                },
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  ElevatedButton(
                    onPressed: () { Navigator.pop(context); },
                    child: const Text("Back"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedCourseTableName == null || selectedCourseTableName!.isEmpty) return;
                      widget.handleDeleteCurrCourseTable(selectedCourseTableName!);
                      Navigator.pop(context);
                    },
                    child: const Text("Delete"),
                  ),
              ]),
          ]),
        )
      ],
    );
  }

  List<DropdownMenuEntry<String>> getStoredCourseTableEntries() {
    List<DropdownMenuEntry<String>> items = [];
    Set<String> keys = widget.prefs.getKeys();
    for (var element in keys) {
      if (element != 'currCourseTableName' && element != 'useLightMode') {
        items.add(DropdownMenuEntry(value: element, label: element));
      }
    }
    return items;
  }
}


