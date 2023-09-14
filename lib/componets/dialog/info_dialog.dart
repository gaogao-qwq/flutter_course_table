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

void showInfoDialog(BuildContext context, String title, String content) {
  showDialog(
      context: context,
      builder: (context) {
        return InfoDialog(title: title, content: content);
      });
}

class InfoDialog extends StatefulWidget {
  final String title;
  final String content;

  const InfoDialog({super.key, required this.title, required this.content});

  @override
  State<InfoDialog> createState() => _InfoDialogState();
}

class _InfoDialogState extends State<InfoDialog>
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
    return AlertDialog(
      title: Text(widget.title),
      content: Text(widget.content),
      actions: <Widget>[
        TextButton(
          onPressed: () => {Navigator.of(context).pop()},
          child: const Text("OK"),
        )
      ],
    );
  }
}
