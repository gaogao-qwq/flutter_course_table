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
import 'package:flutter_course_table/internal/database/course_table_repository.dart';
import 'package:flutter_course_table/internal/handlers/response_handlers.dart';
import 'package:flutter_course_table/internal/types/course_table.dart';
import 'package:flutter_course_table/internal/types/semester_info.dart';
import 'package:flutter_course_table/internal/utils/course_table_json_handlers.dart';
import 'package:flutter_course_table/pages/import_page/loading_overlay.dart';
import 'package:flutter_course_table/pages/import_page/name_table_dialog.dart';
import 'package:flutter_course_table/pages/import_page/select_first_week_date_dialog.dart';
import 'package:flutter_course_table/pages/import_page/select_semester_dialog.dart';
import 'package:flutter_course_table/utils/show_info_dialog.dart';
import 'package:loader_overlay/loader_overlay.dart';

class ImportFromCrawler extends StatefulWidget {
  final Future<void> Function(String courseTableName)
      handleCurrCourseTableChange;
  final CourseTableRepository courseTableRepository;

  const ImportFromCrawler(
      {super.key,
      required this.handleCurrCourseTableChange,
      required this.courseTableRepository});

  @override
  State<ImportFromCrawler> createState() => _ImportFromCrawlerState();
}

class _ImportFromCrawlerState extends State<ImportFromCrawler> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoaderVisible = false;
  String? username, password;
  FocusNode? blankNode = FocusNode();
  FocusNode? passwordTextNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("从爬虫服务器导入")),
      body: GlobalLoaderOverlay(
          child: ListView(
        children: [
          Form(
              key: _formKey,
              child: Container(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: TextFormField(
                        autofocus: true,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.person),
                          border: UnderlineInputBorder(),
                          labelText: "请输入帐号",
                        ),
                        maxLength: 30,
                        autocorrect: false,
                        onChanged: (value) {
                          setState(() {
                            username = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "请输入有效账号";
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
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: TextFormField(
                        focusNode: passwordTextNode,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.lock),
                          border: UnderlineInputBorder(),
                          labelText: "请输入密码",
                        ),
                        maxLength: 30,
                        obscureText: true,
                        autocorrect: false,
                        onChanged: (value) {
                          setState(() {
                            password = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "请输入有效密码";
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(120, 50)),
                          onPressed: () async {
                            // 验证表单
                            if (!_formKey.currentState!.validate()) return;
                            // 聚焦至空白 Node
                            FocusScope.of(context).requestFocus(blankNode);

                            // Start importing...
                            context.loaderOverlay.show(
                                widget: const LoadingOverlay(
                              loadingText: '登录中...',
                            ));
                            setState(() {
                              _isLoaderVisible = context.loaderOverlay.visible;
                            });

                            // 获取 SemesterId 表
                            List<SemesterInfo>? semesterList;
                            try {
                              semesterList =
                                  await fetchSemesterList(username, password);
                            } catch (e) {
                              if (!mounted) return;
                              if (_isLoaderVisible) {
                                context.loaderOverlay.hide();
                              }
                              setState(() {
                                _isLoaderVisible =
                                    context.loaderOverlay.visible;
                              });
                              showInfoDialog(context, "Oops", "发生了错误：$e");
                              return;
                            }

                            if (!mounted) return;
                            if (_isLoaderVisible) {
                              context.loaderOverlay.hide();
                            }
                            setState(() {
                              _isLoaderVisible = context.loaderOverlay.visible;
                            });
                            // End logging...

                            if (semesterList == null) {
                              if (!mounted) return;
                              showInfoDialog(
                                  context,
                                  "Oops",
                                  "服务端返回了空学期列表\n"
                                      "检查设备网络是否已连接\n"
                                      "这也有可能是服务端的错误");
                              return;
                            }

                            // 等待用户选择要导入的学期
                            Map<String, String>? semester =
                                await Navigator.push(
                                    context,
                                    DialogRoute(
                                        context: context,
                                        builder: (context) {
                                          return SelectSemesterDialog(
                                              semesterList: semesterList!);
                                        }));
                            if (semester == null) {
                              if (!mounted) return;
                              if (_isLoaderVisible) {
                                context.loaderOverlay.hide();
                              }
                              setState(() {
                                _isLoaderVisible =
                                    context.loaderOverlay.visible;
                              });
                              showInfoDialog(context, "注意", "由于用户取消，课表未导入");
                              return;
                            }

                            // 等待用户选择课表第一周日期
                            if (!mounted) return;
                            String? firstWeekDate = await Navigator.push(
                                context,
                                DialogRoute(
                                    context: context,
                                    builder: (context) {
                                      return FirstWeekDateSelector(
                                          selectedYear:
                                              semester['selectedYear'] ?? "");
                                    }));
                            if (firstWeekDate == null ||
                                firstWeekDate.isEmpty) {
                              if (!mounted) return;
                              showInfoDialog(context, "注意", "未指定第一周日期，课表未导入");
                              return;
                            }

                            // 等待用户输入课程表名称
                            if (!mounted) return;
                            String? courseTableName = await Navigator.push(
                                context,
                                DialogRoute(
                                    context: context,
                                    builder: (context) {
                                      String initName = "";
                                      for (int i = 0;
                                          i < semesterList!.length;
                                          i++) {
                                        if (semester['selectedSemester'] ==
                                            semesterList[i].semesterId1) {
                                          initName =
                                              "${semesterList[i].value}学年第1学期课表";
                                          break;
                                        }
                                        if (semester['selectedSemester'] ==
                                            semesterList[i].semesterId2) {
                                          initName =
                                              "${semesterList[i].value}学年第2学期课表";
                                          break;
                                        }
                                      }
                                      return NameTableDialog(
                                          initName: initName,
                                          courseTableRepository:
                                              widget.courseTableRepository);
                                    }));
                            if (courseTableName == null ||
                                courseTableName.isEmpty) {
                              if (!mounted) return;
                              if (_isLoaderVisible) {
                                context.loaderOverlay.hide();
                              }
                              setState(() {
                                _isLoaderVisible =
                                    context.loaderOverlay.visible;
                              });
                              showInfoDialog(context, "注意", "由于用户取消，课表未导入");
                              return;
                            }

                            // Start importing...
                            if (!mounted) return;
                            context.loaderOverlay.show(
                                widget: const LoadingOverlay(
                              loadingText: '导入中...',
                            ));
                            setState(() {
                              _isLoaderVisible = context.loaderOverlay.visible;
                            });

                            CourseTable? courseTable;
                            try {
                              courseTable = await fetchCourseTable(
                                  username,
                                  password,
                                  semester['selectedSemester'],
                                  firstWeekDate,
                                  courseTableName);
                            } catch (e) {
                              if (!mounted) return;
                              if (_isLoaderVisible) {
                                context.loaderOverlay.hide();
                              }
                              setState(() {
                                _isLoaderVisible =
                                    context.loaderOverlay.visible;
                              });
                              showInfoDialog(context, "Oops", "发生了错误：$e");
                              return;
                            }

                            if (!mounted) return;
                            if (_isLoaderVisible) {
                              context.loaderOverlay.hide();
                            }
                            setState(() {
                              _isLoaderVisible = context.loaderOverlay.visible;
                            });
                            // End importing...

                            if (courseTable == null) {
                              if (!mounted) return;
                              showInfoDialog(
                                  context,
                                  "Oops",
                                  "服务端返回了空课表\n"
                                      "请检查是否选择了错误的学期\n"
                                      "这也有可能是服务端的错误");
                              return;
                            }

                            // Start saving...
                            context.loaderOverlay.show(
                                widget: const LoadingOverlay(
                              loadingText: '保存中...',
                            ));
                            setState(() {
                              _isLoaderVisible = context.loaderOverlay.visible;
                            });

                            String jsonString;
                            try {
                              jsonString = courseTableToJson(courseTable);
                            } catch (e) {
                              if (!mounted) return;
                              showInfoDialog(context, "Oops", "发生了错误：$e");
                              if (_isLoaderVisible) {
                                context.loaderOverlay.hide();
                              }
                              setState(() {
                                _isLoaderVisible =
                                    context.loaderOverlay.visible;
                              });
                              return;
                            }

                            // 存入 Database
                            try {
                              await widget.courseTableRepository
                                  .insertCourseTable(
                                      courseTableName, jsonString);
                            } catch (e) {
                              if (!mounted) return;
                              showInfoDialog(context, "Oops", "发生了错误：$e");
                              if (_isLoaderVisible) {
                                context.loaderOverlay.hide();
                              }
                              setState(() {
                                _isLoaderVisible =
                                    context.loaderOverlay.visible;
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
                            // End saving...

                            await widget
                                .handleCurrCourseTableChange(courseTableName);
                            if (!mounted) return;
                            showInfoDialog(context, "喜报", "导入成功");
                          },
                          child:
                              const Text('导入', style: TextStyle(fontSize: 18))),
                    ),
                  ],
                ),
              )),
        ],
      )),
    );
  }
}
