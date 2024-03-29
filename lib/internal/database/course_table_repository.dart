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

import 'package:flutter_course_table/configure_dependencies.dart';
import 'package:flutter_course_table/internal/types/course_table.dart';
import 'package:flutter_course_table/internal/utils/course_table_json_handlers.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqlite3/common.dart';

final Database database = getIt.get<Database>();

@singleton
class CourseTableRepository {
  Future<int> count() async {
    if (!database.isOpen) {
      throw SqliteException(
          SqlError.SQLITE_NOTFOUND, 'Sqlite database not found or cannot open');
    }
    return Sqflite.firstIntValue(await database
            .rawQuery('SELECT COUNT(*) FROM course_tables_table')) ??
        0;
  }

  Future<bool> containName(String name) async {
    if (!database.isOpen) {
      throw SqliteException(
          SqlError.SQLITE_NOTFOUND, "Sqlite database not found or cannot open");
    }
    return Sqflite.firstIntValue(await database.rawQuery(
            'SELECT COUNT(*) FROM course_tables_table WHERE name = \'name\'')) !=
        0;
  }

  // This function will return a courseTable json string by the giving name
  // It will return a empty string if there's not a courseTable named by giving name.
  Future<String> getCourseTableJsonByName(String name) async {
    if (!database.isOpen) {
      throw SqliteException(
          SqlError.SQLITE_NOTFOUND, "Sqlite database not found or cannot open");
    }
    final res = await database.query(
      'course_tables_table',
      columns: ['json'],
      where: 'name = ?',
      whereArgs: [name],
    );
    return res.isEmpty ? "" : res[0]['json'].toString();
  }

  Future<CourseTable?> getCourseTableByName(String name) async {
    return jsonToCourseTable(await getCourseTableJsonByName(name));
  }

  // This function will return a List that contains all courseTables' name
  // If there isn't any courseTable existed, it will return empty List
  Future<List<String>> getCourseTableNames() async {
    if (!database.isOpen) {
      throw SqliteException(
          SqlError.SQLITE_NOTFOUND, "Sqlite database not found or cannot open");
    }
    final res = await database.query(
      'course_tables_table',
      columns: ['name'],
    );
    return List.generate(res.length, (index) => res[index]['name'].toString());
  }

  Future<void> insertCourseTable(String name, String json) async {
    int cnt = await database.insert(
      'course_tables_table',
      <String, Object?>{'name': name, 'json': json},
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
    if (cnt == 0) {
      throw SqliteException(SqlError.SQLITE_CONSTRAINT, 'Constraint row');
    }
  }

  Future<void> deleteCourseTableByName(String name) async {
    int cnt = await database.delete(
      'course_tables_table',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (cnt != 1) {
      throw SqlError.SQLITE_NOTFOUND;
    }
  }
}
