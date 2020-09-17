import 'package:flutter/material.dart';

enum ModuleIndex {
  HOME,
  Profile,
  UTARPORTAL,
  About,
  Settings,
  TIMETABLE,
  TASK,
  ATTENDANCE,
  CGPA,
  STAFFDIR
}

class PageList {
  PageList(
      {this.isAssetsImage = false,
      this.labelName = '',
      this.icon,
      this.imagePath,
      this.imageName = '',
      this.index});

  String labelName;
  Icon icon;
  bool isAssetsImage;
  String imagePath;
  String imageName;
  ModuleIndex index;

  static List<PageList> drawerList = <PageList>[
    PageList(
      index: ModuleIndex.HOME,
      labelName: 'Home',
      icon: Icon(Icons.home),
    ),
    PageList(
      index: ModuleIndex.UTARPORTAL,
      labelName: 'Get UTAR Data',
      icon: Icon(Icons.account_balance),
    ),
    PageList(
      index: ModuleIndex.About,
      labelName: 'About Me',
      icon: Icon(Icons.info),
    ),
    PageList(
      index: ModuleIndex.Settings,
      labelName: 'Settings',
      icon: Icon(Icons.settings),
    )
  ];

  static List<PageList> moduleList = <PageList>[
    PageList(
      index: ModuleIndex.TIMETABLE,
      labelName: 'Timetable',
      imagePath: 'assets/images/app/calendar.png',
    ),
    PageList(
      index: ModuleIndex.TASK,
      labelName: 'Task',
      imagePath: 'assets/images/app/organize.png',
    ),
    PageList(
      index: ModuleIndex.ATTENDANCE,
      labelName: 'Attendance',
      imagePath: 'assets/images/app/attendance.png',
    ),
    PageList(
      index: ModuleIndex.CGPA,
      labelName: 'Grades',
      imagePath: 'assets/images/app/budget.png',
    ),
    PageList(
      index: ModuleIndex.STAFFDIR,
      labelName: 'Staff Dir',
      imagePath: 'assets/images/app/group.png',
    )
  ];
}
