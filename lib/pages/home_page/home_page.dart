import 'package:flutter/material.dart';
import 'package:flutter_course_table_demo/pages/home_page/change_current_course_table_dialog.dart';
import 'package:flutter_course_table_demo/pages/home_page/course_table_widget_builder.dart';
import 'package:flutter_course_table_demo/pages/home_page/delete_stored_course_table_dialog.dart';
import 'package:flutter_course_table_demo/pages/import_page/import_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseTableHomePage extends StatefulWidget {
  final SharedPreferences prefs;
  final void Function(bool useLightMode) handleBrightnessChange;

  const CourseTableHomePage({
    super.key,
    required this.prefs,
    required this.handleBrightnessChange,
  });

  @override
  State<CourseTableHomePage> createState() => _CourseTableHomePageState();
}

class _CourseTableHomePageState extends State<CourseTableHomePage> {
  late String currCourseTableName;

  @override
  void initState() {
    // currCourseTableName = "2022-2023学年第2学期课表";
    currCourseTableName = "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Course Table Demo'),
        actions: [
          _BrightnessButton(handleBrightnessChange: widget.handleBrightnessChange),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Flutter Course Table Menu'),
            ),
            ListTile(
              title: const Text('Import Table'),
              onTap: () async {
                Navigator.pop(context);
                final tmp = await Navigator.push(context, MaterialPageRoute(builder: (context) => ImportTablePage(prefs: widget.prefs)));
                if (tmp == null || tmp.isEmpty) return;
                setState(() { currCourseTableName = tmp; });
              },
            ),
            ListTile(
              title: const Text("Change Table"),
              onTap: () async {
                Navigator.pop(context);
                Set<String> keys = widget.prefs.getKeys();
                if (keys.isEmpty) {
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
                  return;
                }
                final tmp = await Navigator.push(context,
                  DialogRoute(context: context, builder: (context) => ChangeCurrentCourseTable(prefs: widget.prefs, currCourseTableName: currCourseTableName))
                );
                if (tmp == null) return;
                if (currCourseTableName != tmp) { setState(() { currCourseTableName = tmp; }); }
              },
            ),
            ListTile(
              title: const Text("Delete course table"),
              onTap: () async {
                Navigator.pop(context);
                Set<String> keys = widget.prefs.getKeys();
                if (keys.isEmpty) {
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
                  return;
                }
                final tmp = await Navigator.push(context,
                  DialogRoute(context: context, builder: (context) => DeleteStoredCourseTable(prefs: widget.prefs, currCourseTableName: currCourseTableName))
                );
                if (tmp == null) return;
                if (currCourseTableName == tmp) setState(() { currCourseTableName = ""; });
                widget.prefs.remove(tmp);
              },
            ),
            ListTile(
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'Course Table Demo',
                  applicationVersion: '1.0.0',
                );
              },
            ),
          ],
        ),
      ),
      body: (currCourseTableName.isEmpty)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("There is nothing here, select or import a course table first"),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final tmp = await Navigator.push(context, MaterialPageRoute(builder: (context) => ImportTablePage(prefs: widget.prefs)));
                      if (tmp == null || tmp.isEmpty) return;
                      setState(() { currCourseTableName = tmp; });
                    },
                    child: const Text("Import"),
                  ),
                ],
              )
            )
          : CourseTableWidget(courseTableName: currCourseTableName, courseTableRow: 12, prefs: widget.prefs),
    );
  }
}

class _BrightnessButton extends StatelessWidget {
  final Function handleBrightnessChange;
  final bool showTooltipBelow;

  const _BrightnessButton({
    required this.handleBrightnessChange,
    this.showTooltipBelow = true,
  });

  @override
  Widget build(BuildContext context) {
    final isBright = Theme.of(context).brightness == Brightness.light;
    return Tooltip(
      preferBelow: showTooltipBelow,
      message: 'Toggle brightness',
      child: IconButton(
        icon: isBright
            ? const Icon(Icons.dark_mode_outlined)
            : const Icon(Icons.light_mode_outlined),
        onPressed: () => handleBrightnessChange(!isBright),
      ),
    );
  }
}
