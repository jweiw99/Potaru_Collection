import 'package:flutter/material.dart';

import 'package:potaru/UI/Modules/StaffDirectory/staffDir_screen.dart';

class StaffDirAppHomeScreen extends StatefulWidget {
  const StaffDirAppHomeScreen({Key key, this.animationController})
      : super(key: key);
  final AnimationController animationController;
  @override
  _StaffDirAppHomeScreenState createState() => _StaffDirAppHomeScreenState();
}

class _StaffDirAppHomeScreenState extends State<StaffDirAppHomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  Widget tabBody = Container(
    color: Color(0xFFF2F3F8),
  );

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    tabBody = StaffDirScreen(animationController: animationController);
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
