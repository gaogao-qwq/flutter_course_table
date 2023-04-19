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

class LoadingOverlay extends StatelessWidget {
  final String loadingText;

  const LoadingOverlay({
    super.key,
    required this.loadingText,
  });

  @override
  Widget build(BuildContext context) => SimpleDialog(
    backgroundColor: Colors.white,
    children: <Widget>[
      Center(
        child: Container(
          padding: const EdgeInsets.all(64),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              const CircularProgressIndicator(backgroundColor: Colors.grey,),
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: Text(loadingText),
              ),
            ]
          )
        ),
      ),
    ],
  );
}