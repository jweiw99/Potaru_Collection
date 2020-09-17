import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:potaru/UI/Modules/StaffDirectory/staff_screen.dart';
import 'package:potaru/UI/Modules/Timetable/Widgets/addEvent.dart';
import 'package:potaru/Controller/timetable.controller.dart';
import 'package:potaru/Model/timetable.model.dart';
import 'package:potaru/Controller/staff.controller.dart';
import 'package:potaru/Model/staff.model.dart';
import 'package:potaru/Controller/attendance.controller.dart';
import 'package:potaru/UI/Modules/Timetable/utils/config.dart';
import 'package:potaru/UI/Modules/Timetable/utils/timetableToImage.dart';
import 'package:potaru/UI/utils/toastMsg.dart';

class EventListView extends StatefulWidget {
  const EventListView(
      {Key key, this.selectedDate, this.animationController, this.animation})
      : super(key: key);

  final AnimationController animationController;
  final Animation animation;
  final DateTime selectedDate;

  @override
  _EventListViewState createState() => _EventListViewState();
}

class _EventListViewState extends State<EventListView>
    with TickerProviderStateMixin {
  AnimationController animationController;
  CalendarController _calendarController;
  Animation<double> animation;

  TimetableController timetableController = TimetableController();
  AttendanceController attendanceController = AttendanceController();
  List<Timetable> timetable = [];

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _calendarController = CalendarController();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  Future<List<Timetable>> getData(DateTime date) async {
    String dateSelected = DateFormat("yyyy-MM-dd").format(date);
    timetable = await timetableController.getTimetableList(dateSelected);
    return timetable;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: widget.animationController,
        builder: (BuildContext context, Widget child) {
          return FadeTransition(
              opacity: widget.animation,
              child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 30 * (1.0 - widget.animation.value), 0.0),
                  child: FutureBuilder(
                      future: getData(widget.selectedDate),
                      builder:
                          (context, AsyncSnapshot<List<Timetable>> snapshot) {
                        //print(snapshot.error);
                        if (snapshot.hasError) {
                          return Container(
                              child: Padding(
                            padding: const EdgeInsets.only(top: 50.0),
                            child: Center(
                              child: Text("Data Error",
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(43))),
                            ),
                          ));
                        } else if (timetable.length == 0) {
                          return Container(
                              child: Padding(
                            padding: const EdgeInsets.only(top: 50.0),
                            child: Center(
                              child: Text("No Class",
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(43))),
                            ),
                          ));
                        } else {
                          return Container(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: BouncingScrollPhysics(),
                                  scrollDirection: Axis.vertical,
                                  itemCount: timetable.length,
                                  itemBuilder: (BuildContext ctxt, int index) {
                                    final Animation<double> animation =
                                        Tween<double>(begin: 0.0, end: 1.0)
                                            .animate(CurvedAnimation(
                                                parent: animationController,
                                                curve: Interval(
                                                    (1 / timetable.length) *
                                                        index,
                                                    1.0,
                                                    curve:
                                                        Curves.fastOutSlowIn)));
                                    animationController.forward();

                                    return EventsView(
                                      parent: this,
                                      timetableController: timetableController,
                                      attendanceController:
                                          attendanceController,
                                      timetableData: timetable,
                                      datetime: widget.selectedDate,
                                      index: index,
                                      animation: animation,
                                      animationController: animationController,
                                    );
                                  }));
                        }
                      })));
        });
  }
}

class EventsView extends StatelessWidget {
  const EventsView(
      {Key key,
      this.parent,
      this.timetableData,
      this.datetime,
      this.index,
      this.animationController,
      this.animation,
      this.timetableController,
      this.attendanceController})
      : super(key: key);

  final _EventListViewState parent;
  final List<Timetable> timetableData;
  final DateTime datetime;
  final int index;
  final AnimationController animationController;
  final Animation<dynamic> animation;
  final TimetableController timetableController;
  final AttendanceController attendanceController;

  Future<void> removeData(Timetable timetable) async {
    await timetableController.removeTimetableByPrimary(
      timetable.courseCode,
      timetable.courseType,
      timetable.courseDate,
      timetable.courseStartTime,
      timetable.startDate,
    );

    await attendanceController.removeAttendanceByKey(timetable.courseCode,
        timetable.courseType, timetable.courseDate, timetable.courseStartTime);

    this.parent.setState(() {});
  }

  Future<void> removeAllData(Timetable timetable) async {
    List<Timetable> deleteTimetable =
        await timetableController.getAllRecurringTimetable(
            timetable.courseCode,
            timetable.courseType,
            timetable.courseStartDate,
            timetable.courseStartTime,
            timetable.startDate,
            timetable.recurring);

    await timetableController.removeRecurringTimetable(
        timetable.courseCode,
        timetable.courseType,
        timetable.courseStartDate,
        timetable.courseStartTime,
        timetable.startDate,
        timetable.recurring);

    for (int i = 0; i < deleteTimetable.length; i++) {
      await attendanceController.removeAttendanceByKey(
          deleteTimetable[i].courseCode,
          deleteTimetable[i].courseType,
          deleteTimetable[i].courseDate,
          deleteTimetable[i].courseStartTime);
    }

    this.parent.setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ProgressDialog pr;
    pr = new ProgressDialog(context, showLogs: true);
    pr.style(message: 'Please wait...');

    Timetable timetable = timetableData[index];
    DateTime _now = DateTime.now();
    DateTime _startTime = DateFormat("yyyy-MM-dd HH:mm").parse(
        DateFormat("yyyy-MM-dd").format(datetime) +
            " " +
            timetable.courseStartTime);
    DateTime _endTime = DateFormat("yyyy-MM-dd HH:mm").parse(
        DateFormat("yyyy-MM-dd").format(datetime) +
            " " +
            timetable.courseEndTime);

    return AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget child) {
          return FadeTransition(
              opacity: animation,
              child: Transform(
                  transform: Matrix4.translationValues(
                      100 * (1.0 - animation.value), 0.0, 0.0),
                  child: Slidable(
                      actionPane: SlidableDrawerActionPane(),
                      actionExtentRatio: 0.25,
                      actions: <Widget>[
                        IconSlideAction(
                          iconWidget: CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.pink[400],
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 30,
                              )),
                          color: Colors.transparent,
                          onTap: () async {
                            int option = 0;
                            final bool confirm = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text("Delete Confirmation"),
                                  content: Text(
                                      "Are you sure you wish to delete this?\n" +
                                          "Event Info : \n" +
                                          timetable.courseName +
                                          "\n" +
                                          "Day : " +
                                          DateFormat("EEEE").format(datetime) +
                                          (timetable.recurring != "N"
                                              ? ("\n" +
                                                  "Recurring : " +
                                                  TimetableConfig.recType[
                                                      timetable.recurring])
                                              : "") +
                                          "\n" +
                                          "Type : " +
                                          TimetableConfig.courseType[
                                              timetable.courseType]),
                                  actions: <Widget>[
                                    timetable.recurring != "N"
                                        ? FlatButton(
                                            onPressed: () {
                                              option = 2;
                                              Navigator.of(context).pop(true);
                                            },
                                            child: const Text("Delete All"))
                                        : SizedBox(),
                                    FlatButton(
                                        onPressed: () {
                                          option = 1;
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text("Delete")),
                                    FlatButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text("Cancel"),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (confirm) {
                              await pr.show();
                              if (option == 1)
                                await removeData(timetable);
                              else
                                await removeAllData(timetable);

                              final prefs =
                                  await SharedPreferences.getInstance();
                              DateTime timetableDate =
                                  DateFormat("yyyy-MM-dd HH:mm").parse(
                                      timetable.courseDate +
                                          " " +
                                          timetable.courseStartTime);
                              if (prefs.getBool('setting_lockScreenImage')) {
                                /* await TimetableImage.startConvertImage(
                                    timetableDate); */
                                await pr.hide();
                              }
                            }
                          },
                        ),
                      ],
                      secondaryActions: <Widget>[
                        IconSlideAction(
                          iconWidget: CircleAvatar(
                              radius: 25,
                              backgroundColor:
                                  Theme.of(context).backgroundColor,
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 30,
                              )),
                          color: Colors.transparent,
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return AddEventScreen(
                                  action: "Modify",
                                  type: timetable.courseType,
                                  timetable: timetable,
                                  selectedDate: DateFormat("yyyy-MM-dd")
                                      .parse(timetable.courseDate),
                                  appBarTitle: TimetableConfig
                                      .courseType[timetable.courseType]);
                            }));
                          },
                        ),
                        IconSlideAction(
                          iconWidget: CircleAvatar(
                              radius: 25,
                              backgroundColor: timetable.lecturerID.isNotEmpty
                                  ? Colors.blue[400]
                                  : Colors.grey[700],
                              child: Icon(
                                Icons.contacts,
                                color: timetable.lecturerID.isNotEmpty
                                    ? Colors.white
                                    : Colors.grey,
                                size: 30,
                              )),
                          color: Colors.transparent,
                          onTap: () async {
                            if (timetable.lecturerID.isNotEmpty) {
                              List<Staff> staff = await StaffController()
                                  .getStaffByID(timetable.lecturerID);

                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return StaffScreen(
                                    animationController: animationController,
                                    staff: staff[0],
                                    appBarTitle: "Staff Info");
                              }));
                            } else {
                              ToastMsg.toToast("No Staff Info");
                            }
                          },
                        ),
                      ],
                      child: Padding(
                          padding: const EdgeInsets.only(left: 2.0, right: 2.0),
                          child: Card(
                              color: Colors.white,
                              elevation: 1.0,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 10.0, top: 10.0),
                                child: ListTile(
                                  leading: SizedBox(
                                      width: 90,
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              DateFormat("h:mm a")
                                                  .format(_startTime),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize:
                                                      ScreenUtil().setSp(40),
                                                  letterSpacing: 1.2,
                                                  color: (_now.isAfter(
                                                              _startTime) &&
                                                          _now.isBefore(
                                                              _endTime))
                                                      ? Colors.red
                                                      : Colors.blue),
                                            ),
                                            Text(
                                              DateFormat("h:mm a")
                                                  .format(_endTime),
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(38)),
                                            ),
                                            Text(
                                              timetable.courseVenue,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize:
                                                      ScreenUtil().setSp(40),
                                                  letterSpacing: 1.2,
                                                  color: Colors.blue),
                                            )
                                          ])),
                                  subtitle: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                            timetable.courseCode +
                                                (timetable.courseCode == ""
                                                    ? ""
                                                    : "\n") +
                                                timetable.courseName,
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(38),
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1.2)),
                                        Text(
                                          timetable.lecturerName.isNotEmpty
                                              ? timetable.lecturerName
                                              : '-',
                                          style: TextStyle(
                                              fontSize: ScreenUtil().setSp(36)),
                                        ),
                                        Text(
                                          getCourseTypeDisplay(timetable),
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: ScreenUtil().setSp(36),
                                              color: getCourseTypeColor(
                                                  timetable)),
                                        ),
                                      ]),
                                  onLongPress: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return AddEventScreen(
                                          action: "Modify",
                                          type: timetable.courseType,
                                          timetable: timetable,
                                          selectedDate: DateFormat("yyyy-MM-dd")
                                              .parse(timetable.courseDate),
                                          appBarTitle:
                                              TimetableConfig.courseType[
                                                  timetable.courseType]);
                                    }));
                                  },
                                ),
                              ))))));
        });
  }

  String getCourseTypeDisplay(Timetable timetable) {
    String display = "";
    if (['L', 'P', 'T'].contains(timetable.courseType))
      display = timetable.courseType + timetable.courseGroup.toString();
    else
      display = TimetableConfig.courseType[timetable.courseType];
    return display;
  }

  Color getCourseTypeColor(Timetable timetable) {
    Color color;
    if (['L', 'P', 'T'].contains(timetable.courseType))
      color = Colors.grey;
    else if (timetable.courseType == "E")
      color = Colors.red;
    else
      color = Colors.blue;
    return color;
  }
}
