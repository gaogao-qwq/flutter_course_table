import 'package:flutter/material.dart';

const double narrowScreenWidthThreshold = 450;

const double mediumWidthBreakpoint = 1000;
const double largeWidthBreakpoint = 1500;

const double transitionLength = 500;

const List<NavigationDestination> appBarDestinations = [
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.table_chart_outlined),
    label: 'Course Table',
    selectedIcon: Icon(Icons.table_chart),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.download_outlined),
    label: 'Import',
    selectedIcon: Icon(Icons.download),
  ),
  NavigationDestination(
    tooltip: '',
    icon: Icon(Icons.settings_outlined),
    label: 'Settings',
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
  appVersion("0.0.1");

  const AppInformation(this.value);
  final String value;
}
