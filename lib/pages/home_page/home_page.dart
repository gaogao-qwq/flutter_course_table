import 'package:flutter/material.dart';
import 'package:flutter_course_table_demo/pages/home_page/course_table_widget_builder.dart';
import 'package:flutter_course_table_demo/pages/import_page/import_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseTableHomePage extends StatefulWidget {
  final SharedPreferences prefs;
  const CourseTableHomePage({
    super.key,
    required this.prefs,
  });

  @override
  State<CourseTableHomePage> createState() => _CourseTableHomePageState();
}

class _CourseTableHomePageState extends State<CourseTableHomePage> {
  String? currCourseTableName;

  @override
  void initState() {
    currCourseTableName = "0";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Course Table Demo'),
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
                setState(() { currCourseTableName = tmp; });
              },
            ),
            ListTile(
              title: const Text("Change Table"),
              onTap: () {
                Navigator.pop(context);
                setState(() { currCourseTableName = ""; });
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
      body: CourseTableWidget(courseTableName: currCourseTableName!, prefs: widget.prefs),
    );
  }
}
