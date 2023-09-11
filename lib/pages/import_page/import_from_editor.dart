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

// TODO: Implement ImportFromEditor
class ImportFromEditor extends StatefulWidget {
  const ImportFromEditor({super.key});

  @override
  State<ImportFromEditor> createState() => _ImportFromEditorState();
}

class _ImportFromEditorState extends State<ImportFromEditor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("手动创建课表")),
      body: const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [Text("前有通路，所以，等待很重要"), Text("敬请见证")],
        ),
      ),
    );
  }
}
