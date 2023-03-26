import 'package:flutter/material.dart';
import 'package:flutter_course_table_demo/internal/handlers/response_handlers.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'loading_overlay.dart';
import 'semester_dropdown_button.dart';


class ImportTablePage extends StatefulWidget {
  const ImportTablePage({Key? key}) : super(key: key);

  @override
  State<ImportTablePage> createState() => _ImportTablePageState();
}

class _ImportTablePageState extends State<ImportTablePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoaderVisible = false;

  FocusNode? blankNode = FocusNode();
  FocusNode? passwordTextNode = FocusNode();

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
                  autofocus: true,
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
                  textInputAction: TextInputAction.next,
                  onEditingComplete: () {
                    FocusScope.of(context).requestFocus(passwordTextNode);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                child: TextFormField(
                  focusNode: passwordTextNode,
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
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () {
                        FocusScope.of(context).requestFocus(blankNode);
                        Navigator.pop(context);
                      },
                      child: const Text('Back'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }

                        FocusScope.of(context).requestFocus(blankNode);

                        context.loaderOverlay.show(widget: const LoadingOverlay());
                        setState(() {
                          _isLoaderVisible = context.loaderOverlay.visible;
                        });

                        // 登陆验证
                        try {
                          if (!await authorizer(username, password)) {
                            if (!mounted) return;
                            if (_isLoaderVisible) {
                              context.loaderOverlay.hide();
                            }
                            setState(() {
                              _isLoaderVisible = context.loaderOverlay.visible;
                            });
                            showDialog(context: context, builder: (context) {
                              return AlertDialog(
                                title: const Text("Oops"),
                                content: const Text("Authorization failed"),
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
                        } catch(e) {
                          if (!mounted) return;
                          if (_isLoaderVisible) {
                            context.loaderOverlay.hide();
                          }
                          setState(() {
                            _isLoaderVisible = context.loaderOverlay.visible;
                          });
                          showDialog(context: context, builder: (context) {
                            return AlertDialog(
                              title: const Text("Oops"),
                              content: Text("$e occurred"),
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


                        // 获取 SemesterId 表
                        List<SemesterInfo>? semesterList;
                        try {
                          semesterList = await fetchSemesterList(username, password);
                        } on NoSuchMethodError {
                          if (!mounted) return;
                          if (_isLoaderVisible) {
                            context.loaderOverlay.hide();
                          }
                          setState(() {
                            _isLoaderVisible = context.loaderOverlay.visible;
                          });
                          showDialog(context: context, builder: (context) {
                            return AlertDialog(
                              title: const Text("Oops"),
                              content: const Text(
                                "Everything alright but the server return a wrong semester list\n"
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
                          return;
                        } catch(e) {
                          if (!mounted) return;
                          if (_isLoaderVisible) {
                            context.loaderOverlay.hide();
                          }
                          setState(() {
                            _isLoaderVisible = context.loaderOverlay.visible;
                          });
                          showDialog(context: context, builder: (context) {
                            return AlertDialog(
                              title: const Text("Oops"),
                              content: Text("$e occurred"),
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

                        if (!mounted) return;
                        if (_isLoaderVisible) {
                          context.loaderOverlay.hide();
                        }
                        setState(() {
                          _isLoaderVisible = context.loaderOverlay.visible;
                        });

                        // 等待用户选择要导入的学期
                        final semesterId = await Navigator.push(context, DialogRoute(context: context, builder: (context) {
                          return SimpleDialog(
                            title: const Text("Choose semester"),
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  SemesterDropdownButton(semesterList: semesterList ?? [],),
                                ],
                              ),
                            ],
                          );
                        }));

                        debugPrint(semesterId);

                        if (!mounted) return;

                        context.loaderOverlay.show(widget: const LoadingOverlay());
                        setState(() {
                          _isLoaderVisible = context.loaderOverlay.visible;
                        });

                        // TODO: Import course table implementation

                        if (_isLoaderVisible) {
                          context.loaderOverlay.hide();
                        }
                        setState(() {
                          _isLoaderVisible = context.loaderOverlay.visible;
                        });

                        // final prefs = await SharedPreferences.getInstance();
                        // List<String>? courseTableJsons = prefs.getStringList('courseTables');
                        // if (courseTableJsons == null) {
                        //   await prefs.setStringList('courseTables', [courseTable.jsonString ?? ""]);
                        // }

                      },
                      style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll<Color>(Colors.green)
                      ),
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

