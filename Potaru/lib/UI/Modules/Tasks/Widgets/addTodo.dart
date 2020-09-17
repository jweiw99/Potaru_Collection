import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:potaru/Controller/todo.controller.dart';
import 'package:potaru/Controller/task.controller.dart';
import 'package:potaru/Model/task.model.dart';
import 'package:potaru/Model/todo.model.dart';
import 'package:potaru/UI/Bar/appbar.dart';
import 'package:potaru/UI/Modules/Tasks/Widgets/addTask.dart';
import 'package:potaru/UI/utils/toastMsg.dart';

class AddTodoScreen extends StatefulWidget {
  const AddTodoScreen({Key key, this.action, this.todo, this.appBarTitle})
      : super(key: key);

  final String action;
  final String appBarTitle;
  final Todo todo;

  @override
  _AddTodoScreenState createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  FocusNode titleFocus, descFocus;
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  Todo todo;
  bool recurringVal;
  bool reminderVal;

  TodoController todoController = TodoController();
  TaskController taskController = TaskController();

  Map<String, String> recType = {
    "D": "Day",
    "W": "Week",
    "M": "Month",
    "Y": "Year"
  };

  @override
  void initState() {
    titleFocus = FocusNode();
    descFocus = FocusNode();
    todo = widget.todo;

    recurringVal = todo.recurring == 0 ? false : true;
    reminderVal = todo.remind == 0 ? false : true;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
        child: Container(
            color: Color(0xFFF2F3F8),
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar:
                    subappBar(context, widget.action + widget.appBarTitle, 2),
                backgroundColor: Colors.transparent,
                body: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 36),
                        child: Card(
                          child: FormBuilder(
                              key: _fbKey,
                              autovalidate: false,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 15, 0, 15),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).buttonColor,
                                          borderRadius: BorderRadius.only(
                                              topLeft:
                                                  const Radius.circular(5.0),
                                              topRight:
                                                  const Radius.circular(5.0))),
                                      child: Center(
                                          child: Text(
                                        "Main Information",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white),
                                      )),
                                    ),
                                    Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            20, 20, 20, 30),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(children: <Widget>[
                                                Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      "Title",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 16,
                                                          color: Colors
                                                              .blueGrey[700]),
                                                    )),
                                                Expanded(
                                                    flex: 8,
                                                    child: SizedBox(
                                                        height: 40,
                                                        child:
                                                            FormBuilderTextField(
                                                          attribute: "title",
                                                          maxLines: 1,
                                                          initialValue:
                                                              todo.title,
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .normal),
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                          textInputAction:
                                                              TextInputAction
                                                                  .next,
                                                          focusNode: titleFocus,
                                                          onFieldSubmitted:
                                                              (term) {
                                                            _fieldFocusChange(
                                                                context,
                                                                titleFocus,
                                                                descFocus);
                                                          },
                                                          decoration:
                                                              InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            hintText:
                                                                "Task Name",
                                                            contentPadding:
                                                                const EdgeInsets
                                                                        .only(
                                                                    bottom: 10),
                                                          ),
                                                          validators: [
                                                            FormBuilderValidators
                                                                .required(),
                                                            FormBuilderValidators
                                                                .minLength(3,
                                                                    errorText:
                                                                        "Min 3 character")
                                                          ],
                                                        )))
                                              ]),
                                              Divider(
                                                color: Colors.black,
                                              ),
                                              SizedBox(height: 15),
                                              Text(
                                                "Description",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16,
                                                    color:
                                                        Colors.blueGrey[700]),
                                              ),
                                              SizedBox(height: 10),
                                              FormBuilderTextField(
                                                attribute: "desc",
                                                maxLines: 4,
                                                initialValue: todo.desc,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontStyle:
                                                        FontStyle.normal),
                                                keyboardType:
                                                    TextInputType.text,
                                                textInputAction:
                                                    TextInputAction.done,
                                                focusNode: descFocus,
                                                decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText:
                                                        "Enter task description here"),
                                              ),
                                              Divider(
                                                color: Colors.black,
                                              ),
                                              FormBuilderSwitch(
                                                label: Text(
                                                  'Recurring',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 16,
                                                      color:
                                                          Colors.blueGrey[700]),
                                                ),
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                ),
                                                attribute: "recurring",
                                                initialValue: recurringVal,
                                                onChanged: (val) {
                                                  setState(() {
                                                    recurringVal = val;
                                                  });
                                                },
                                              ),
                                              Visibility(
                                                  visible: recurringVal,
                                                  child: Row(children: <Widget>[
                                                    Expanded(
                                                        flex: 7,
                                                        child: Text(
                                                          "Recurring Every ",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              fontSize: 16,
                                                              color: Colors
                                                                      .blueGrey[
                                                                  700]),
                                                        )),
                                                    Expanded(
                                                        flex: 3,
                                                        child: SizedBox(
                                                            height: 50,
                                                            child:
                                                                DropdownButton(
                                                              style: TextStyle(
                                                                  letterSpacing:
                                                                      1.2,
                                                                  color: Colors
                                                                          .blueGrey[
                                                                      700],
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700),
                                                              isExpanded: true,
                                                              itemHeight: 70,
                                                              value:
                                                                  todo.recType,
                                                              underline:
                                                                  SizedBox(),
                                                              onChanged: (val) {
                                                                setState(() {
                                                                  todo.recType =
                                                                      val;
                                                                });
                                                              },
                                                              items: recType
                                                                  .entries
                                                                  .map((l) => DropdownMenuItem(
                                                                      value:
                                                                          l.key,
                                                                      child: Center(
                                                                          child:
                                                                              Text(l.value))))
                                                                  .toList(),
                                                            )))
                                                  ])),
                                              Visibility(
                                                  visible: !recurringVal,
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 15),
                                                      child: Text(
                                                        "Task Date Time",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 16,
                                                            color: Colors
                                                                .blueGrey[700]),
                                                      ))),
                                              Visibility(
                                                  visible: !recurringVal,
                                                  child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 25),
                                                      child: Row(
                                                          children: <Widget>[
                                                            Expanded(
                                                                flex: 2,
                                                                child: Text(
                                                                  "Start",
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                              .blueGrey[
                                                                          700]),
                                                                )),
                                                            Expanded(
                                                                flex: 8,
                                                                child: SizedBox(
                                                                  height: 45,
                                                                  child:
                                                                      FormBuilderDateTimePicker(
                                                                    attribute:
                                                                        "startTime",
                                                                    initialValue: todo
                                                                            .startTime
                                                                            .isNotEmpty
                                                                        ? DateFormat("yyyy-MM-dd HH:mm").parse(todo
                                                                            .startTime)
                                                                        : DateTime
                                                                            .now(),
                                                                    inputType:
                                                                        InputType
                                                                            .both,
                                                                    format: DateFormat(
                                                                        "yyyy-MM-dd HH:mm"),
                                                                    decoration:
                                                                        InputDecoration(
                                                                      hintText:
                                                                          "2020-12-24 12:00",
                                                                    ),
                                                                    validators: [
                                                                      FormBuilderValidators
                                                                          .required(),
                                                                      (val) {
                                                                        if (!recurringVal) {
                                                                          if (_fbKey.currentState.fields['endTime'].currentState.value != null &&
                                                                              val != null) {
                                                                            DateTime
                                                                                starttime =
                                                                                DateFormat("yyyy-MM-dd HH:mm").parse(DateFormat("yyyy-MM-dd HH:mm").format(val));
                                                                            DateTime
                                                                                endtime =
                                                                                DateFormat("yyyy-MM-dd HH:mm").parse(DateFormat("yyyy-MM-dd HH:mm").format(_fbKey.currentState.fields['endTime'].currentState.value));

                                                                            if (endtime.isBefore(starttime) &&
                                                                                !endtime.isAtSameMomentAs(starttime)) {
                                                                              return "Start time is after end time";
                                                                            }
                                                                          }
                                                                        }
                                                                        return null;
                                                                      }
                                                                    ],
                                                                  ),
                                                                ))
                                                          ]))),
                                              SizedBox(height: 10),
                                              Row(children: <Widget>[
                                                Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      !recurringVal
                                                          ? "End"
                                                          : "Date",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 16,
                                                          color: Colors
                                                              .blueGrey[700]),
                                                    )),
                                                Expanded(
                                                    flex: 8,
                                                    child: SizedBox(
                                                      height: 45,
                                                      child:
                                                          FormBuilderDateTimePicker(
                                                        attribute: "endTime",
                                                        initialValue: todo
                                                                .endTime
                                                                .isNotEmpty
                                                            ? DateFormat(
                                                                    "yyyy-MM-dd HH:mm")
                                                                .parse(todo
                                                                    .endTime)
                                                            : DateTime.now(),
                                                        inputType:
                                                            InputType.both,
                                                        format: DateFormat(
                                                            "yyyy-MM-dd HH:mm"),
                                                        decoration:
                                                            InputDecoration(
                                                          hintText:
                                                              "2020-12-31 12:00",
                                                        ),
                                                        validators: [
                                                          FormBuilderValidators
                                                              .required(),
                                                          (val) {
                                                            if (!recurringVal) {
                                                              if (_fbKey
                                                                          .currentState
                                                                          .fields[
                                                                              'startTime']
                                                                          .currentState
                                                                          .value !=
                                                                      null &&
                                                                  val != null) {
                                                                DateTime starttime = DateFormat("yyyy-MM-dd HH:mm").parse(DateFormat(
                                                                        "yyyy-MM-dd HH:mm")
                                                                    .format(_fbKey
                                                                        .currentState
                                                                        .fields[
                                                                            'startTime']
                                                                        .currentState
                                                                        .value));
                                                                DateTime endtime = DateFormat(
                                                                        "yyyy-MM-dd HH:mm")
                                                                    .parse(DateFormat(
                                                                            "yyyy-MM-dd HH:mm")
                                                                        .format(
                                                                            val));
                                                                if (endtime.isBefore(
                                                                        starttime) &&
                                                                    !endtime.isAtSameMomentAs(
                                                                        starttime)) {
                                                                  return "Start time is after end time";
                                                                }
                                                              }
                                                            }
                                                            return null;
                                                          }
                                                        ],
                                                      ),
                                                    )),
                                              ]),
                                              SizedBox(height: 30),
                                              Divider(
                                                color: Colors.black,
                                              ),
                                              FormBuilderSwitch(
                                                label: Text(
                                                  'Reminder',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 16,
                                                      color:
                                                          Colors.blueGrey[700]),
                                                ),
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                ),
                                                attribute: "reminder",
                                                initialValue: reminderVal,
                                                onChanged: (val) {
                                                  setState(() {
                                                    reminderVal = val;
                                                  });
                                                },
                                              ),
                                              Visibility(
                                                  visible: reminderVal,
                                                  child:
                                                      Column(children: <Widget>[
                                                    Row(children: <Widget>[
                                                      Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            "Time",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize: 16,
                                                                color: Colors
                                                                        .blueGrey[
                                                                    700]),
                                                          )),
                                                      Expanded(
                                                          flex: 8,
                                                          child: SizedBox(
                                                            height: 45,
                                                            child:
                                                                FormBuilderDateTimePicker(
                                                              attribute:
                                                                  "remindTime",
                                                              initialValue: todo
                                                                      .remindTime
                                                                      .isNotEmpty
                                                                  ? DateFormat(
                                                                          "HH:mm")
                                                                      .parse(todo
                                                                          .remindTime)
                                                                  : DateTime
                                                                      .now(),
                                                              inputType:
                                                                  InputType
                                                                      .time,
                                                              format:
                                                                  DateFormat(
                                                                      "HH:mm"),
                                                              decoration:
                                                                  InputDecoration(
                                                                hintText:
                                                                    "12:00",
                                                              ),
                                                              validators: [
                                                                FormBuilderValidators
                                                                    .required(),
                                                              ],
                                                            ),
                                                          ))
                                                    ]),
                                                    SizedBox(height: 30),
                                                  ])),
                                              Divider(
                                                color: Colors.black,
                                              ),
                                              Row(children: <Widget>[
                                                Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      "Priority",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 16,
                                                          color: Colors
                                                              .blueGrey[700]),
                                                    )),
                                                Expanded(
                                                  flex: 7,
                                                  child: FormBuilderChoiceChip(
                                                    attribute: "priority",
                                                    selectedColor:
                                                        Colors.grey[100],
                                                    backgroundColor:
                                                        Colors.white,
                                                    initialValue: todo.priority,
                                                    spacing: 10,
                                                    decoration: InputDecoration(
                                                        border:
                                                            InputBorder.none),
                                                    options: [
                                                      FormBuilderFieldOption(
                                                          child: Text("P1"),
                                                          value: 1),
                                                      FormBuilderFieldOption(
                                                          child: Text("P2"),
                                                          value: 2),
                                                      FormBuilderFieldOption(
                                                          child: Text("P3"),
                                                          value: 3),
                                                    ],
                                                  ),
                                                )
                                              ]),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Center(
                                                  child: MaterialButton(
                                                color: Theme.of(context)
                                                    .buttonColor,
                                                textColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.all(0.0),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      2.2,
                                                  height: 50,
                                                  child: Center(
                                                    child: Text(
                                                      widget.action == "Edit"
                                                          ? 'Save Now'
                                                          : 'Continue',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500),
                                                    ),
                                                  ),
                                                ),
                                                onPressed: () async {
                                                  if (_fbKey.currentState
                                                      .saveAndValidate()) {
                                                    todo.title = _fbKey
                                                        .currentState
                                                        .fields['title']
                                                        .currentState
                                                        .value;
                                                    todo.desc = _fbKey
                                                                .currentState
                                                                .fields['desc']
                                                                .currentState
                                                                .value ==
                                                            null
                                                        ? ""
                                                        : _fbKey
                                                            .currentState
                                                            .fields['desc']
                                                            .currentState
                                                            .value;
                                                    todo.recurring =
                                                        !recurringVal ? 0 : 1;
                                                    todo.endTime = DateFormat(
                                                            "yyyy-MM-dd HH:mm")
                                                        .format(_fbKey
                                                            .currentState
                                                            .fields['endTime']
                                                            .currentState
                                                            .value);
                                                    if (!recurringVal) {
                                                      todo.startTime = DateFormat(
                                                              "yyyy-MM-dd HH:mm")
                                                          .format(_fbKey
                                                              .currentState
                                                              .fields[
                                                                  'startTime']
                                                              .currentState
                                                              .value);
                                                    } else {
                                                      todo.startTime =
                                                          todo.endTime;
                                                    }
                                                    DateTime selectedDate =
                                                        DateFormat("yyyy-MM-dd")
                                                            .parse(
                                                                todo.startTime);

                                                    todo.remind =
                                                        !reminderVal ? 0 : 1;
                                                    if (reminderVal) {
                                                      todo.remindTime =
                                                          DateFormat("HH:mm")
                                                              .format(_fbKey
                                                                  .currentState
                                                                  .fields[
                                                                      'remindTime']
                                                                  .currentState
                                                                  .value);
                                                    }
                                                    todo.priority = _fbKey
                                                        .currentState
                                                        .fields['priority']
                                                        .currentState
                                                        .value;

                                                    if (widget.action ==
                                                        "Add") {
                                                      Navigator.push(context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) {
                                                        return AddTaskScreen(
                                                            action:
                                                                widget.action,
                                                            selectedDate:
                                                                selectedDate,
                                                            appBarTitle:
                                                                " Task",
                                                            todo: todo);
                                                      }));
                                                    } else {
                                                      await updateDatabase(
                                                          todo);
                                                    }
                                                  }
                                                },
                                              )),
                                            ]))
                                  ])),
                        ))))));
  }

  Future<void> updateDatabase(Todo todo) async {
    await todoController.insertTodo(todo);
    DateTime startDate = DateFormat("yyyy-MM-dd")
        .parse(todo.startTime)
        .subtract(Duration(days: 1));
    DateTime endDate =
        DateFormat("yyyy-MM-dd").parse(todo.endTime).add(Duration(days: 1));
    List<Task> taskList = await taskController.getTaskList(todo.tid);
    await Future.forEach(taskList, (t) async {
      DateTime curDate = DateFormat("yyyy-MM-dd").parse(t.date);
      if (!(curDate.isAfter(startDate) && curDate.isBefore(endDate))) {
        await taskController.removeTaskByDate(t);
      }
    });

    ToastMsg.toToast("Updated");
    Navigator.of(context).pop();
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}
