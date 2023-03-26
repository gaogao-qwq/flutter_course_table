import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../import_page/import_page.dart';

class CourseTableHomePage extends StatelessWidget {
  const CourseTableHomePage({super.key});

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
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ImportTablePage(),
                  ),
                );
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
      body: Scaffold(
        body: ElevatedButton(
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            List<String>? courseTableJsons = prefs.getStringList('courseTables');
            int len = courseTableJsons?.length ?? 0;
            for (int i = 0; i < len; i++) {
              debugPrint(courseTableJsons![i]);
            }
          },
          child: const Text("debug"),
        ),
      ),
    );
  }
}
