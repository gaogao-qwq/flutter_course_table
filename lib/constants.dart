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

const double narrowScreenWidthThreshold = 450;
const double largeWidthBreakpoint = 800;
const double transitionLength = 500;
const int courseInfoLength = 10;
const int largeCourseInfoLength = 20;

const List<NavigationDestination> appBarDestinations = [
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.table_chart_outlined),
    label: '课表',
    selectedIcon: Icon(Icons.table_chart),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.download_outlined),
    label: '导入课表',
    selectedIcon: Icon(Icons.download),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.settings_outlined),
    label: '设置',
    selectedIcon: Icon(Icons.settings),
  ),
];

enum ScreenSelected {
  courseTable(0),
  import(1),
  settings(2);

  const ScreenSelected(this.value);
  final int value;
}

enum AppInformation {
  appName("Flutter Course Table Demo"),
  appVersion("0.0.1"),
  appLegalese("Copyright © 2023 Zhihao Zhou under GPL-3.0 license");

  const AppInformation(this.value);
  final String value;
}
