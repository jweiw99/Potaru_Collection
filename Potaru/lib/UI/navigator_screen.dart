import 'package:flutter/material.dart';

import 'package:potaru/UI/Drawer/drawer_controller.dart';
import 'package:potaru/UI/Bar/bottom_navbar_tabicon.dart';

import 'package:potaru/UI/Modules/Timetable/timeTable_app.dart';
import 'package:potaru/UI/Modules/Tasks/tasks_app.dart';
import 'package:potaru/UI/Modules/Attendance/attendance_app.dart';
import 'package:potaru/UI/Modules/GradeCalc/gradeCalc_app.dart';
import 'package:potaru/UI/Modules/StaffDirectory/staffDir_app.dart';
import 'package:potaru/UI/Widgets/module.model.dart';

import 'package:potaru/UI/utarPortal_screen.dart';
import 'package:potaru/UI/home_screen.dart';
import 'package:potaru/UI/profile_screen.dart';
import 'package:potaru/UI/settings_screen.dart';
import 'package:potaru/UI/aboutUs_screen.dart';

class NavigatorScreen extends StatefulWidget {
  @override
  _NavigatorScreenState createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends State<NavigatorScreen>
    with SingleTickerProviderStateMixin {
  Widget screenView;
  ModuleIndex moduleIndex;
  List<TabIconData> homeIconsList = TabIconData.homeIconsList;
  bool moduleIsOpen;
  AnimationController sliderAnimationController, fadeAnimationController;
  String appbarTitle;
  ScrollController drawerScrollController = ScrollController();

  @override
  void initState() {
    fadeAnimationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);

    appbarTitle = "Potaru";
    moduleIsOpen = false;
    moduleIndex = ModuleIndex.HOME;
    setRemoveAllSelection(moduleIndex);
    screenView = HomeScreen(
      animationController: fadeAnimationController,
      onHomeListCall: (ModuleIndex moduleIndexdata) {
        changeIndex(moduleIndexdata);
        setRemoveAllSelection(moduleIndexdata);
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: false,
        child: DrawerUserController(
            screenIndex: moduleIndex,
            homeIconsList: homeIconsList,
            drawerWidth: MediaQuery.of(context).size.width * 0.75,
            animationController: (AnimationController animationController) {
              sliderAnimationController = animationController;
            },
            onDrawerCall: (ModuleIndex moduleIndexdata) {
              changeIndex(moduleIndexdata);
              setRemoveAllSelection(moduleIndexdata);
            },
            drawerScrollController: (ScrollController sc) {
              drawerScrollController = sc;
            },
            moduleIsOpen: moduleIsOpen,
            screenView: screenView,
            appbarTitle: appbarTitle),
      ),
    );
  }

  void setRemoveAllSelection(ModuleIndex index) {
    if (!mounted) return;
    setState(() {
      homeIconsList.forEach((TabIconData tab) {
        tab.isSelected = false;
        if (index == tab.index) {
          tab.isSelected = true;
        }
      });
    });
  }

  void changeIndex(ModuleIndex moduleIndexdata) {
    if (moduleIndex != moduleIndexdata) {
      moduleIndex = moduleIndexdata;
      fadeAnimationController.reverse().then<dynamic>((data) {
        if (moduleIndex == ModuleIndex.HOME) {
          setState(() {
            appbarTitle = "Potaru";
            moduleIsOpen = false;
            screenView = HomeScreen(
              animationController: fadeAnimationController,
              onHomeListCall: (ModuleIndex moduleIndexdata) {
                changeIndex(moduleIndexdata);
                setRemoveAllSelection(moduleIndexdata);
              },
            );
          });
        } else if (moduleIndex == ModuleIndex.Profile) {
          setState(() {
            appbarTitle = "Potaru";
            moduleIsOpen = false;
            screenView =
                ProfileScreen(animationController: fadeAnimationController);
          });
        } else if (moduleIndex == ModuleIndex.UTARPORTAL) {
          setState(() {
            appbarTitle = "UTAR Portal Login";
            moduleIsOpen = false;
            screenView = UTARPortalScreen(
                drawerWidth: MediaQuery.of(context).size.width * 0.75,
                animationController: fadeAnimationController,
                drawerScrollController: drawerScrollController);
          });
        } else if (moduleIndex == ModuleIndex.About) {
          setState(() {
            appbarTitle = "About";
            moduleIsOpen = false;
            screenView =
                AboutUsScreen(animationController: fadeAnimationController);
          });
        } else if (moduleIndex == ModuleIndex.Settings) {
          setState(() {
            appbarTitle = "Settings";
            moduleIsOpen = false;
            screenView =
                SettingScreen(animationController: fadeAnimationController);
          });
        } else if (moduleIndex == ModuleIndex.TIMETABLE) {
          setState(() {
            moduleIsOpen = true;
            screenView = TimetableAppHomeScreen(
                animationController: fadeAnimationController);
          });
        } else if (moduleIndex == ModuleIndex.TASK) {
          setState(() {
            moduleIsOpen = true;
            screenView =
                TaskAppHomeScreen(animationController: fadeAnimationController);
          });
        } else if (moduleIndex == ModuleIndex.ATTENDANCE) {
          setState(() {
            moduleIsOpen = true;
            screenView = AttendanceAppHomeScreen(
                animationController: fadeAnimationController);
          });
        } else if (moduleIndex == ModuleIndex.CGPA) {
          setState(() {
            moduleIsOpen = true;
            screenView = GradeCalcAppHomeScreen(
                animationController: fadeAnimationController);
          });
        } else if (moduleIndex == ModuleIndex.STAFFDIR) {
          setState(() {
            moduleIsOpen = true;
            screenView = StaffDirAppHomeScreen(
                animationController: fadeAnimationController);
          });
        }
      });
    }
  }
}
