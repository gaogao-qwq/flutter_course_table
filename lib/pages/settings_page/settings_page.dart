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
import 'package:flutter_course_table_demo/constants.dart';
import 'package:flutter_course_table_demo/pages/home_page/change_current_course_table_dialog.dart';
import 'package:flutter_course_table_demo/pages/home_page/delete_stored_course_table_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final SharedPreferences prefs;
  final String currCourseTableName;
  final void Function(String courseTableName) handleChangeCurrCourseTable;
  final void Function(String courseTableName) handleDeleteCurrCourseTable;

  const SettingsPage({
    super.key,
    required this.prefs,
    required this.currCourseTableName,
    required this.handleChangeCurrCourseTable,
    required this.handleDeleteCurrCourseTable,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double? width;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      width = MediaQuery.of(context).size.width;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text("Change current course table"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.currCourseTableName),
                  const Icon(Icons.arrow_drop_down)
              ]),
              onTap: () {
                if (widget.prefs.getKeys().isEmpty) {
                  showDialog(context: context, builder: (context) {
                    return AlertDialog(
                      title: const Text("Oops"),
                      content: const Text(
                          "You haven't import any course table yet"
                      ),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () => {Navigator.of(context).pop()},
                            child: const Text("OK")
                        )
                      ],
                    );
                  });
                }
                Navigator.push(context, DialogRoute(context: context, builder:
                   (context) => ChangeCurrentCourseTable(
                  prefs: widget.prefs,
                  currCourseTableName: widget.currCourseTableName,
                  handleChangeCurrCourseTable: widget.handleChangeCurrCourseTable,
                )));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("Delete course table"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
              ),
              onTap: () {
                if (widget.prefs.getKeys().isEmpty) {
                  showDialog(context: context, builder: (context) {
                    return AlertDialog(
                      title: const Text("Oops"),
                      content: const Text(
                          "You haven't import any course table yet"
                      ),
                      actions: <Widget>[
                        TextButton(
                            onPressed: () => {Navigator.of(context).pop()},
                            child: const Text("OK")
                        )
                      ],
                    );
                  });
                }
                Navigator.push(context, DialogRoute(context: context, builder:
                    (context) => DeleteStoredCourseTable(
                  prefs: widget.prefs,
                  currCourseTableName: widget.currCourseTableName,
                  handleDeleteCurrCourseTable: widget.handleChangeCurrCourseTable,
                )));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text("About"),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: AppInformation.appName.value,
                  applicationVersion: AppInformation.appVersion.value,
                );
              },
            ),
          ],
        ),
      )
    );
  }

  List<DropdownMenuEntry<String>> getStoredCourseTableEntries(SharedPreferences prefs) {
    List<DropdownMenuEntry<String>> items = [];
    Set<String> keys = prefs.getKeys();
    for (var element in keys) {
      if (element != 'currCourseTableName') {
        items.add(DropdownMenuEntry(value: element, label: element));
      }
    }
    return items;
  }
}
