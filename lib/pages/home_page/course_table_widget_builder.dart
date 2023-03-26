import 'package:flutter/material.dart';

Future<Table?> tableRowBuilder() async {
  Table courseTable = Table();
  courseTable.children.add(
    const TableRow(

    )
  );

  return courseTable;
}


Table? courseTableWidget = Table(
  children: [
    TableRow(
      children: <Widget>[
        Container(

        ),
      ],
    ),
  ],
);
