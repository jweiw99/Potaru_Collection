import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'package:potaru/Controller/timetable.controller.dart';
import 'package:potaru/Controller/semester.controller.dart';
import 'package:potaru/Controller/attendance.controller.dart';
import 'package:potaru/Controller/grade.controller.dart';
import 'package:potaru/Controller/cgpa.controller.dart';
import 'package:potaru/Model/cgpa.model.dart';
import 'package:potaru/Model/semester.model.dart';
import 'package:potaru/Model/timetable.model.dart';
import 'package:potaru/Model/attendance.model.dart';
import 'package:potaru/Model/grade.model.dart';
import 'package:potaru/UI/utils/errorMsg.dart';

class UTARPortalScreen extends StatefulWidget {
  const UTARPortalScreen(
      {Key key,
      this.drawerWidth,
      this.animationController,
      this.drawerScrollController})
      : super(key: key);
  final double drawerWidth;
  final AnimationController animationController;
  final ScrollController drawerScrollController;

  @override
  _UTARPortalScreenState createState() => _UTARPortalScreenState();
}

class _UTARPortalScreenState extends State<UTARPortalScreen> {
  Widget screenView;
  AnimationController animationController;
  final flutterWebviewPlugin = FlutterWebviewPlugin();
  String sessionCookie;
  bool downloading = false;

  TimetableController timetableController = TimetableController();
  SemesterController semesterController = SemesterController();
  AttendanceController attendanceController = AttendanceController();
  GradeController gradeController = GradeController();
  CGPAController cgpaController = CGPAController();

  @override
  void initState() {
    animationController = widget.animationController;
    _webViewLogin();
    screenView = webView();
    widget.drawerScrollController
      ..addListener(() {
        if (widget.drawerScrollController.offset > widget.drawerWidth - 5 && !downloading) {
          flutterWebviewPlugin.show();
        } else if (widget.drawerScrollController.offset <=
            widget.drawerWidth - 5 && !downloading) {
          flutterWebviewPlugin.hide();
        }
      });
    super.initState();
  }

  @override
  void dispose() {
    widget.drawerScrollController.removeListener(() {});
    flutterWebviewPlugin.dispose();
    super.dispose();
  }

  void _webViewLogin() {
    flutterWebviewPlugin.onUrlChanged.listen((String url) async {
      var _uri = Uri.parse(url);
      //print("URL changed: ${_uri.path}");
      if (_uri.path == "/stuIntranet/default.jsp") {
        final String result =
            await flutterWebviewPlugin.getAllCookies(_uri.toString());
        flutterWebviewPlugin.close();
        downloading = true;
        sessionCookie = result.split("JSESSIONID=")[1].split(";")[0];
        await syncDB();
      }
    });
  }

  Future<http.Response> getTimetable() async {
    return await http.post('https://potaru-api.herokuapp.com/api/timetable/',
        headers: {"Accept": "application/json"},
        body: {'JSESSIONID': sessionCookie});
  }

  Future<bool> syncDB() async {
    var response = await getTimetable();
    if (response.statusCode == 200) {
      //Timetable
      List timetableData = json.decode(response.body)['data']['timetable'];
      final items = timetableData.map((i) => Timetable.fromMapObject(i));
      for (final item in items) {
        await timetableController.insertTimetable(item);
      }

      // Semester
      List semesterData = json.decode(response.body)['data']['semester'];
      final semesteritems = semesterData.map((i) => Semester.fromMapObject(i));
      for (final item in semesteritems) {
        await semesterController.insertSemester(item);
      }

      // Attendance
      List attendanceData = json.decode(response.body)['data']['attendance'];
      final attendanceitems =
          attendanceData.map((i) => Attendance.fromMapObject(i));
      for (final item in attendanceitems) {
        await attendanceController.insertAttendance(item);
      }

      // Course List with and without timetable
      List courseGradeData = json.decode(response.body)['data']['courseGrade'];
      final courseGradeitems =
          courseGradeData.map((i) => Grade.fromMapObject(i));
      for (final item in courseGradeitems) {
        await gradeController.insertSubject(item);
      }

      // previous sem CGPA List
      List cgpaData = json.decode(response.body)['data']['cgpa'];
      final cgpaitems = cgpaData.map((i) => CGPA.fromMapObject(i));
      for (final item in cgpaitems) {
        await cgpaController.insertCGPA(item);
      }

      setState(() {
        screenView = messageUI();
      });
      return true;
    }
    ErrorMsg.serverErrorMsg();
    setState(() {
      screenView = SizedBox();
    });
    return false;
  }

  Widget webView() {
    return SafeArea(
        top: true,
        bottom: true,
        child: WebviewScaffold(
            url: "https://portal.utar.edu.my/loginPageV2.jsp",
            userAgent:
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.97 Safari/537.36",
            initialChild: WillPopScope(
              onWillPop: _onWillPop,
              child: Container(
                color: Color(0xFFF2F3F8),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Color(0xFFF2F3F8),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80),
          child: SizedBox(height: 80),
        ),
        body: Stack(
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.only(
                    top: 5, left: 5, right: 5, bottom: 70),
                child: screenView)
          ],
        ));
  }

  Widget messageUI() {
    return Container(
        color: Color(0xFFF2F3F8),
        child: Center(child: Text("Database Updated")));
  }

  Future<bool> _onWillPop() async {
    flutterWebviewPlugin.hide();
    return showDialog<bool>(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Text(
                "Are you sure you want to quit?\nIt will not update Database."),
            title: Text("Warning!"),
            actions: <Widget>[
              FlatButton(
                child: Text("Yes"),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
              FlatButton(
                child: Text("No"),
                onPressed: () {
                  flutterWebviewPlugin.show();
                  Navigator.pop(context, false);
                },
              ),
            ],
          );
        });
  }
}
