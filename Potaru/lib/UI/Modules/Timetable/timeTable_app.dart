import 'package:flutter/material.dart';

import 'package:potaru/UI/Modules/TimeTable/timeTable_screen.dart';

class TimetableAppHomeScreen extends StatefulWidget {
  const TimetableAppHomeScreen({Key key, this.animationController})
      : super(key: key);
  final AnimationController animationController;
  @override
  _TimetableAppHomeScreenState createState() => _TimetableAppHomeScreenState();
}

class _TimetableAppHomeScreenState extends State<TimetableAppHomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  Widget tabBody = Container(
    color: Color(0xFFF2F3F8),
  );

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    tabBody = TimetableScreen(animationController: animationController);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF2F3F8),
      child: Scaffold(backgroundColor: Colors.transparent, body: tabBody),
    );
  }
}
