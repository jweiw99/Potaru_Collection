import 'package:flutter/material.dart';
import 'package:potaru/UI/Widgets/module.model.dart';

class TabIconData {
  TabIconData({
    this.imagePath = '',
    this.index = ModuleIndex.HOME,
    this.selectedImagePath = '',
    this.isSelected = false,
    this.animationController,
  });

  String imagePath;
  String selectedImagePath;
  bool isSelected;
  ModuleIndex index;

  AnimationController animationController;

  static List<TabIconData> homeIconsList = <TabIconData>[
    TabIconData(
      imagePath: 'assets/images/app/bottombar/tab_1.png',
      selectedImagePath: 'assets/images/app/bottombar/tab_1s.png',
      index: ModuleIndex.HOME,
      isSelected: true,
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/images/app/bottombar/tab_2.png',
      selectedImagePath: 'assets/images/app/bottombar/tab_2s.png',
      index: ModuleIndex.TIMETABLE,
      isSelected: false,
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/images/app/bottombar/tab_3.png',
      selectedImagePath: 'assets/images/app/bottombar/tab_3s.png',
      index: ModuleIndex.TASK,
      isSelected: false,
      animationController: null,
    ),
    TabIconData(
      imagePath: 'assets/images/app/bottombar/tab_4.png',
      selectedImagePath: 'assets/images/app/bottombar/tab_4s.png',
      index: ModuleIndex.ATTENDANCE,
      isSelected: false,
      animationController: null,
    ),
  ];
}
