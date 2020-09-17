import 'package:flutter/material.dart';

import 'package:potaru/UI/Modules/Attendance/attendance_screen.dart';

class AttendanceAppHomeScreen extends StatefulWidget {
  const AttendanceAppHomeScreen({Key key, this.animationController})
      : super(key: key);
  final AnimationController animationController;
  @override
  _AttendanceAppHomeScreenState createState() =>
      _AttendanceAppHomeScreenState();
}

class _AttendanceAppHomeScreenState extends State<AttendanceAppHomeScreen> {
  Widget tabBody = Container(
    color: Color(0xFFF2F3F8),
  );

  @override
  void initState() {
    tabBody = AttendanceScreen(
        animationController: widget.animationController,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController,
            curve: Interval((1 / 2) * 1, 1.0, curve: Curves.fastOutSlowIn))));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF2F3F8),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Stack(
                children: <Widget>[tabBody],
              );
            }
          },
        ),
      ),
    );
  }

  Future<bool> getData() async {
    //await Future<dynamic>.delayed(const Duration(milliseconds: 0));
    return true;
  }
}
