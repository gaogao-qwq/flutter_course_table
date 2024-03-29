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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_course_table/animations/offset_animation.dart';
import 'package:flutter_course_table/animations/size_animation.dart';
import 'package:flutter_course_table/configure_dependencies.dart';
import 'package:flutter_course_table/constants.dart';
import 'package:flutter_course_table/internal/prefs/shared_preferences_repository.dart';
import 'package:flutter_course_table/internal/types/course_table.dart';
import 'package:flutter_course_table/pages/data.dart';
import 'package:flutter_course_table/pages/home_page/course_table_widget_builder.dart';
import 'package:flutter_course_table/pages/import_page/import_page.dart';
import 'package:flutter_course_table/pages/settings_page/settings_page.dart';
import 'package:provider/provider.dart';

final prefsRepository = getIt<SharedPreferencesRepository>();

final List<NavigationRailDestination> navRailDestinations = appBarDestinations
    .map(
      (destination) => NavigationRailDestination(
        icon: Tooltip(
          message: destination.label,
          child: destination.icon,
        ),
        selectedIcon: Tooltip(
          message: destination.label,
          child: destination.selectedIcon,
        ),
        label: Text(destination.label),
      ),
    )
    .toList();

class NavigationTransition extends StatefulWidget {
  const NavigationTransition({super.key, required this.showLargeSizeLayout});

  final bool showLargeSizeLayout;

  @override
  State<NavigationTransition> createState() => _NavigationTransitionState();
}

class _NavigationTransitionState extends State<NavigationTransition>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late final AnimationController _controller;
  late final CurvedAnimation railAnimation;
  late final ReverseAnimation barAnimation;
  late final ReverseAnimation pageAnimation;
  late PageController pageController;

  int screenIndex = MainPage.courseTable.index;
  bool _isPageVisible = true;
  late bool showLargeSizeLayout;

  @override
  void initState() {
    super.initState();
    showLargeSizeLayout = widget.showLargeSizeLayout;
    _controller = AnimationController(
      duration: Duration(milliseconds: transitionLength.toInt() * 2),
      vsync: this,
    );
    barAnimation = ReverseAnimation(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5),
      ),
    );
    railAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0),
    );
  }

  @override
  void didChangeDependencies() {
    final double width = MediaQuery.of(context).size.width;
    final AnimationStatus status = _controller.status;
    if (width > largeWidthBreakpoint) {
      showLargeSizeLayout = true;
      if (status != AnimationStatus.forward &&
          status != AnimationStatus.completed) {
        _controller.forward();
      }
    } else {
      showLargeSizeLayout = false;
      if (status != AnimationStatus.reverse &&
          status != AnimationStatus.dismissed) {
        _controller.reverse();
      }
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currWeek = context.select((CourseTableData data) => data.currWeek);
    pageController = PageController(initialPage: currWeek - 1);
    final courseTableNames =
        context.select((CourseTableData data) => data.courseTableNames);
    final courseTable =
        context.select((CourseTableData data) => data.courseTable);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          key: scaffoldKey,
          appBar: createAppBar(courseTableNames),
          body: Row(
            children: [
              RailTransition(
                animation: railAnimation,
                backgroundColor: colorScheme.surface,
                child: NavigationRail(
                  extended: true,
                  destinations: navRailDestinations,
                  selectedIndex: screenIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      changePageTo(MainPage.values[index]);
                    });
                  },
                  trailing: const Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: ExpandedTrailingActions()),
                  ),
                ),
              ),
              createScreenFor(MainPage.values[screenIndex], courseTable)
            ],
          ),
          bottomNavigationBar: BarTransition(
            animation: barAnimation,
            backgroundColor: colorScheme.surface,
            child: NavigationBars(
              onSelectItem: (index) {
                setState(() {
                  changePageTo(MainPage.values[index]);
                });
              },
              selectedIndex: screenIndex,
            ),
          ),
        );
      },
    );
  }

  Widget menu() {
    return Container(
      alignment: Alignment.bottomLeft,
      child: FittedBox(
        child: Row(
          children: [
            CourseTableMenu(pageController: pageController),
            const Padding(padding: EdgeInsets.only(left: 10)),
            WeekMenu(pageController: pageController),
          ],
        ),
      ),
    );
  }

  void changePageTo(MainPage page) {
    setState(() {
      screenIndex = page.index;
      _isPageVisible = !_isPageVisible;
    });
  }

  PreferredSizeWidget createAppBar(List<String> courseTableNames) {
    return AppBar(
        title: () {
          Widget title;
          switch (screenIndex) {
            case 0:
              title = courseTableNames.isEmpty
                  ? const Text("Flutter Course Table")
                  : menu();
              break;
            case 1:
              title = const Text("导入课表");
              break;
            case 2:
              title = const Text("设置");
              break;
            default:
              title = const Text("Flutter Course Table");
          }
          return title;
        }(),
        notificationPredicate: (ScrollNotification notification) {
          return notification.depth == 1;
        },
        scrolledUnderElevation: 4.0,
        actions:
            (showLargeSizeLayout) ? [Container()] : [const BrightnessButton()]);
  }

  Widget createScreenFor(MainPage screenSelected, CourseTable? courseTable) {
    switch (screenSelected) {
      case MainPage.courseTable:
        return courseTable == null
            ? Expanded(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("未选择或未导入课表，请先选择或导入课表"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      changePageTo(MainPage.import);
                    },
                    child: const Text("导入"),
                  ),
                ],
              ))
            : CourseTableWidget(pageController: pageController);
      case MainPage.import:
        return const ImportTablePage();
      case MainPage.settings:
        return const SettingsPage();
      default:
        return Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(10),
              child: Text("未选择或未导入课表，请先选择或导入课表"),
            ),
            ElevatedButton(
              onPressed: () {
                changePageTo(MainPage.import);
              },
              child: const Text("导入"),
            ),
          ],
        ));
    }
  }
}

class NavigationBars extends StatefulWidget {
  const NavigationBars({
    super.key,
    this.onSelectItem,
    required this.selectedIndex,
  });

  final void Function(int)? onSelectItem;
  final int selectedIndex;

  @override
  State<NavigationBars> createState() => _NavigationBarsState();
}

class _NavigationBarsState extends State<NavigationBars> {
  late int selectedIndex;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant NavigationBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      selectedIndex = widget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
          widget.onSelectItem!(index);
        },
        destinations: appBarDestinations,
      ),
    );
  }
}

class RailTransition extends StatefulWidget {
  const RailTransition(
      {super.key,
      required this.animation,
      required this.backgroundColor,
      required this.child});

  final Animation<double> animation;
  final Widget child;
  final Color backgroundColor;

  @override
  State<RailTransition> createState() => _RailTransition();
}

class _RailTransition extends State<RailTransition> {
  late Animation<Offset> offsetAnimation;
  late Animation<double> widthAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // The animations are only rebuilt by this method when the text
    // direction changes because this widget only depends on Directionality.
    final bool ltr = Directionality.of(context) == TextDirection.ltr;

    widthAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(SizeAnimation(widget.animation));

    offsetAnimation = Tween<Offset>(
      begin: ltr ? const Offset(-1, 0) : const Offset(1, 0),
      end: Offset.zero,
    ).animate(OffsetAnimation(widget.animation));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: DecoratedBox(
        decoration: BoxDecoration(color: widget.backgroundColor),
        child: Align(
          alignment: Alignment.topLeft,
          widthFactor: widthAnimation.value,
          child: FractionalTranslation(
            translation: offsetAnimation.value,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class BarTransition extends StatefulWidget {
  const BarTransition(
      {super.key,
      required this.animation,
      required this.backgroundColor,
      required this.child});

  final Animation<double> animation;
  final Color backgroundColor;
  final Widget child;

  @override
  State<BarTransition> createState() => _BarTransition();
}

class _BarTransition extends State<BarTransition> {
  late final Animation<Offset> offsetAnimation;
  late final Animation<double> heightAnimation;

  @override
  void initState() {
    super.initState();

    offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(OffsetAnimation(widget.animation));

    heightAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(SizeAnimation(widget.animation));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: DecoratedBox(
        decoration: BoxDecoration(color: widget.backgroundColor),
        child: Align(
          alignment: Alignment.topLeft,
          heightFactor: heightAnimation.value,
          child: FractionalTranslation(
            translation: offsetAnimation.value,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class ExpandedTrailingActions extends StatelessWidget {
  const ExpandedTrailingActions({super.key});

  @override
  Widget build(BuildContext context) {
    final isLightMode =
        context.select((AppSettingData data) => data.isLightMode);
    return Container(
      alignment: Alignment.bottomCenter,
      constraints: const BoxConstraints.tightFor(width: 250),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Divider(),
              Row(
                children: [
                  prefsRepository.isLightMode()
                      ? const Icon(Icons.light_mode_outlined)
                      : const Icon(Icons.dark_mode_outlined),
                  const Text('更改显示模式'),
                  Expanded(child: Container()),
                  Switch(
                      value: isLightMode,
                      onChanged: (value) {
                        context.read<AppSettingData>().useLightMode(value);
                      }),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BrightnessButton extends StatelessWidget {
  const BrightnessButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isBright = context.select((AppSettingData data) => data.isLightMode);
    return Tooltip(
      preferBelow: true,
      message: '更改显示模式',
      child: IconButton(
          icon: isBright
              ? const Icon(Icons.light_mode_outlined)
              : const Icon(Icons.dark_mode_outlined),
          onPressed: () =>
              context.read<AppSettingData>().useLightMode(!isBright)),
    );
  }
}

class CourseTableMenu extends StatelessWidget {
  final PageController pageController;

  const CourseTableMenu({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    final courseTableNames =
        context.select((CourseTableData data) => data.courseTableNames);
    final entries = List.generate(
        courseTableNames.length,
        (index) => DropdownMenuEntry(
            value: courseTableNames[index], label: courseTableNames[index]));
    return DropdownMenu(
      menuHeight: 400,
      leadingIcon: const Icon(Icons.table_chart),
      initialSelection: prefsRepository.getCurrentCourseTableName(),
      inputDecorationTheme: const InputDecorationTheme(isCollapsed: true),
      dropdownMenuEntries: entries,
      onSelected: (value) async {
        if (value == null || value.isEmpty) return;
        await context.read<CourseTableData>().changeByName(value);
        final initWeek = context.read<CourseTableData>().getInitWeek();
        pageController.jumpToPage(initWeek - 1);
      },
    );
  }
}

class WeekMenu extends StatelessWidget {
  final PageController pageController;
  const WeekMenu({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    final courseTableWeek =
        context.select((CourseTableData data) => data.courseTable?.week);
    final initialSelection =
        context.select((CourseTableData data) => data.currWeek);
    final entries = List.generate(courseTableWeek!, (index) {
      return DropdownMenuEntry(value: index + 1, label: "第${index + 1}周");
    });
    return DropdownMenu(
      menuHeight: 400,
      leadingIcon: const Icon(Icons.calendar_today),
      initialSelection: initialSelection,
      inputDecorationTheme: const InputDecorationTheme(isCollapsed: true),
      dropdownMenuEntries: entries,
      onSelected: (value) {
        if (value == null) return;
        animateToTargetPage(value);
      },
    );
  }

  void animateToTargetPage(int targetPage) {
    int oldPage = pageController.page!.toInt();
    if ((pageController.page! - targetPage).abs() < 1) return;
    pageController.animateToPage(targetPage - 1,
        // duration = sqrt(abs(differences between oldPage & targetPage)) * 300ms
        duration: Duration(
            milliseconds: sqrt((targetPage - oldPage).abs()).toInt() * 300),
        curve: Curves.easeInOut);
  }
}
