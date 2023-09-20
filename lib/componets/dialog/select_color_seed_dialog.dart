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
import 'package:flutter_course_table/animations/fade_animation.dart';
import 'package:flutter_course_table/constants.dart';
import 'package:flutter_course_table/pages/data.dart';
import 'package:provider/provider.dart';

class SelectColorSeedDialog extends StatefulWidget {
  const SelectColorSeedDialog({super.key});

  @override
  State<SelectColorSeedDialog> createState() => _SelectColorSeedDialogState();
}

class _SelectColorSeedDialogState extends State<SelectColorSeedDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 200),
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_controller.status != AnimationStatus.forward) {
      _controller.forward();
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _controller.reverse();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorSeed = context.select((AppSettingData data) => data.colorSeed);
    final colorSeedEntries = ColorSeed.values
        .map((e) => DropdownMenuEntry<ColorSeed>(
              leadingIcon: Icon(Icons.circle, color: e.color),
              value: e,
              label: e.label,
            ))
        .toList();

    return FadeTransition(
      opacity: FadeAnimation(_controller),
      child: SimpleDialog(title: const Text("选择颜色主题"), children: [
        Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DropdownMenu<ColorSeed>(
                enableSearch: false,
                initialSelection: colorSeed,
                dropdownMenuEntries: colorSeedEntries,
                onSelected: (value) {
                  if (value == null) return;
                  context.read<AppSettingData>().changeColorSeed(value);
                },
              ),
              const Padding(padding: EdgeInsets.all(10)),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("确定"))
            ],
          ),
        )
      ]),
    );
  }
}
