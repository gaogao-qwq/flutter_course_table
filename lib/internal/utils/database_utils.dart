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

import 'package:sqflite/sqflite.dart';
import 'package:sqlite3/common.dart';

// This function will return a courseTable json string by the giving name
// It will return a empty string if there's not a courseTable named by giving name.
Future<String> getCourseTableJsonByName(Database db, String name) async {
  if (!db.isOpen) {
    throw SqliteException(SqlError.SQLITE_NOTFOUND, "Sqlite database not found or cannot open");
  }
  final res = await db.query('course_tables_table',
      columns: ['json'],
      where: 'name = ?',
      whereArgs: [name],
  );
  return res.isEmpty ? "" : res[0]['json'].toString();
}

// This function will return a List that contains all courseTables' name
// If there isn't any courseTable existed, it will return empty List
Future<List<String>> getCourseTableNames(Database db) async {
  if (!db.isOpen) {
    throw SqliteException(SqlError.SQLITE_NOTFOUND, "Sqlite database not found or cannot open");
  }
  final res = await db.query('course_tables_table',
      columns: ['name'],
  );
  final l = List.generate(res.length, (index) => res[index]['name'].toString());
  return l;
}

Future<void> insertCourseTable(Database db, String name, String json) async {
  int cnt = await db.insert('course_tables_table',
      <String, Object?>{'name': name, 'json': json},
      conflictAlgorithm: ConflictAlgorithm.fail,
  );
  if (cnt == 0) {
    throw SqliteException(SqlError.SQLITE_CONSTRAINT, 'Constraint row');
  }
}

Future<void> deleteCourseTable(Database db, String name) async {
  int code = await db.delete('course_tables_table',
      where: 'name = ?',
      whereArgs: [name],
  );
  if (code != 1) {
    throw SqlError.SQLITE_NOTFOUND;
  }
}
