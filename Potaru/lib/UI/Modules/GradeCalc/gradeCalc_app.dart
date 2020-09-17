import 'package:flutter/material.dart';

import 'package:potaru/UI/Modules/GradeCalc/gradeCalc_screen.dart';
import 'package:potaru/UI/Modules/GradeCalc/gradeCwCalc_screen.dart';
import 'package:potaru/UI/Modules/GradeCalc/gradeHist_screen.dart';
import 'package:potaru/UI/Modules/GradeCalc/gradeManuCalc_screen.dart';

class GradeCalcAppHomeScreen extends StatefulWidget {
  const GradeCalcAppHomeScreen({Key key, this.animationController})
      : super(key: key);
  final AnimationController animationController;
  @override
  _GradeCalcAppHomeScreenState createState() => _GradeCalcAppHomeScreenState();
}

class _GradeCalcAppHomeScreenState extends State<GradeCalcAppHomeScreen>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  int bodyIndex = 0;

  List<Map<String, String>> dropDropList = [
    {"title": "CGPA Calculator", "code": "CGPA_CALC"},
    {"title": "Manual CGPA Calculator", "code": "CGPA_CALC2"},
    {"title": "Coursework Mark Calculator", "code": "CW_CALC"},
    {"title": "Grade Report", "code": "GPA_HIS"}
  ];

  Widget tabBody = Container(
    color: Color(0xFFF2F3F8),
  );

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    tabBody = GradeCalcScreen(
      animationController: animationController,
      dropDropList: dropDropList,
      callBackIndex: (int index) {
        changeBody(index, "");
      },
      dropDownINDEX: 0,
      session: "",
    );
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[tabBody],
        ),
      ),
    );
  }

  void changeBody(int index, String session) {
    if (bodyIndex != index) {
      bodyIndex = index;
      animationController.reverse().then((data) {
        if (dropDropList[bodyIndex]['code'] == "CGPA_CALC") {
          setState(() {
            tabBody = GradeCalcScreen(
                animationController: animationController,
                dropDropList: dropDropList,
                callBackIndex: (int index) {
                  changeBody(index, "");
                },
                session: session,
                dropDownINDEX: index);
          });
        } else if (dropDropList[bodyIndex]['code'] == "CGPA_CALC2") {
          setState(() {
            tabBody = GradeManualScreen(
                animationController: animationController,
                dropDropList: dropDropList,
                callBackIndex: (int index) {
                  changeBody(index, "");
                },
                dropDownINDEX: index);
          });
        } else if (dropDropList[bodyIndex]['code'] == "CW_CALC") {
          setState(() {
            tabBody = GradeCWScreen(
                animationController: animationController,
                dropDropList: dropDropList,
                callBackIndex: (int index) {
                  changeBody(index, "");
                },
                dropDownINDEX: index);
          });
        } else if (dropDropList[bodyIndex]['code'] == "GPA_HIS") {
          setState(() {
            tabBody = GradeHistScreen(
                animationController: animationController,
                dropDropList: dropDropList,
                callBackIndex: (int index, String session) {
                  changeBody(index, session);
                },
                dropDownINDEX: index);
          });
        }
      });
    }
  }
}
