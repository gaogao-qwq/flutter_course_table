import 'package:flutter/material.dart';
import 'package:flutter_course_table_demo/internal/handlers/response_handlers.dart';
import 'package:flutter_course_table_demo/pages/import_page/name_table_dialog.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'loading_overlay.dart';
import 'select_semester_dialog.dart';


class ImportTablePage extends StatefulWidget {
  const ImportTablePage({Key? key}) : super(key: key);

  @override
  State<ImportTablePage> createState() => _ImportTablePageState();
}

class _ImportTablePageState extends State<ImportTablePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoaderVisible = false;
  String? username, password;
  FocusNode? blankNode = FocusNode();
  FocusNode? passwordTextNode = FocusNode();

  @override
  Widget build(BuildContext context) {

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
                  onChanged: (value) { setState(() { username = value; }); },
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your account';
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
                  onChanged: (value) { setState(() { password = value; }); },
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Please enter your password';
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
                        // 验证表单
                        if (!_formKey.currentState!.validate()) return;
                        // 聚焦至空白 Node
                        FocusScope.of(context).requestFocus(blankNode);

                        // Start importing...
                        context.loaderOverlay.show(widget: const LoadingOverlay(loadingText: 'Logging...',));
                        setState(() { _isLoaderVisible = context.loaderOverlay.visible; });

                        // 登陆验证
                        try {
                          if (!await authorizer(username, password)) {
                            if (!mounted) return;
                            if (_isLoaderVisible) context.loaderOverlay.hide();
                            setState(() { _isLoaderVisible = context.loaderOverlay.visible; });
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
                          if (_isLoaderVisible) context.loaderOverlay.hide();
                          setState(() { _isLoaderVisible = context.loaderOverlay.visible; });
                          showDialog(context: context, builder: (context) {
                            return AlertDialog(
                              title: const Text("Oops"),
                              content: Text("Error occurred: $e"),
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
                        } catch(e) {
                          if (!mounted) return;
                          if (_isLoaderVisible) context.loaderOverlay.hide();
                          setState(() { _isLoaderVisible = context.loaderOverlay.visible; });
                          showDialog(context: context, builder: (context) {
                            return AlertDialog(
                              title: const Text("Oops"),
                              content: Text("Error occurred: $e"),
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
                        if (_isLoaderVisible) context.loaderOverlay.hide();
                        setState(() { _isLoaderVisible = context.loaderOverlay.visible; });
                        // End logging...

                        if (semesterList == null) {
                          if (!mounted) return;
                          showDialog(context: context, builder: (context) {
                            return AlertDialog(
                              title: const Text("Oops"),
                              content: const Text(
                                "Everything alright but the server return a empty semester list\n"
                                "Check if the network is down\n"
                                "Or it can be server side error as well"
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

                        // 等待用户选择要导入的学期
                        final semesterId = await Navigator.push(context, DialogRoute(context: context, builder: (context) {
                          return SelectSemesterDialog(semesterList: semesterList!);
                        }));
                        if (semesterId == null) {
                          if (!mounted) return;
                          if (_isLoaderVisible) context.loaderOverlay.hide();
                          setState(() { _isLoaderVisible = context.loaderOverlay.visible; });
                          showDialog(context: context, builder: (context) {
                            return AlertDialog(
                              title: const Text("Note"),
                              content: const Text("Nothing was imported due to user cancellation"),
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

                        // Start importing...
                        if (!mounted) return;
                        context.loaderOverlay.show(widget: const LoadingOverlay(loadingText: 'Importing...',));
                        setState(() { _isLoaderVisible = context.loaderOverlay.visible; });

                        CourseTable? courseTable;
                        try {
                          courseTable = await fetchCourseTable(username, password, semesterId);
                        } catch(e) {
                          if (!mounted) return;
                          if (_isLoaderVisible) context.loaderOverlay.hide();
                          setState(() { _isLoaderVisible = context.loaderOverlay.visible; });
                          showDialog(context: context, builder: (context) {
                            return AlertDialog(
                              title: const Text("Oops"),
                              content: Text("Error occurred: $e"),
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
                        if (_isLoaderVisible) context.loaderOverlay.hide();
                        setState(() { _isLoaderVisible = context.loaderOverlay.visible; });
                        // End importing...

                        if (courseTable == null) {
                          if (!mounted) return;
                          showDialog(context: context, builder: (context) {
                            return AlertDialog(
                              title: const Text("Oops"),
                              content: const Text(
                                  "Everything alright but the server return a empty course table list\n"
                                  "Check if you choose wrong semester\n"
                                  "Or it can be server side error as well"
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

                        // Start saving...
                        context.loaderOverlay.show(widget: const LoadingOverlay(loadingText: 'Saving...',));
                        setState(() { _isLoaderVisible = context.loaderOverlay.visible; });

                        final prefs = await SharedPreferences.getInstance();

                        if (!mounted) return;
                        String? courseTableName = await Navigator.push(context, DialogRoute(context: context, builder: (context) {
                          String initName = "";
                          for (int i = 0; i < semesterList!.length; i++) {
                            if (semesterId == semesterList[i].semesterId1) {
                              initName = "${semesterList[i].value}学年第1学期课表";
                              break;
                            }
                            if (semesterId == semesterList[i].semesterId2) {
                              initName = "${semesterList[i].value}学年第2学期课表";
                              break;
                            }
                          }
                          return NameTableDialog(initName: initName, prefs: prefs);
                        }));
                        if (courseTableName == null) {
                          if (!mounted) return;
                          if (_isLoaderVisible) context.loaderOverlay.hide();
                          setState(() { _isLoaderVisible = context.loaderOverlay.visible; });
                          showDialog(context: context, builder: (context) {
                            return AlertDialog(
                              title: const Text("Note"),
                              content: const Text("Nothing was imported due to user cancellation"),
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
                        if (!await prefs.setString(courseTableName, courseTable.jsonString)) {
                          if (!mounted) return;
                          if (_isLoaderVisible) context.loaderOverlay.hide();
                          setState(() { _isLoaderVisible = context.loaderOverlay.visible; });
                          showDialog(context: context, builder: (context) {
                            return AlertDialog(
                              title: const Text("Oops"),
                              content: const Text(
                                  "Saving course table to device failed, check if your device has enough spaces"
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

                        if (!mounted) return;
                        if (_isLoaderVisible) context.loaderOverlay.hide();
                        setState(() { _isLoaderVisible = context.loaderOverlay.visible; });
                        // End saving...
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

