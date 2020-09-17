import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:potaru/Model/task.model.dart';
import 'package:potaru/Model/timetable.model.dart';
import 'package:potaru/Model/todo.model.dart';
import 'package:potaru/UI/utils/curvePainter.dart';
import 'package:potaru/Controller/task.controller.dart';
import 'package:potaru/Controller/todo.controller.dart';
import 'package:potaru/Controller/semester.controller.dart';
import 'package:potaru/Controller/timetable.controller.dart';

class DashBoardTaskView extends StatelessWidget {
  final AnimationController animationController;
  final Animation animation;

  const DashBoardTaskView({Key key, this.animationController, this.animation})
      : super(key: key);

  Future<List<Task>> getTaskData() async {
    TodoController todoController = TodoController();
    TaskController taskController = TaskController();
    List<Task> tasksList = [];
    String now = DateFormat("yyyy-MM-dd").format(DateTime.now());
    List<Todo> todosList = await todoController.getTodoList(DateTime.now());
    if (todosList.length > 0) {
      await Future.forEach(todosList, (t) async {
        List<Task> _temptaskList =
            await taskController.getRecurringTaskList(t.tid, now);
        if (_temptaskList.length > 0) {
          tasksList.addAll(_temptaskList);
        } else if (t.recurring == 1 && _temptaskList.length == 0) {
          String _tempDate = await taskController.getLastTaskDateList(t.tid);
          if (_tempDate.isNotEmpty) {
            _temptaskList =
                await taskController.getRecurringTaskList(t.tid, _tempDate);
            await Future.forEach(_temptaskList, (t) async {
              t.date = now;
              t.completed = 0;
              await taskController.insertTask(t);
              tasksList.add(t);
            });
          }
        }
      });
    }

    return tasksList;
  }

  Future<List<Timetable>> getExamData() async {
    SemesterController semesterController = SemesterController();
    TimetableController timetableController = TimetableController();
    List<Map<String, String>> sem = await semesterController.getSemesterList();
    List<Timetable> exam = await timetableController
        .getNextExamData(sem.length > 0 ? sem[0]['startDate'] : '');
    return exam;
  }

  Future<List<Timetable>> getSubmissionData() async {
    SemesterController semesterController = SemesterController();
    TimetableController timetableController = TimetableController();
    List<Map<String, String>> sem = await semesterController.getSemesterList();
    List<Timetable> submission = await timetableController
        .getNextSubmissionData(sem.length > 0 ? sem[0]['startDate'] : '');
    return submission;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: animationController,
        builder: (BuildContext context, Widget child) {
          return FadeTransition(
              opacity: animation,
              child: Padding(
                  padding: const EdgeInsets.only(
                      left: 24, right: 24, top: 16, bottom: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          bottomLeft: Radius.circular(8.0),
                          bottomRight: Radius.circular(8.0),
                          topRight: Radius.circular(8.0)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            offset: Offset(1.1, 1.1),
                            blurRadius: 10.0),
                      ],
                    ),
                    child: Padding(
                        padding: const EdgeInsets.only(
                            top: 0, left: 16, right: 16, bottom: 15),
                        child: FutureBuilder(
                            future: Future.wait([
                              getTaskData(),
                              getExamData(),
                              getSubmissionData()
                            ]),
                            builder:
                                (context, AsyncSnapshot<List<List>> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasError) {
                                  print(snapshot.error);
                                  return Container(
                                      height: 200,
                                      child: Center(
                                        child: Text("Data Error",
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(43))),
                                      ));
                                } else {
                                  // Task
                                  int total = snapshot.data[0].length;
                                  int completed = snapshot.data[0]
                                      .where((t) => t.completed == 1)
                                      .length;
                                  int left = total - completed;
                                  double percent = 0.0;
                                  if (left == 0)
                                    percent = 1.0;
                                  else
                                    percent = completed / total;
                                  double anglePercent = percent;
                                  percent *= 100;

                                  // Exam
                                  String examDay;
                                  int examProgress;
                                  Map<String, dynamic> calcData =
                                      calculateDayAndProgress(snapshot.data[1]);
                                  examDay = calcData['dayLeft'];
                                  examProgress = calcData['progress'];

                                  // Submisson
                                  String submitDay;
                                  int submitProgress;
                                  calcData =
                                      calculateDayAndProgress(snapshot.data[2]);
                                  submitDay = calcData['dayLeft'];
                                  submitProgress = calcData['progress'];

                                  return FadeTransition(
                                      opacity: animation,
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: <Widget>[
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8,
                                                            right: 8,
                                                            top: 4,
                                                            bottom: 8),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  top: 15,
                                                                  left: 0,
                                                                  right: 0,
                                                                  bottom: 10),
                                                          child: Text(
                                                            "Today Dashboard",
                                                            style: TextStyle(
                                                                color: Colors
                                                                        .blueGrey[
                                                                    600],
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                letterSpacing:
                                                                    1.2),
                                                          ),
                                                        ),
                                                        Row(
                                                          children: <Widget>[
                                                            Container(
                                                              height: 35,
                                                              width: 2,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color:
                                                                    Colors.blue,
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            4.0)),
                                                              ),
                                                            ),
                                                            Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        15,
                                                                        8,
                                                                        8,
                                                                        8),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left: 8,
                                                                      bottom:
                                                                          2),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        'Completed',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontSize:
                                                                              ScreenUtil().setSp(32),
                                                                          letterSpacing:
                                                                              -0.1,
                                                                          color:
                                                                              Color(0xFF4A6572),
                                                                        ),
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceAround,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.end,
                                                                        children: <
                                                                            Widget>[
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(top: 3),
                                                                            child:
                                                                                SizedBox(
                                                                              width: 17,
                                                                              height: 17,
                                                                              child: Image.asset("assets/images/taskapp/task.png"),
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 15, bottom: 0),
                                                                            child:
                                                                                Text(
                                                                              '${(completed * animation.value).toInt()}',
                                                                              textAlign: TextAlign.center,
                                                                              style: TextStyle(
                                                                                fontWeight: FontWeight.w600,
                                                                                fontSize: ScreenUtil().setSp(35),
                                                                                color: Color(0xFF4A6572),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                )),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: <Widget>[
                                                            Container(
                                                              height: 35,
                                                              width: 2,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0xffF56E98),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            4.0)),
                                                              ),
                                                            ),
                                                            Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        15,
                                                                        8,
                                                                        8,
                                                                        8),
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left: 6,
                                                                      bottom:
                                                                          2),
                                                                  child: Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        'Under Progress',
                                                                        textAlign:
                                                                            TextAlign.center,
                                                                        style:
                                                                            TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          fontSize:
                                                                              ScreenUtil().setSp(32),
                                                                          letterSpacing:
                                                                              -0.1,
                                                                          color:
                                                                              Color(0xFF4A6572),
                                                                        ),
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.end,
                                                                        children: <
                                                                            Widget>[
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 4, top: 5),
                                                                            child:
                                                                                SizedBox(
                                                                              width: 17,
                                                                              height: 17,
                                                                              child: Image.asset("assets/images/taskapp/remain.png"),
                                                                            ),
                                                                          ),
                                                                          Padding(
                                                                            padding:
                                                                                const EdgeInsets.only(left: 15, top: 3),
                                                                            child:
                                                                                Text(
                                                                              '${((total - completed) * animation.value).toInt()}',
                                                                              textAlign: TextAlign.center,
                                                                              style: TextStyle(
                                                                                fontWeight: FontWeight.w600,
                                                                                fontSize: ScreenUtil().setSp(35),
                                                                                color: Color(0xFF4A6572),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                )),
                                                          ],
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 17, bottom: 5),
                                                  child: Center(
                                                    child: Stack(
                                                      overflow:
                                                          Overflow.visible,
                                                      children: <Widget>[
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(1.0),
                                                          child: Container(
                                                            width: 100,
                                                            height: 100,
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  Colors.white,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(
                                                                Radius.circular(
                                                                    100.0),
                                                              ),
                                                              border: Border.all(
                                                                  width: 15,
                                                                  color: Colors
                                                                      .blue[900]
                                                                      .withOpacity(
                                                                          0.2)),
                                                            ),
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  '${(percent * animation.value).toInt()}%',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    fontSize: ScreenUtil()
                                                                        .setSp(
                                                                            50),
                                                                    letterSpacing:
                                                                        0.0,
                                                                    color: Color(
                                                                        0xFF17262A),
                                                                  ),
                                                                ),
                                                                Text(
                                                                  'Completed',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize: ScreenUtil()
                                                                        .setSp(
                                                                            28),
                                                                    letterSpacing:
                                                                        0.0,
                                                                    color: Color(
                                                                        0xFF4A6572),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(2.0),
                                                          child: CustomPaint(
                                                            painter: CurvePainter(
                                                                colors: [
                                                                  Colors.blue[
                                                                      900],
                                                                  Colors.blue[
                                                                      400],
                                                                  Colors
                                                                      .blue[900]
                                                                ],
                                                                angle: (360 *
                                                                        (anglePercent >
                                                                                0.0
                                                                            ? anglePercent
                                                                            : 0.01)) +
                                                                    (0 - (360 * (anglePercent > 0.0 ? anglePercent : 0.01))) *
                                                                        (1.0 -
                                                                            animation.value)),
                                                            child: SizedBox(
                                                              width: 98,
                                                              height: 98,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8,
                                                  right: 8,
                                                  top: 4,
                                                  bottom: 8),
                                              child: Container(
                                                height: 2,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFF2F3F8),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(4.0)),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 14,
                                                  right: 14,
                                                  top: 3,
                                                  bottom: 0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: <Widget>[
                                                  Expanded(
                                                      child: Row(children: <
                                                          Widget>[
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(
                                                          'Submission',
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            fontSize:
                                                                ScreenUtil()
                                                                    .setSp(35),
                                                            letterSpacing: -0.2,
                                                            color: Color(
                                                                0xFF4A6572),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(top: 4),
                                                          child: Container(
                                                            height: 4,
                                                            width: 70,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .blue[100],
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          4.0)),
                                                            ),
                                                            child: Row(
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  width: ((submitProgress /
                                                                          1.45) *
                                                                      animation
                                                                          .value),
                                                                  height: 4,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    gradient:
                                                                        LinearGradient(
                                                                            colors: [
                                                                          Colors
                                                                              .blue[200],
                                                                          Colors
                                                                              .blue,
                                                                        ]),
                                                                    borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(4.0)),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10),
                                                      child: Text(
                                                        submitDay,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: ScreenUtil()
                                                              .setSp(35),
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                    ),
                                                  ])),
                                                  Expanded(
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: <Widget>[
                                                        Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Text(
                                                              'Exam',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize:
                                                                    ScreenUtil()
                                                                        .setSp(
                                                                            35),
                                                                letterSpacing:
                                                                    -0.2,
                                                                color: Color(
                                                                    0xFF4A6572),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 4),
                                                              child: Container(
                                                                height: 4,
                                                                width: 70,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                          .blue[
                                                                      100],
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              4.0)),
                                                                ),
                                                                child: Row(
                                                                  children: <
                                                                      Widget>[
                                                                    Container(
                                                                      width: ((examProgress /
                                                                              1.45) *
                                                                          animation
                                                                              .value),
                                                                      height: 4,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        gradient:
                                                                            LinearGradient(
                                                                                colors: [
                                                                              Colors.red[100],
                                                                              Colors.red,
                                                                            ]),
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(4.0)),
                                                                      ),
                                                                    )
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 10),
                                                          child: Text(
                                                            examDay,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize:
                                                                  ScreenUtil()
                                                                      .setSp(
                                                                          35),
                                                              color: Colors
                                                                  .grey[600],
                                                            ),
                                                          ),
                                                        ),
                                                      ])),
                                                ],
                                              ),
                                            ),
                                          ]));
                                }
                              } else {
                                return SizedBox(
                                    height: 200,
                                    child: Center(
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                          SizedBox(
                                              width: 35,
                                              height: 35,
                                              child:
                                                  CircularProgressIndicator())
                                        ])));
                              }
                            })),
                  )));
        });
  }

  Map<String, dynamic> calculateDayAndProgress(List<Timetable> data) {
    int progress = 0;
    String dayLeft = "None";
    if (data.length > 0) {
      DateTime courseDate = DateFormat('yyyy-MM-dd HH:mm')
          .parse(data[0].courseDate + " " + data[0].courseStartTime);
      int diff = courseDate.difference(DateTime.now()).inMinutes;
      int day = diff ~/ 60 ~/ 24;
      int hour = diff ~/ 60;
      int minute = diff % 60;
      if (hour < 168) progress = 100 - ((diff ~/ 60 / 168) * 100).toInt();
      if (day > 0)
        dayLeft = day.toString() + 'd ' + (hour % 24).toString() + 'h';
      else
        dayLeft = hour.toString() + 'h ' + minute.toString() + 'm';
    }
    return {"progress": progress, "dayLeft": dayLeft};
  }
}
