import 'package:flutter/material.dart';

import 'package:flutter_course_table_demo/request_handlers.dart';


class ImportTablePage extends StatefulWidget {
  const ImportTablePage({Key? key}) : super(key: key);

  @override
  State<ImportTablePage> createState() => _ImportTablePageState();
}

class _ImportTablePageState extends State<ImportTablePage> {

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    String? username, password;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Table'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
              child: TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your account',
                ),
                maxLength: 30,
                autocorrect: false,
                onChanged: (value) {
                  username = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
              child: TextFormField(
                decoration: const InputDecoration(
                  icon: Icon(Icons.lock),
                  border: UnderlineInputBorder(),
                  labelText: 'Enter your password',
                ),
                maxLength: 30,
                obscureText: true,
                autocorrect: false,
                onChanged: (value) {
                  password = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Back'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Processing data...')),
                        );
                        fetchCourseTable(username, password).then((value) {
                          for (int i = 0; i < value.data.length; i++) {
                            debugPrint(value.data[i].courseName);
                          }
                        });
                      }
                    },
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(Colors.green)),
                    child: const Text('Import'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}