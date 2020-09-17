import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:potaru/UI/Modules/Tasks/Widgets/taskDetails.dart';
import 'package:potaru/UI/utils/customeRoute.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'package:potaru/UI/Modules/Tasks/Widgets/addTodo.dart';
import 'package:potaru/Controller/todo.controller.dart';
import 'package:potaru/Model/todo.model.dart';
import 'package:potaru/Controller/task.controller.dart';
import 'package:potaru/Model/task.model.dart';
import 'package:potaru/UI/Modules/Tasks/Widgets/addTask.dart';
import 'package:potaru/UI/Modules/Tasks/utils/taskFunc.dart';

class TasksListView extends StatefulWidget {
  const TasksListView(
      {Key key, this.selectedDate, this.animationController, this.animation})
      : super(key: key);

  final AnimationController animationController;
  final Animation animation;
  final DateTime selectedDate;

  @override
  _TasksListViewState createState() => _TasksListViewState();
}

class _TasksListViewState extends State<TasksListView>
    with TickerProviderStateMixin {
  AnimationController animationController;
  CalendarController _calendarController;
  Animation<double> animation;

  List<Todo> tasksList = [];
  TodoController todoController = TodoController();
  TaskController taskController = TaskController();

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

  Future<List<Todo>> getData(DateTime date) async {
    tasksList = await todoController.getTodoList(date);
    return tasksList;
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
                builder: (context, AsyncSnapshot<List<Todo>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.hasError) {
                      return Container(
                          child: Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Center(
                          child: Text("Data Error",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(43))),
                        ),
                      ));
                    } else if (tasksList.length == 0) {
                      return Container(
                          child: Padding(
                        padding: const EdgeInsets.only(top: 50.0),
                        child: Center(
                          child: Text("No Task",
                              style:
                                  TextStyle(fontSize: ScreenUtil().setSp(43))),
                        ),
                      ));
                    } else {
                      return Container(
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              itemCount: tasksList.length,
                              itemBuilder: (BuildContext ctxt, int index) {
                                final Animation<double> animation =
                                    Tween<double>(begin: 0.0, end: 1.0).animate(
                                        CurvedAnimation(
                                            parent: animationController,
                                            curve: Interval(
                                                (1 / tasksList.length) * index,
                                                1.0,
                                                curve: Curves.fastOutSlowIn)));
                                animationController.forward();

                                return TasksView(
                                    todoData: tasksList[index],
                                    animationController: animationController,
                                    animation: animation,
                                    parent: this,
                                    selectedDate: widget.selectedDate,
                                    todoController: todoController,
                                    taskController: taskController);
                              }));
                    }
                  } else {
                    return SizedBox(
                        height: 100,
                        child: Center(
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                              SizedBox(
                                  width: 35,
                                  height: 35,
                                  child: CircularProgressIndicator())
                            ])));
                  }
                }),
          ),
        );
      },
    );
  }
}

class TasksView extends StatefulWidget {
  const TasksView(
      {Key key,
      this.todoData,
      this.parent,
      this.animationController,
      this.animation,
      this.selectedDate,
      this.todoController,
      this.taskController})
      : super(key: key);

  final _TasksListViewState parent;
  final Todo todoData;
  final AnimationController animationController;
  final Animation<dynamic> animation;
  final DateTime selectedDate;
  final TodoController todoController;
  final TaskController taskController;

  @override
  _TasksViewState createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  List<Task> taskList = [];

  Future<List<Task>> getData() async {
    if (widget.todoData.recurring == 0) {
      taskList = await widget.taskController.getTaskList(widget.todoData.tid);
    } else {
      String taskDate = DateFormat("yyyy-MM-dd").format(widget.selectedDate);
      taskList = await widget.taskController
          .getRecurringTaskList(widget.todoData.tid, taskDate);
      if (taskList.length == 0) {
        String _tempDate = await widget.taskController
            .getLastTaskDateList(widget.todoData.tid);
        if (_tempDate.isNotEmpty) {
          taskList = await widget.taskController
              .getRecurringTaskList(widget.todoData.tid, _tempDate);
          await Future.forEach(taskList, (t) async {
            t.date = taskDate;
            t.completed = 0;
            await widget.taskController.insertTask(t);
          });
        }
      }
    }
    return taskList;
  }

  @override
  void initState() {
    widget.animationController.forward(from: 0.0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime _today = DateFormat("yyyy-MM-dd")
        .parse(DateFormat("yyyy-MM-dd").format(widget.selectedDate));
    DateTime _startTime =
        DateFormat("yyyy-MM-dd HH:mm").parse(widget.todoData.startTime);
    DateTime _endTime;
    if (widget.todoData.recurring == 0)
      _endTime = DateFormat("yyyy-MM-dd HH:mm").parse(widget.todoData.endTime);
    else
      _endTime = widget.selectedDate;
    DateTime _endDate = DateFormat("yyyy-MM-dd")
        .parse(DateFormat("yyyy-MM-dd").format(_endTime));

    return FutureBuilder(
        future: getData(),
        builder: (context, AsyncSnapshot<List<Task>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Container(
                  child: Padding(
                padding: const EdgeInsets.only(top: 50.0),
                child: Center(
                  child: Text("Data Error",
                      style: TextStyle(fontSize: ScreenUtil().setSp(43))),
                ),
              ));
            } else {
              List<Task> taskLeftList = taskList
                  .where(
                      (t) => t.date == DateFormat("yyyy-MM-dd").format(_today))
                  .toList();

              return AnimatedBuilder(
                  animation: widget.animationController,
                  builder: (BuildContext context, Widget child) {
                    return FadeTransition(
                        opacity: widget.animation,
                        child: Transform(
                            transform: Matrix4.translationValues(
                                100 * (1.0 - widget.animation.value), 0.0, 0.0),
                            child: Slidable(
                                actionPane: SlidableDrawerActionPane(),
                                actionExtentRatio: 0.25,
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
                                        return AddTodoScreen(
                                            action: "Edit",
                                            todo: widget.todoData,
                                            appBarTitle: " Task");
                                      }));
                                    },
                                  ),
                                  IconSlideAction(
                                    iconWidget: CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Colors.blueGrey,
                                        child: Icon(
                                          Icons.calendar_today,
                                          color: Colors.white,
                                          size: 30,
                                        )),
                                    color: Colors.transparent,
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return AddTaskScreen(
                                            action: "Edit",
                                            selectedDate: widget.selectedDate,
                                            todo: widget.todoData,
                                            appBarTitle: " Task");
                                      }));
                                    },
                                  ),
                                ],
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
                                      final bool confirm = await showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text("Confirm"),
                                            content: Text(
                                                "Are you sure you wish to delete this?"),
                                            actions: <Widget>[
                                              FlatButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(true),
                                                  child: const Text("Delete")),
                                              FlatButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(false),
                                                child: const Text("Cancel"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      if (confirm) {
                                        await deleteTodo(widget.todoData);
                                      }
                                    },
                                  ),
                                ],
                                child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 2.0, right: 2.0),
                                    child: Card(
                                        color: Colors.white,
                                        elevation: 1.0,
                                        child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 10.0, top: 0.0),
                                            child: ListTile(
                                              leading: SizedBox(
                                                  width: 70,
                                                  child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: <Widget>[
                                                        Text(
                                                          DateFormat("MMM d")
                                                              .format(_endTime),
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize:
                                                                  ScreenUtil()
                                                                      .setSp(
                                                                          43),
                                                              letterSpacing:
                                                                  1.2,
                                                              color: (_today
                                                                      .isAtSameMomentAs(
                                                                          _endDate))
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .blue),
                                                        ),
                                                        Text(
                                                          DateFormat("h:mm a")
                                                              .format(_endTime),
                                                          style: TextStyle(
                                                              fontSize:
                                                                  ScreenUtil()
                                                                      .setSp(
                                                                          40)),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Text(
                                                              taskLeft(
                                                                  taskLeftList),
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      ScreenUtil()
                                                                          .setSp(
                                                                              40),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: Colors
                                                                      .blue),
                                                            ),
                                                            Text(
                                                              " Tasks",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      ScreenUtil()
                                                                          .setSp(
                                                                              40)),
                                                            )
                                                          ],
                                                        )
                                                      ])),
                                              subtitle: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                        "(P" +
                                                            widget.todoData
                                                                .priority
                                                                .toString() +
                                                            ") " +
                                                            widget
                                                                .todoData.title,
                                                        style: TextStyle(
                                                            fontSize:
                                                                ScreenUtil()
                                                                    .setSp(40),
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            letterSpacing:
                                                                1.2)),
                                                    widget.todoData.recurring ==
                                                            0
                                                        ? Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    top: 2),
                                                            child: Text(
                                                              "Start Date : " +
                                                                  DateFormat(
                                                                          "MMM d")
                                                                      .format(
                                                                          _startTime),
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      ScreenUtil()
                                                                          .setSp(
                                                                              38)),
                                                            ),
                                                          )
                                                        : SizedBox(),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 2),
                                                      child:
                                                          widget.todoData.desc
                                                                  .isNotEmpty
                                                              ? Text(
                                                                  widget
                                                                      .todoData
                                                                      .desc,
                                                                  softWrap:
                                                                      false,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          ScreenUtil()
                                                                              .setSp(38)),
                                                                )
                                                              : Text(
                                                                  "No Description.",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          ScreenUtil()
                                                                              .setSp(38)),
                                                                ),
                                                    ),
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(top: 2),
                                                        child: Row(
                                                          children: <Widget>[
                                                            Expanded(
                                                                child: SizedBox(
                                                              height: 3,
                                                              child:
                                                                  LinearProgressIndicator(
                                                                value: percentCalc(
                                                                    taskLeftList),
                                                                backgroundColor:
                                                                    Colors.grey[
                                                                        200],
                                                                valueColor: AlwaysStoppedAnimation<
                                                                    Color>(Theme.of(
                                                                        context)
                                                                    .primaryColor),
                                                              ),
                                                            )),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          5.0),
                                                              child: Text(
                                                                (percentCalc(taskLeftList) *
                                                                            100)
                                                                        .round()
                                                                        .toString() +
                                                                    "%",
                                                                style: TextStyle(
                                                                    fontSize: ScreenUtil()
                                                                        .setSp(
                                                                            38)),
                                                              ),
                                                            )
                                                          ],
                                                        )),
                                                  ]),
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    MyCustomRoute(TaskDetails(
                                                  selectedDate:
                                                      widget.selectedDate,
                                                  todoData: widget.todoData,
                                                  taskData: taskList,
                                                )));
                                              },
                                            )))))));
                  });
            }
          } else {
            return SizedBox(
                height: 100,
                child: Center(
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                      SizedBox(
                          width: 35,
                          height: 35,
                          child: CircularProgressIndicator())
                    ])));
          }
        });
  }

  Future<void> deleteTodo(Todo todo) async {
    await widget.todoController.removeTodoByID(todo.tid);
    await widget.taskController.removeTaskBytid(todo.tid);
    widget.parent.setState(() {});
  }
}
