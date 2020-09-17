import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:potaru/Controller/attendance.controller.dart';
import 'package:potaru/Model/attendance.model.dart';
import 'package:potaru/Model/subject.model.dart';
import 'package:potaru/Model/timetable.model.dart';

import 'package:potaru/UI/Bar/appbar.dart';
import 'package:potaru/UI/utils/toastMsg.dart';

class StuAttendanceScreen extends StatefulWidget {
  const StuAttendanceScreen(
      {Key key,
      this.animationController,
      this.animation,
      this.appBarTitle,
      this.semester,
      this.attendWeekCount,
      this.attendance,
      this.subject})
      : super(key: key);

  final AnimationController animationController;
  final Animation animation;
  final String appBarTitle;
  final Map<String, String> semester;
  final Map<String, int> attendWeekCount;
  final List<Attendance> attendance;
  final Subject subject;

  @override
  _StuAttendanceScreenState createState() => _StuAttendanceScreenState();
}

class _StuAttendanceScreenState extends State<StuAttendanceScreen> {
  List<Timetable> timetable = [];
  Map<String, AttendModel> attendList = {};

  DateTime today = DateTime.now();

  AttendanceController attendanceController = AttendanceController();

  final Map<String, String> _courseType = {
    "L": "Lecturer",
    "T": "Tutorial",
    "P": "Practical",
  };

  final List<RadioModel> radioText = [
    RadioModel(false, "√"),
    RadioModel(false, "L"),
    RadioModel(false, "X")
  ];

  @override
  void initState() {
    for (int j = 0; j < widget.subject.subTypeHrs.length; j++) {
      attendList[widget.subject.subTypeHrs[j].courseType +
              widget.subject.subTypeHrs[j].courseDate +
              widget.subject.subTypeHrs[j].courseStartTime] =
          AttendModel(
              widget.subject.subTypeHrs[j].courseType,
              widget.subject.subTypeHrs[j].courseDate,
              widget.subject.subTypeHrs[j].courseStartTime,
              RadioModel(false, " "));
    }

    for (int i = 0; i < widget.attendance.length; i++) {
      if (widget.attendance[i].attendance == radioText[0].buttonText ||
          widget.attendance[i].attendance == radioText[1].buttonText ||
          widget.attendance[i].attendance == radioText[2].buttonText) {
        if (attendList.containsKey(widget.attendance[i].courseType +
            widget.attendance[i].courseDate +
            widget.attendance[i].courseStartTime)) {
          attendList[widget.attendance[i].courseType +
                  widget.attendance[i].courseDate +
                  widget.attendance[i].courseStartTime]
              .radioModel
              .buttonText = widget.attendance[i].attendance;
          attendList[widget.attendance[i].courseType +
                  widget.attendance[i].courseDate +
                  widget.attendance[i].courseStartTime]
              .radioModel
              .isSelected = true;
        }
      }
    }

    super.initState();
  }

  Future<bool> saveAttendance(AttendModel attendData) async {
    await attendanceController.insertAttendance(Attendance(
        widget.semester['code'],
        widget.subject.courseCode,
        attendData.courseType,
        attendData.courseDate,
        attendData.courseStartTime,
        attendData.radioModel.buttonText));
    ToastMsg.toToastBottom("Saved");
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color(0xFFF2F3F8),
        child: Scaffold(
            appBar: subappBar(context, widget.appBarTitle, 2),
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Container(
                    child: Column(
                  children: <Widget>[
                    Column(
                      children: courseList(),
                    )
                  ],
                )))));
  }

  List<Widget> courseList() {
    DateTime weekDate =
        DateFormat("yyyy-MM-dd").parse(widget.semester['startDate']);
    int weekno = 1;

    return List.generate(widget.subject.subTypeHrs.length, (subIndex) {
      bool newWeek = false;
      if (subIndex == 0) newWeek = true;
      String courseType = widget.subject.subTypeHrs[subIndex].courseType;
      String courseDate = widget.subject.subTypeHrs[subIndex].courseDate;
      String courseStartTime =
          widget.subject.subTypeHrs[subIndex].courseStartTime;

      DateTime newWeekDate = DateFormat("yyyy-MM-dd").parse(courseDate);

      DateTime _startTime = DateFormat("yyyy-MM-dd HH:mm").parse(courseDate +
          " " +
          widget.subject.subTypeHrs[subIndex].courseStartTime);

      DateTime _endTime = DateFormat("yyyy-MM-dd HH:mm").parse(
          courseDate + " " + widget.subject.subTypeHrs[subIndex].courseEndTime);

      if (weekDate.difference(newWeekDate).inDays.abs() >= 7) {
        weekno++;
        weekDate = weekDate.add(Duration(days: 7));
        newWeek = true;
      }

      if (_endTime.isAfter(today) ||
          widget.attendWeekCount[widget.semester['totalWeek']] < weekno) {
        return SizedBox();
      } else {
        return Column(children: <Widget>[
          newWeek
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 5, 10),
                  child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Week " + weekno.toString(),
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(45),
                            fontWeight: FontWeight.w700,
                            color: Colors.blueGrey[700]),
                      )))
              : SizedBox(),
          Card(
              child: ListTile(
                  isThreeLine: true,
                  title: Text(
                    _courseType[courseType] +
                        " (" +
                        DateFormat("EEEE").format(_startTime) +
                        ")",
                    style: TextStyle(
                        letterSpacing: 1.2, fontSize: ScreenUtil().setSp(38)),
                  ),
                  subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                DateFormat("h:mm a").format(_startTime),
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: ScreenUtil().setSp(38),
                                    letterSpacing: 1.2,
                                    color: Colors.blue),
                              ),
                              Text(" - "),
                              Text(
                                DateFormat("h:mm a").format(_endTime),
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: ScreenUtil().setSp(38),
                                    letterSpacing: 1.2,
                                    color: Colors.blue),
                              ),
                            ]),
                        SizedBox(
                          height: 3,
                        ),
                        Text(
                          DateFormat("dd.MM.yyyy").format(_startTime) +
                              " (" +
                              widget.subject.subTypeHrs[subIndex].courseHrs
                                  .toString() +
                              "Hrs)",
                          style: TextStyle(
                            letterSpacing: 1.2,
                            fontSize: ScreenUtil().setSp(38),
                          ),
                        ),
                      ]),
                  trailing: SizedBox(
                    width: 140,
                    child: Center(
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: buttonList(
                                courseType, courseDate, courseStartTime))),
                  )))
        ]);
      }
    });
  }

  List<Widget> buttonList(
      String courseType, String courseDate, String courseStartTime) {
    return List.generate(radioText.length, (buttonIndex) {
      return InkWell(
          onTap: () {
            setState(() {
              if (attendList[courseType + courseDate + courseStartTime]
                      .radioModel
                      .isSelected &&
                  attendList[courseType + courseDate + courseStartTime]
                          .radioModel
                          .buttonText ==
                      radioText[buttonIndex].buttonText) {
                attendList[courseType + courseDate + courseStartTime]
                    .radioModel
                    .buttonText = " ";
                attendList[courseType + courseDate + courseStartTime]
                    .radioModel
                    .isSelected = false;
              } else {
                attendList[courseType + courseDate + courseStartTime]
                    .radioModel
                    .buttonText = radioText[buttonIndex].buttonText;
                attendList[courseType + courseDate + courseStartTime]
                    .radioModel
                    .isSelected = true;
              }
              saveAttendance(
                  attendList[courseType + courseDate + courseStartTime]);
            });
          },
          child: Container(
            height: 35.0,
            width: 35.0,
            child: Center(
              child: Text(radioText[buttonIndex].buttonText,
                  style: TextStyle(
                      color: _onchangeButtonTextColor(
                          courseType, courseDate, courseStartTime, buttonIndex),
                      //fontWeight: FontWeight.bold,
                      fontSize: ScreenUtil().setSp(38))),
            ),
            decoration: BoxDecoration(
              color: _onchangeButtonColor(
                  courseType, courseDate, courseStartTime, buttonIndex),
              border: Border.all(
                  width: 2.0,
                  color: _onchangeButtonBorderColor(
                      courseType, courseDate, courseStartTime, buttonIndex)),
              borderRadius: const BorderRadius.all(const Radius.circular(2.0)),
            ),
          ));
    });
  }

  Color _onchangeButtonTextColor(String courseType, String courseDate,
      String courseStartTime, int buttonIndex) {
    if (attendList[courseType + courseDate + courseStartTime]
            .radioModel
            .buttonText ==
        radioText[buttonIndex].buttonText) {
      if (attendList[courseType + courseDate + courseStartTime]
          .radioModel
          .isSelected) {
        return Colors.white;
      }
    }
    return Colors.grey[700];
  }

  Color _onchangeButtonColor(String courseType, String courseDate,
      String courseStartTime, int buttonIndex) {
    if (attendList[courseType + courseDate + courseStartTime]
            .radioModel
            .buttonText ==
        radioText[buttonIndex].buttonText) {
      if (attendList[courseType + courseDate + courseStartTime]
          .radioModel
          .isSelected) {
        if (radioText[buttonIndex].buttonText != radioText[2].buttonText) {
          return Colors.blue;
        }
        return Colors.red;
      }
    }
    return Colors.transparent;
  }

  Color _onchangeButtonBorderColor(String courseType, String courseDate,
      String courseStartTime, int buttonIndex) {
    if (attendList[courseType + courseDate + courseStartTime]
            .radioModel
            .buttonText ==
        radioText[buttonIndex].buttonText) {
      if (attendList[courseType + courseDate + courseStartTime]
          .radioModel
          .isSelected) {
        if (radioText[buttonIndex].buttonText != radioText[2].buttonText) {
          return Colors.blue;
        }
        return Colors.red;
      }
    }
    return Colors.grey[300];
  }
}

class RadioModel {
  bool isSelected;
  String buttonText;

  RadioModel(this.isSelected, this.buttonText);
}

class AttendModel {
  String courseType;
  String courseDate;
  String courseStartTime;
  RadioModel radioModel;

  AttendModel(
      this.courseType, this.courseDate, this.courseStartTime, this.radioModel);
}
