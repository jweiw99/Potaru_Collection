import 'package:flutter/material.dart';

import 'package:potaru/UI/Modules/Tasks/tasks_screen.dart';

class TaskAppHomeScreen extends StatefulWidget {
  const TaskAppHomeScreen({Key key, this.animationController})
      : super(key: key);
  final AnimationController animationController;
  @override
  _TaskAppHomeScreenState createState() => _TaskAppHomeScreenState();
}

class _TaskAppHomeScreenState extends State<TaskAppHomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  Widget tabBody = Container(
    color: Color(0xFFF2F3F8),
  );

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    tabBody = TasksScreen(animationController: animationController);
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
        child: Scaffold(backgroundColor: Colors.transparent, body: tabBody));
  }
}
