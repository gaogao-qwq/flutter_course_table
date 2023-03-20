import 'package:flutter/material.dart';

import 'package:flutter_course_table_demo/request_handlers.dart';
import 'package:loader_overlay/loader_overlay.dart';


class ImportTablePage extends StatefulWidget {
  const ImportTablePage({Key? key}) : super(key: key);

  @override
  State<ImportTablePage> createState() => _ImportTablePageState();
}

class _ImportTablePageState extends State<ImportTablePage> {

  final _formKey = GlobalKey<FormState>();
  bool _isLoaderVisible = false;

  @override
  Widget build(BuildContext context) {
    String? username, password;
    return GlobalLoaderOverlay(
      child: Scaffold(
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
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }

                        context.loaderOverlay.show(widget: const LoadingOverlay());
                        setState(() {
                          _isLoaderVisible = context.loaderOverlay.visible;
                        });

                        CourseTable? courseTable;
                        try {
                          courseTable = await fetchCourseTable(username, password);
                        } on NoSuchMethodError {
                          courseTable = const CourseTable(statusCode: 200);
                        } catch (e) {
                          courseTable = null;
                        }

                        if (!mounted) return;

                        if (_isLoaderVisible) {
                          context.loaderOverlay.hide();
                        }
                        setState(() {
                          _isLoaderVisible = context.loaderOverlay.visible;
                        });

                        if (courseTable == null) {
                          showDialog(context: context, builder: (context) {
                            return AlertDialog(
                              title: const Text("Oops"),
                              content: const Text("Can't get course table, check if the network is down."),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => {
                                    Navigator.of(context).pop()
                                  },
                                  child: const Text("OK"),
                                )
                              ],
                            );
                          });
                          return;
                        }

                        switch (courseTable.statusCode) {
                          case 401:
                            showDialog(context: context, builder: (context) {
                              return AlertDialog(
                                title: const Text("Oops"),
                                content: const Text("Authorization failed, maybe wrong account or password?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => {
                                      Navigator.of(context).pop()
                                    },
                                    child: const Text("OK"),
                                  )
                                ],
                              );
                            });
                            break;
                          case 200:
                            if (courseTable.data == null) {
                              showDialog(context: context, builder: (context) {
                                return AlertDialog(
                                  title: const Text("Oops"),
                                  content: const Text(
                                    "Everything alright but the server return a empty course table\n"
                                    "Check if you choose wrong semester\n"
                                    "Or it can be server side error as well"
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () => {
                                        Navigator.of(context).pop()
                                      },
                                      child: const Text("OK"),
                                    )
                                  ],
                                );
                              });
                            }
                            debugPrint(courseTable.statusCode.toString());
                            break;
                          default:
                            showDialog(context: context, builder: (context) {
                              return AlertDialog(
                                title: const Text("Oops"),
                                content: Text("Some error occurred, server response status code: ${courseTable?.statusCode}"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => {
                                      Navigator.of(context).pop()
                                    },
                                    child: const Text("OK"),
                                  )
                                ],
                              );
                            });
                            break;
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
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        CircularProgressIndicator(backgroundColor: Colors.white,),
        SizedBox(height: 12),
        Text(
          'Loading...',
        ),
      ],
    ),
  );
}