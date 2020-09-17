import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:potaru/Model/task.model.dart';
import 'package:potaru/Model/todo.model.dart';
import 'package:potaru/UI/Bar/appbar.dart';
import 'package:potaru/UI/Modules/Tasks/utils/taskFunc.dart';
import 'package:potaru/Controller/task.controller.dart';

class TaskDetails extends StatefulWidget {
  TaskDetails({Key key, this.todoData, this.taskData, this.selectedDate})
      : super(key: key);

  final Todo todoData;
  final List<Task> taskData;
  final DateTime selectedDate;

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<TaskDetails>
    with TickerProviderStateMixin {
  AnimationController animationBar;
  double barPercent = 0.0;
  double percentComplete = 0.0;
  Tween<double> animT;
  AnimationController scaleAnimation;
  List<String> taskDateList = [];
  Map<String, List<Task>> taskList = {};
  int displayDateRange = 0;
  int showingTask = 0;

  DateTime _now = DateTime.now();
  DateTime startDate;
  DateTime endDate;
  int diffDay;

  TaskController taskController = TaskController();

  @override
  void initState() {
    scaleAnimation = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1000),
        lowerBound: 0.0,
        upperBound: 1.0);

    if (widget.todoData.recurring == 0) {
      startDate = DateFormat("yyyy-MM-dd").parse(widget.todoData.startTime);
      endDate = DateFormat("yyyy-MM-dd").parse(widget.todoData.endTime);
      diffDay = endDate.difference(startDate).inDays;

      changeDateRange(displayDateRange);
    } else {
      recurringDate();
    }

    percentComplete = percentCalc(widget.taskData);
    barPercent = percentComplete;
    animationBar =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100))
          ..addListener(() {
            setState(() {
              barPercent = animT.transform(animationBar.value);
            });
          });

    animT = Tween<double>(begin: percentComplete, end: percentComplete);
    scaleAnimation.forward();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    animationBar.dispose();
    scaleAnimation.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget menu = PopupMenuButton(
      icon: Icon(
        Icons.more_vert,
        color: Colors.grey,
      ),
      itemBuilder: (context) => <PopupMenuEntry<int>>[
        PopupMenuItem(
          child: Text("3 Days",
              style: TextStyle(fontSize: ScreenUtil().setSp(40))),
          value: 0,
        ),
        PopupMenuItem(
          child: Text("1 Week",
              style: TextStyle(fontSize: ScreenUtil().setSp(40))),
          value: 1,
        ),
        PopupMenuItem(
          child:
              Text("All", style: TextStyle(fontSize: ScreenUtil().setSp(40))),
          value: 2,
        ),
      ],
      onSelected: (val) {
        changeDateRange(val);
      },
    );

    return Container(
        color: Colors.white,
        child: Scaffold(
          appBar: widget.todoData.recurring == 0
              ? subappBarMenu(context, "Task Details", 2, menu)
              : subappBar(context, "Task Details", 2),
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        showingTask.toString() +
                            " of " +
                            widget.taskData.length.toString() +
                            " Tasks",
                        style: TextStyle(fontSize: ScreenUtil().setSp(38)),
                        softWrap: false,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 15.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        widget.todoData.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: ScreenUtil().setSp(70)),
                        softWrap: false,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Material(
                        color: Colors.transparent,
                        child: widget.todoData.desc.isNotEmpty
                            ? Text(
                                widget.todoData.desc,
                                style:
                                    TextStyle(fontSize: ScreenUtil().setSp(40)),
                              )
                            : Text("No Description.")),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Material(
                      color: Colors.transparent,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: SizedBox(
                            height: 4,
                            child: LinearProgressIndicator(
                              value: barPercent,
                              backgroundColor: Colors.grey.withAlpha(50),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor),
                            ),
                          )),
                          Padding(
                            padding: EdgeInsets.only(left: 5.0),
                            child: Text(
                              (barPercent * 100).round().toString() + "%",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(40)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: taskDateList.length,
                        itemBuilder: (BuildContext ctxt, int index) {
                          if (taskList[taskDateList[index]].length == 0) {
                            return SizedBox();
                          } else {
                            String taskDate = DateFormat("EEEE, MMM d, yyyy")
                                .format(DateFormat("yyyy-MM-dd")
                                    .parse(taskDateList[index]));
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  taskDate,
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(41),
                                      fontWeight: FontWeight.w500),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                      taskList[taskDateList[index]].length,
                                      (taskIndex) {
                                    return Row(children: <Widget>[
                                      Container(
                                        width: 40.0,
                                        child: Checkbox(
                                          value: taskList[taskDateList[index]]
                                                      [taskIndex]
                                                  .completed ==
                                              1,
                                          onChanged: (val) async {
                                            taskList[taskDateList[index]]
                                                    [taskIndex]
                                                .completed = val ? 1 : 0;
                                            updateBarPercent();
                                            await updateDatabase(
                                                taskList[taskDateList[index]]
                                                    [taskIndex]);
                                          },
                                          activeColor:
                                              Theme.of(context).primaryColor,
                                        ),
                                      ),
                                      Text(
                                        taskList[taskDateList[index]][taskIndex]
                                            .task,
                                        style: TextStyle(
                                            fontSize: ScreenUtil().setSp(40)),
                                      )
                                    ]);
                                  }),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                              ],
                            );
                          }
                        }))
              ],
            ),
          ),
        ));
  }

  void changeDateRange(val) {
    displayDateRange = val;
    taskList.clear();
    taskDateList.clear();
    showingTask = 0;
    for (int i = 0; i <= diffDay; i++) {
      String _tempDate =
          DateFormat("yyyy-MM-dd").format(startDate.add(Duration(days: i)));
      DateTime curDate = DateFormat("yyyy-MM-dd").parse(_tempDate);
      if (displayDateRange == 0) {
        DateTime rangeStart = _now.subtract(Duration(days: 1));
        DateTime rangeEnd = _now.add(Duration(days: 1));
        if (curDate.isAfter(rangeStart) && curDate.isBefore(rangeEnd)) {
          taskDateList.add(_tempDate);
          taskList[_tempDate] = [];
        }
      } else if (displayDateRange == 1) {
        DateTime rangeStart = _now.subtract(Duration(days: 3));
        DateTime rangeEnd = _now.add(Duration(days: 3));
        if (curDate.isAfter(rangeStart) && curDate.isBefore(rangeEnd)) {
          taskDateList.add(_tempDate);
          taskList[_tempDate] = [];
        }
      } else {
        taskDateList.add(_tempDate);
        taskList[_tempDate] = [];
      }
    }

    taskList.entries.forEach((t) {
      taskList[t.key] = widget.taskData.where((d) => d.date == t.key).toList();
      showingTask += taskList[t.key].length;
    });
    setState(() {});
  }

  void recurringDate() {
    String _tempDate = DateFormat("yyyy-MM-dd").format(widget.selectedDate);
    taskDateList.add(_tempDate);
    taskList[_tempDate] = widget.taskData;
    showingTask = taskList[_tempDate].length;
  }

  void updateBarPercent() async {
    double newPercentComplete = percentCalc(widget.taskData);
    if (animationBar.status == AnimationStatus.forward ||
        animationBar.status == AnimationStatus.completed) {
      animT.begin = newPercentComplete;
      await animationBar.reverse();
    } else {
      animT.end = newPercentComplete;
      await animationBar.forward();
    }
    percentComplete = newPercentComplete;
  }

  Future<void> updateDatabase(Task taskData) async {
    await taskController.insertTask(taskData);
  }
}
