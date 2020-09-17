import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reorderables/reorderables.dart';
import 'package:intl/intl.dart';

import 'package:potaru/Controller/task.controller.dart';
import 'package:potaru/Controller/todo.controller.dart';
import 'package:potaru/Model/task.model.dart';
import 'package:potaru/Model/todo.model.dart';
import 'package:potaru/UI/Bar/appbar.dart';
import 'package:potaru/UI/utils/toastMsg.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen(
      {Key key, this.action, this.todo, this.appBarTitle, this.selectedDate})
      : super(key: key);

  final String action;
  final String appBarTitle;
  final DateTime selectedDate;
  final Todo todo;

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  bool firstrun = false;
  Todo todo;
  Map<String, List<Task>> taskList = {};
  List<String> dateList = [];
  String dateSelected = "";
  String todoStartDate = "";
  String todoEndDate = "";

  final TaskController taskController = TaskController();
  final TodoController todoController = TodoController();

  Future<Map<String, List<Task>>> getData() async {
    if (!firstrun) {
      if (widget.todo.recurring == 0) {
        List<Task> _tempData = await taskController.getTaskList(todo.tid);
        taskList.entries.forEach((t) {
          taskList[t.key] = _tempData.where((d) => d.date == t.key).toList();
        });
      } else {
        List<Task> _tempData = await taskController.getTaskList(todo.tid);
        if (_tempData.length > 0) {
          _tempData.forEach((t) {
            if (!taskList.containsKey(t.date)) {
              dateList.add(t.date);
              taskList[t.date] = [];
              taskList[t.date].add(t);
            } else {
              taskList[t.date].add(t);
            }
          });
        } else {
          dateList.add(dateSelected);
          taskList[dateSelected] = [];
        }
      }
    }
    firstrun = true;
    return taskList;
  }

  @override
  void initState() {
    todo = widget.todo;

    dateSelected = DateFormat("yyyy-MM-dd").format(widget.selectedDate);
    if (todo.recurring == 0) {
      DateTime startDate = DateFormat("yyyy-MM-dd").parse(todo.startTime);
      DateTime endDate = DateFormat("yyyy-MM-dd").parse(todo.endTime);
      todoStartDate = DateFormat("yyyy-MM-dd").format(startDate);
      todoEndDate = DateFormat("yyyy-MM-dd").format(endDate);
      int diffDay = endDate.difference(startDate).inDays;
      for (int i = 0; i <= diffDay; i++) {
        String _tempDate =
            DateFormat("yyyy-MM-dd").format(startDate.add(Duration(days: i)));
        dateList.add(_tempDate);
        taskList[_tempDate] = [];
      }
    } else {
      todoStartDate = todoEndDate = dateSelected;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
        child: Container(
            color: Color(0xFFF2F3F8),
            child: Scaffold(
                appBar:
                    subappBar(context, widget.action + widget.appBarTitle, 2),
                backgroundColor: Colors.transparent,
                body: Container(
                    child: FutureBuilder(
                        future: getData(),
                        builder: (context,
                            AsyncSnapshot<Map<String, List<Task>>> snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
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
                            } else {
                              return TaskListScreen(
                                  dateSelected: dateSelected,
                                  action: widget.action,
                                  todo: widget.todo,
                                  dateList: dateList,
                                  taskList: taskList,
                                  todoStartDate: todoStartDate,
                                  todoEndDate: todoEndDate,
                                  taskController: taskController,
                                  todoController: todoController);
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
                        })))));
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen(
      {Key key,
      this.todo,
      this.action,
      this.dateSelected,
      this.dateList,
      this.taskList,
      this.todoStartDate,
      this.todoEndDate,
      this.taskController,
      this.todoController})
      : super(key: key);

  final Todo todo;
  final String action;
  final String dateSelected;
  final List<String> dateList;
  final Map<String, List<Task>> taskList;
  final String todoStartDate;
  final String todoEndDate;
  final TaskController taskController;
  final TodoController todoController;

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  String dateSelected = "";

  @override
  void initState() {
    dateSelected = widget.dateSelected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(15, 5, 10, 20),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text("Task",
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            fontSize: ScreenUtil().setSp(43))),
                    SizedBox(height: 3),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                            fontSize: 13, color: Colors.blueGrey[800]),
                        children: [
                          TextSpan(
                              text:
                                  'Enter the list of tasks that you plan to perform on this project that day. You can hold '),
                          WidgetSpan(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 1.0),
                              child: Icon(
                                Icons.swap_vert,
                                size: 15,
                              ),
                            ),
                          ),
                          TextSpan(text: ' button to reorder the list.'),
                        ],
                      ),
                    )
                  ]),
              SizedBox(
                height: 15,
              ),
              Container(
                  child: Row(children: <Widget>[
                Visibility(
                    visible: widget.todo.recurring == 0 ? false : true,
                    child: Expanded(
                        flex: 8,
                        child: Text(
                          "Recurring Date : " + dateSelected,
                          style: TextStyle(
                              letterSpacing: 1.2,
                              fontSize: ScreenUtil().setSp(40),
                              fontWeight: FontWeight.w700),
                        ))),
                Visibility(
                    visible: widget.todo.recurring == 0 ? true : false,
                    child: Expanded(
                        flex: 2,
                        child: Text(
                          "Date : ",
                          style: TextStyle(
                              letterSpacing: 1.2,
                              fontSize: ScreenUtil().setSp(40),
                              fontWeight: FontWeight.w700),
                        ))),
                Visibility(
                    visible: widget.todo.recurring == 0 ? true : false,
                    child: Expanded(
                        flex: 6,
                        child: Container(
                            height: 45,
                            margin: EdgeInsets.only(right: 3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(const Radius.circular(10.0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[300],
                                  offset: Offset(2.0, 2.0),
                                  blurRadius: 5.0,
                                ),
                              ],
                            ),
                            child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 0, 15, 0),
                                child: DropdownButton(
                                  style: TextStyle(
                                      letterSpacing: 1.2,
                                      color: Colors.blueGrey,
                                      fontWeight: FontWeight.w700),
                                  isExpanded: true,
                                  itemHeight: 70,
                                  value: dateSelected,
                                  hint: Text(
                                    'Date',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  underline: SizedBox(),
                                  onChanged: (val) {
                                    setState(() {
                                      dateSelected = val;
                                    });
                                  },
                                  items: widget.dateList
                                      .map((val) => DropdownMenuItem(
                                          value: val,
                                          child: Center(
                                              child: Text(
                                            DateFormat("EE").format(
                                                    DateFormat("yyyy-MM-dd")
                                                        .parse(val)) +
                                                " " +
                                                val,
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(40)),
                                          ))))
                                      .toList(),
                                ))))),
                Expanded(
                  flex: 2,
                  child: InkWell(
                      onTap: () => addRow(),
                      child: SizedBox(
                          height: 35,
                          child: CircleAvatar(
                              radius: 25,
                              backgroundColor: Theme.of(context).buttonColor,
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 25,
                              )))),
                )
              ])),
              SizedBox(
                height: 15,
              ),
              Expanded(
                  child: ReorderableColumn(
                      onReorder: reorderRow,
                      children: List.generate(
                          widget.taskList[dateSelected].length, (index) {
                        return ReorderableTableRow(
                            key:
                                ObjectKey(widget.taskList[dateSelected][index]),
                            children: <Widget>[
                              Expanded(
                                  flex: 7,
                                  child: Container(
                                      height: 45,
                                      margin: EdgeInsets.only(top: 5, right: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                            const Radius.circular(10.0)),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey[300],
                                            offset: Offset(2.0, 2.0),
                                            blurRadius: 5.0,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                          child: TextField(
                                        textAlign: TextAlign.center,
                                        controller: TextEditingController()
                                          ..text = widget
                                              .taskList[dateSelected][index]
                                              .task,
                                        keyboardType: TextInputType.text,
                                        textInputAction: TextInputAction.done,
                                        inputFormatters: <TextInputFormatter>[],
                                        decoration: InputDecoration(
                                          hintText: "Task to do",
                                          border: InputBorder.none,
                                          hintStyle:
                                              TextStyle(color: Colors.grey),
                                        ),
                                        style: TextStyle(
                                            color: Color(0xFF4A6572),
                                            fontWeight: FontWeight.w700,
                                            fontSize: ScreenUtil().setSp(40)),
                                        onChanged: (val) {
                                          widget.taskList[dateSelected][index]
                                              .task = val;
                                        },
                                      )))),
                              Expanded(
                                  flex: 2,
                                  child: Container(
                                      height: 35,
                                      width: 35,
                                      margin: EdgeInsets.only(top: 5),
                                      child: CircleAvatar(
                                          radius: 25,
                                          backgroundColor: Colors.blueGrey,
                                          child: PopupMenuButton(
                                            icon: Icon(
                                              Icons.more_vert,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            itemBuilder: (context) =>
                                                <PopupMenuEntry<int>>[
                                              PopupMenuItem(
                                                child: Text("Delete",
                                                    style: TextStyle(
                                                        fontSize: ScreenUtil()
                                                            .setSp(40))),
                                                value: 0,
                                              ),
                                              PopupMenuItem(
                                                child: Text("Move to yesterday",
                                                    style: TextStyle(
                                                        fontSize: ScreenUtil()
                                                            .setSp(40))),
                                                value: 1,
                                                enabled: widget.todoStartDate !=
                                                    dateSelected,
                                              ),
                                              PopupMenuItem(
                                                child: Text(
                                                  "Move to tomorrow",
                                                  style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(40)),
                                                ),
                                                value: 2,
                                                enabled: widget.todoEndDate !=
                                                    dateSelected,
                                              ),
                                            ],
                                            onSelected: (val) {
                                              if (val == 0) {
                                                removeRow(index);
                                              } else if (val == 1 || val == 2) {
                                                String _tempDate = "";
                                                if (val == 1) {
                                                  _tempDate = DateFormat(
                                                          "yyyy-MM-dd")
                                                      .format(DateFormat(
                                                              "yyyy-MM-dd")
                                                          .parse(widget
                                                              .taskList[
                                                                  dateSelected]
                                                                  [index]
                                                              .date)
                                                          .subtract(Duration(
                                                              days: 1)));
                                                } else {
                                                  _tempDate = DateFormat(
                                                          "yyyy-MM-dd")
                                                      .format(DateFormat(
                                                              "yyyy-MM-dd")
                                                          .parse(widget
                                                              .taskList[
                                                                  dateSelected]
                                                                  [index]
                                                              .date)
                                                          .add(Duration(
                                                              days: 1)));
                                                }
                                                widget
                                                    .taskList[dateSelected]
                                                        [index]
                                                    .date = _tempDate;
                                                widget.taskList[_tempDate].add(
                                                    widget.taskList[
                                                        dateSelected][index]);
                                                widget.taskList[dateSelected]
                                                    .removeAt(index);

                                                setState(() {});
                                              }
                                            },
                                          )))),
                              Expanded(
                                  flex: 1,
                                  child: Container(
                                      height: 35,
                                      width: 35,
                                      margin: EdgeInsets.only(top: 5),
                                      child: Center(
                                        child: SizedBox(
                                            height: 35,
                                            child: CircleAvatar(
                                                radius: 25,
                                                backgroundColor:
                                                    Colors.green[500],
                                                child: Icon(
                                                  Icons.swap_vert,
                                                  color: Colors.white,
                                                  size: 20,
                                                ))),
                                      )))
                            ]);
                      }))),
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: ButtonTheme(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(const Radius.circular(10.0))),
                      minWidth: double.infinity,
                      height: 45.0,
                      buttonColor: Theme.of(context).buttonColor,
                      child: RaisedButton(
                        textColor: Colors.white,
                        child: Text(
                            widget.action == "Edit"
                                ? "Save Now"
                                : widget.action + " Now",
                            style: TextStyle(fontSize: ScreenUtil().setSp(40))),
                        onPressed: () async {
                          await updateDatabase();
                        },
                      ))),
            ]));
  }

  Future<void> updateDatabase() async {
    if (widget.action == "Add")
      await widget.todoController.insertTodo(widget.todo);
    else
      widget.taskController.removeTaskBytid(widget.todo.tid);

    if (widget.todo.recurring == 0) {
      await Future.forEach(widget.taskList.values, (List<Task> t) async {
        int index = 0;
        await Future.forEach(t, (Task d) async {
          if (d.task.isNotEmpty) {
            d.no = ++index;
            await widget.taskController.insertTask(d);
          }
        });
      });
    } else {
      DateTime n = DateFormat("yyyy-MM-dd")
          .parse(widget.dateSelected)
          .subtract(Duration(days: 1));
      await Future.forEach(widget.dateList, (String date) async {
        DateTime d = DateFormat("yyyy-MM-dd").parse(date);
        if (d.isAfter(n)) {
          if (date != dateSelected) {
            widget.taskList[date] = widget.taskList[dateSelected];
          }
          int index = 0;
          await Future.forEach(widget.taskList[date], (Task t) async {
            if (t.task.isNotEmpty) {
              t.no = ++index;
              t.date = date;
              if (date != dateSelected) t.completed = 0;
              await widget.taskController.insertTask(t);
            }
          });
        } else {
          await Future.forEach(widget.taskList[date], (Task t) async {
            await widget.taskController.insertTask(t);
          });
        }
      });
    }

    ToastMsg.toToast("Updated");
    int count = 0;
    Navigator.of(context).popUntil((route) {
      return count++ == (widget.action == "Edit" ? 1 : 2);
    });
  }

  void reorderRow(int oldIndex, int newIndex) {
    Task row = widget.taskList[dateSelected].removeAt(oldIndex);
    widget.taskList[dateSelected].insert(newIndex, row);
    setState(() {});
  }

  void addRow() {
    widget.taskList[dateSelected]
        .add(Task(widget.todo.tid, 0, "", dateSelected, 0));
    setState(() {});
  }

  void removeRow(int index) {
    widget.taskList[dateSelected].removeAt(index);
    setState(() {});
  }
}
