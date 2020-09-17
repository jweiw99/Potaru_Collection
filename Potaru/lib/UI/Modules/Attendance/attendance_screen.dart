import 'package:dropdown_menu/dropdown_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:potaru/UI/Bar/appbar.dart';
import 'package:potaru/Controller/timetable.controller.dart';
import 'package:potaru/Controller/attendance.controller.dart';
import 'package:potaru/Controller/semester.controller.dart';
import 'package:potaru/Model/attendance.model.dart';
import 'package:potaru/Model/subject.model.dart';
import 'package:potaru/UI/Modules/Attendance/subject_attend_details.dart';
import 'package:potaru/UI/utils/customeRoute.dart';
import 'package:potaru/UI/utils/errorMsg.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key key, this.animationController, this.animation})
      : super(key: key);

  final AnimationController animationController;
  final Animation animation;
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<Map<String, String>> semester = [];
  List<Subject> subject = [];
  int semesterINDEX = 0;
  List<String> attendText = ["√", "L", "X"];

  Map<String, int> attendWeekCount = {};

  Map<String, String> updateStatus = {
    "0": "Not Started",
    "1": "Outdated",
    "2": "Updated"
  };

  SemesterController semesterController = SemesterController();
  TimetableController timetableController = TimetableController();
  AttendanceController attendanceController = AttendanceController();

  @override
  void initState() {
    widget.animationController.forward(from: 0.0);
    super.initState();
  }

  Future<List<Map<String, String>>> getData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('setting_attendShortSem') == null) {
      await prefs.setInt('setting_attendShortSem', 5);
      await prefs.setInt('setting_attendLongSem', 12);
    }
    attendWeekCount = {
      "14": prefs.getInt('setting_attendLongSem'),
      "7": prefs.getInt('setting_attendShortSem')
    };

    semester = semester.length == 0
        ? await semesterController.getSemesterList()
        : semester;
    if (semester.length > 0)
      subject = subject.length == 0
          ? await timetableController
              .getCurSemSubjectList(semester[0]['startDate'])
          : subject;
    return semester;
  }

  Future<List<Attendance>> getAttendData(String courseCode) async {
    final List<Attendance> attendance = await attendanceController
        .getAttendanceCodeList(semester[semesterINDEX]['code'], courseCode);

    if (attendance.length == 0) {
      attendance.add(Attendance(semester[semesterINDEX]['code'], courseCode, "",
          semester[semesterINDEX]['startDate'], "00:00", ""));
    }

    return attendance;
  }

  DropdownHeader buildDropdownHeader({DropdownMenuHeadTapCallback onTap}) {
    return DropdownHeader(onTap: onTap, titles: [semester[semesterINDEX]]);
  }

  DropdownMenu buildDropdownMenu() {
    return DropdownMenu(maxMenuHeight: kDropdownMenuItemHeight * 6, menus: [
      DropdownMenuBuilder(
          builder: (BuildContext context) {
            return DropdownListMenu(
                selectedIndex: semesterINDEX,
                data: semester,
                itemBuilder:
                    (BuildContext context, dynamic data, bool selected) {
                  if (!selected) {
                    return DecoratedBox(
                        decoration: BoxDecoration(
                            border: Border(
                                right: Divider.createBorderSide(context))),
                        child: Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Row(
                              children: <Widget>[
                                Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.90,
                                    child: Text(data['title'])),
                              ],
                            )));
                  } else {
                    return DecoratedBox(
                        decoration: BoxDecoration(
                            border: Border(
                                top: Divider.createBorderSide(context),
                                bottom: Divider.createBorderSide(context))),
                        child: Container(
                            color: Colors.blue[50],
                            child: Row(
                              children: <Widget>[
                                Container(
                                    color: Theme.of(context).primaryColor,
                                    width: 3.0,
                                    height: 20.0),
                                Padding(
                                    padding: EdgeInsets.only(left: 12.0),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.90,
                                        child: Text(data['title']))),
                              ],
                            )));
                  }
                });
          },
          height: kDropdownMenuItemHeight * semester.length),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF2F3F8),
      child: Scaffold(
          appBar: subappbarWithdropdown(context, 'Attendance'),
          backgroundColor: Colors.transparent,
          body: FutureBuilder<List>(
              future: getData(),
              builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    //print(snapshot.error);
                    return SizedBox(
                        child: Center(
                            child: Text("Data Error",
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(43)))));
                  } else if (semester.length == 0 || subject.length == 0) {
                    ErrorMsg.attendanceNotFoundMsg();
                    return SizedBox(
                        child: Center(
                            child: Text("No Data",
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(43)))));
                  } else {
                    return DefaultDropdownMenuController(
                        onSelected: (
                            {int menuIndex,
                            int index,
                            int subIndex,
                            dynamic data}) {
                          if (semesterINDEX != index) {
                            onSemesterChanged(index);
                          }
                        },
                        child: Stack(
                          children: <Widget>[
                            Transform(
                                transform:
                                    Matrix4.translationValues(0.0, 35, 0.0),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              15, 20, 10, 5),
                                          child: Text("Subject",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 1.2,
                                                  fontSize: 16))),
                                      Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              15, 0, 10, 5),
                                          child: Text(
                                              "Press or Swipe left to have more option\n" +
                                                  "Please leave some quota to prevent cancellation of future class",
                                              style:
                                                  TextStyle(fontSize: 12.5))),
                                      Expanded(
                                          child: _buildSubjectList(subject))
                                    ])),
                            Transform(
                                transform:
                                    Matrix4.translationValues(0.0, 35, 0.0),
                                child: buildDropdownMenu()),
                            Transform(
                              transform:
                                  Matrix4.translationValues(0.0, -15.0, 0.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(32.0),
                                  ),
                                  boxShadow: <BoxShadow>[
                                    BoxShadow(
                                        color: Colors.grey,
                                        offset: const Offset(1.1, 1.1),
                                        blurRadius: 10.0),
                                  ],
                                ),
                                child: buildDropdownHeader(),
                              ),
                            ),
                          ],
                        ));
                  }
                } else {
                  return Center(
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                        SizedBox(
                            width: 35,
                            height: 35,
                            child: CircularProgressIndicator())
                      ]));
                }
              })),
    );
  }

  Widget _buildSubjectList(List<Subject> subjectData) {
    return AnimatedBuilder(
        animation: widget.animationController,
        builder: (BuildContext context, Widget child) {
          return FadeTransition(
              opacity: widget.animation,
              child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 30 * (1.0 - widget.animation.value), 0.0),
                  child: ListView.builder(
                      padding: EdgeInsets.only(top: 10, bottom: 100),
                      physics: BouncingScrollPhysics(),
                      itemCount: subjectData.length,
                      itemBuilder: (BuildContext ctxt, int index) {
                        return FutureBuilder(
                            future:
                                getAttendData(subjectData[index].courseCode),
                            builder: (context,
                                AsyncSnapshot<List<Attendance>> attendance) {
                              if (attendance.connectionState ==
                                  ConnectionState.done) {
                                if (attendance.hasError) {
                                  //print(snapshot.error);
                                  return const SizedBox();
                                } else {
                                  return FutureBuilder(
                                      future: calcAttendRate(
                                          subjectData[index], attendance.data),
                                      builder: (context,
                                          AsyncSnapshot<Map<String, String>>
                                              attendRate) {
                                        if (attendRate.connectionState ==
                                            ConnectionState.done) {
                                          if (attendRate.hasError) {
                                            //print(attendRate.error);
                                            return const SizedBox();
                                          } else {
                                            Color warningClr;
                                            if (attendRate.data['color'] == "0")
                                              warningClr = Colors.blue;
                                            else if (attendRate.data['color'] ==
                                                "1")
                                              warningClr = Colors.yellow[900];
                                            else
                                              warningClr = Colors.red;

                                            return Slidable(
                                                actionPane:
                                                    SlidableDrawerActionPane(),
                                                actionExtentRatio: 0.25,
                                                secondaryActions: <Widget>[
                                                  IconSlideAction(
                                                    iconWidget: CircleAvatar(
                                                        radius: 25,
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .buttonColor,
                                                        child: Icon(
                                                          Icons.edit,
                                                          color: Colors.white,
                                                          size: 30,
                                                        )),
                                                    color: Colors.transparent,
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MyCustomRoute(StuAttendanceScreen(
                                                              animationController:
                                                                  widget
                                                                      .animationController,
                                                              animation: widget
                                                                  .animation,
                                                              appBarTitle:
                                                                  subjectData[
                                                                          index]
                                                                      .courseCode,
                                                              semester: semester[
                                                                  semesterINDEX],
                                                              attendWeekCount:
                                                                  attendWeekCount,
                                                              attendance:
                                                                  attendance
                                                                      .data,
                                                              subject:
                                                                  subjectData[
                                                                      index])));
                                                    },
                                                  )
                                                ],
                                                child: Card(
                                                    color: Colors.white,
                                                    elevation: 1.0,
                                                    child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                bottom: 10.0,
                                                                top: 10.0),
                                                        child: ListTile(
                                                          leading: SizedBox(
                                                            width: 90,
                                                            child: Center(
                                                                child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: <
                                                                        Widget>[
                                                                  Text(
                                                                      attendRate.data['Updated'] ==
                                                                              "2"
                                                                          ? '${(int.parse(attendRate.data['percent']) * widget.animation.value).toInt()}'
                                                                          : '0',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w700,
                                                                        fontSize:
                                                                            40,
                                                                        letterSpacing:
                                                                            1.2,
                                                                        color:
                                                                            warningClr,
                                                                      )),
                                                                  Text(
                                                                    '%',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          20,
                                                                      letterSpacing:
                                                                          1.2,
                                                                      color:
                                                                          warningClr,
                                                                    ),
                                                                  ),
                                                                ])),
                                                          ),
                                                          subtitle: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                    subjectData[index]
                                                                            .courseCode +
                                                                        (subjectData[index].courseCode == ""
                                                                            ? ""
                                                                            : "\n") +
                                                                        subjectData[index]
                                                                            .courseName,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            ScreenUtil().setSp(
                                                                                35),
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w700,
                                                                        letterSpacing:
                                                                            1.2)),
                                                                Container(
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    padding: EdgeInsets.symmetric(
                                                                        vertical:
                                                                            5.0,
                                                                        horizontal:
                                                                            10.0),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color:
                                                                          warningClr,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5),
                                                                    ),
                                                                    child: Text(
                                                                      "Quota Left : ${attendRate.data['HoursLeft']} Hours",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              ScreenUtil().setSp(32)),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    )),
                                                                Text(
                                                                    'Status : ' +
                                                                        updateStatus[attendRate.data[
                                                                            'Updated']],
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          ScreenUtil()
                                                                              .setSp(35),
                                                                      color: attendRate.data['Updated'] ==
                                                                              "2"
                                                                          ? Color(
                                                                              0xFF777777)
                                                                          : Colors
                                                                              .red,
                                                                    ))
                                                              ]),
                                                          onTap: () {
                                                            Navigator.push(
                                                                context,
                                                                MyCustomRoute(StuAttendanceScreen(
                                                                    animationController:
                                                                        widget
                                                                            .animationController,
                                                                    animation:
                                                                        widget
                                                                            .animation,
                                                                    appBarTitle:
                                                                        subjectData[index]
                                                                            .courseCode,
                                                                    semester: semester[
                                                                        semesterINDEX],
                                                                    attendWeekCount:
                                                                        attendWeekCount,
                                                                    attendance:
                                                                        attendance
                                                                            .data,
                                                                    subject:
                                                                        subjectData[
                                                                            index])));
                                                          },
                                                        ))));
                                          }
                                        } else {
                                          return Center(
                                              child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                SizedBox(
                                                    width: 35,
                                                    height: 35,
                                                    child:
                                                        CircularProgressIndicator())
                                              ]));
                                        }
                                      });
                                }
                              } else {
                                return Card(
                                    color: Colors.white,
                                    elevation: 1.0,
                                    child: Padding(
                                        padding: const EdgeInsets.all(30),
                                        child: Center(
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                              SizedBox(
                                                  width: 55,
                                                  height: 55,
                                                  child:
                                                      CircularProgressIndicator())
                                            ]))));
                              }
                            });
                      })));
        });
  }

  onSemesterChanged(int index) async {
    semesterINDEX = index;
    if (semester[index]['startDate'] != "") {
      subject = await timetableController
          .getCurSemSubjectList(semester[index]['startDate']);
    } else {
      subject.clear();
      ErrorMsg.classAttendanceNotFoundMsg();
    }
    setState(() {});
  }

  Future<Map<String, String>> calcAttendRate(
      Subject subject, List<Attendance> attendance) async {
    String totalweek = semester[semesterINDEX]['totalWeek'];

    String update = "2";
    String color = "0";

    double totalcourseHrs = 0.0;
    double _totalcourseHrs = 0.0;
    DateTime today = DateTime.now();

    DateTime startDate =
        DateFormat("yyyy-MM-dd").parse(semester[semesterINDEX]['startDate']);

    if (!today.isAfter(startDate))
      update = "0";
    else {
      int week = 1;
      for (SubTypeHrs sub in subject.subTypeHrs) {
        DateTime newWeekDate = DateFormat("yyyy-MM-dd").parse(sub.courseDate);

        if (startDate.difference(newWeekDate).inDays.abs() >= 7) {
          week++;
          startDate = startDate.add(Duration(days: 7));
        }

        if (week <= attendWeekCount[totalweek]) {
          _totalcourseHrs += sub.courseHrs;
        } else {
          totalcourseHrs = _totalcourseHrs;
          break;
        }
      }

      week = 1;
      startDate =
          DateFormat("yyyy-MM-dd").parse(semester[semesterINDEX]['startDate']);
      for (SubTypeHrs sub in subject.subTypeHrs) {
        if (update == "2") {
          DateTime newWeekDate = DateFormat("yyyy-MM-dd").parse(sub.courseDate);

          if (startDate.difference(newWeekDate).inDays.abs() >= 7) {
            week++;
            startDate = startDate.add(Duration(days: 7));
          }

          List<Attendance> subAttend = attendance
              .where((attendSub) =>
                  attendSub.courseType == sub.courseType &&
                  attendSub.courseDate == sub.courseDate &&
                  attendSub.courseStartTime == sub.courseStartTime &&
                  !attendSub.attendance.contains(" "))
              .toList();

          DateTime _endTime = DateFormat("yyyy-MM-dd HH:mm")
              .parse(sub.courseDate + " " + sub.courseEndTime);

          if (_endTime.isAfter(today) || week > attendWeekCount[totalweek]) {
            break;
          } else if (subAttend.length == 0) {
            update = "1";
            break;
          }

          for (Attendance att in subAttend) {
            if (att.attendance.contains("X")) {
              _totalcourseHrs -= sub.courseHrs;
            } else if (!attendText.contains(att.attendance)) {
              update = "1";
              break;
            }
          }
        }
      }
    }

    int percent = ((_totalcourseHrs / totalcourseHrs) * 100).floor();
    int hoursLeft =
        ((totalcourseHrs * 0.2) - (totalcourseHrs - _totalcourseHrs)).floor();
    if (hoursLeft < 0) hoursLeft = 0;

    if (percent < 80) {
      color = "2";
    } else if (percent <= 85 && percent >= 80) {
      color = "1";
    }

    return {
      "percent": percent.toString(),
      "HoursLeft": update == "2" ? hoursLeft.toString() : "0",
      "Updated": update,
      "color": color
    };
  }
}
