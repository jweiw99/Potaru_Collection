import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_select/smart_select.dart';

import 'package:potaru/Controller/staff.controller.dart';
import 'package:potaru/Controller/timetable.controller.dart';
import 'package:potaru/Controller/grade.controller.dart';
import 'package:potaru/Model/semester.model.dart';
import 'package:potaru/Model/staff.model.dart';
import 'package:potaru/Model/timetable.model.dart';
import 'package:potaru/Controller/semester.controller.dart';
import 'package:potaru/UI/Bar/appbar.dart';
import 'package:potaru/UI/Modules/StaffDirectory/utils/staffImgRetrieve.dart';
import 'package:potaru/UI/Modules/Timetable/utils/timetableToImage.dart';
import 'package:potaru/UI/Modules/Timetable/utils/config.dart';
import 'package:potaru/UI/utils/errorMsg.dart';
import 'package:potaru/UI/utils/toastMsg.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen(
      {Key key,
      this.action,
      this.type,
      this.timetable,
      this.selectedDate,
      this.appBarTitle})
      : super(key: key);

  final String action;
  final String type;
  final String appBarTitle;
  final Timetable timetable;
  final DateTime selectedDate;

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  StaffController staffController = StaffController();
  GradeController gradeController = GradeController();
  SemesterController semesterController = SemesterController();
  TimetableController timetableController = TimetableController();
  List<Map<String, String>> allsubjectdata = [];
  Timetable timetable;
  List<Staff> staffdata = [];
  Semester sem = Semester("", "", "", 0);

  String _coursetype = "";
  String selectEvent = "";

  @override
  void initState() {
    timetable = widget.timetable;

    _coursetype = TimetableConfig.courseType.entries
        .firstWhere((ct) => ct.key == widget.type)
        .key;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<List<Staff>> getData() async {
    if (allsubjectdata.length == 0) {
      List<Semester> _tempSem = await semesterController.getActiveSemester();
      List<String> activeSem = _tempSem.map((val) => val.session).toList();
      allsubjectdata = await gradeController.getAllSubjectList();
      allsubjectdata = allsubjectdata
          .where((val) => activeSem.contains(val['session']))
          .toList();

      if (widget.action == "Add" && allsubjectdata.length > 0) {
        sem = await sessionToStartDate(allsubjectdata[0]['session']);
        selectEvent = sem.session +
            ":" +
            allsubjectdata[0]['courseCode'] +
            ":" +
            allsubjectdata[0]['courseName'];
        timetable = await getTimetable(
            widget.action,
            widget.selectedDate,
            sem.startDate,
            allsubjectdata[0]['courseCode'],
            allsubjectdata[0]['courseName'],
            _coursetype);
      } else if (allsubjectdata.length > 0) {
        sem = await startDateToSession(timetable.startDate);
        selectEvent = sem.session +
            ":" +
            timetable.courseCode +
            ":" +
            timetable.courseName;

        if (timetable.recurring != "N")
          timetable.courseDate = timetable.courseStartDate;
      }

      if (_coursetype == "A")
        allsubjectdata.insert(0,
            {"session": "Other", "courseCode": "Other", "courseName": "Other"});
    }

    staffdata = staffdata.length == 0
        ? await staffController.getStaffList()
        : staffdata;
    return staffdata;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
        child: Container(
            color: Color(0xFFF2F3F8),
            child: Scaffold(
                resizeToAvoidBottomInset: false,
                appBar: subappBar(
                    context, widget.action + " " + widget.appBarTitle, 2),
                backgroundColor: Colors.transparent,
                body: FutureBuilder<List>(
                    future: getData(),
                    builder:
                        (BuildContext context, AsyncSnapshot<List> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          //print(snapshot.error);
                          return SizedBox(
                              child: Center(
                                  child: Text("Database Error",
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(43)))));
                        } else if (allsubjectdata.length == 0 &&
                            _coursetype != "A") {
                          ErrorMsg.courseNameNotFoundMsg();
                          return SizedBox(
                              child: Center(
                                  child: Text("No Course Data",
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(43)))));
                        } else {
                          return AddEventBuildForm(
                              action: widget.action,
                              coursetype: _coursetype,
                              appBarTitle: widget.appBarTitle,
                              sem: sem,
                              timetable: timetable,
                              staffdata: staffdata,
                              selectEvent: selectEvent,
                              allsubjectdata: allsubjectdata,
                              timetableController: timetableController,
                              selectedDate: widget.selectedDate);
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
                    }))));
  }
}

class AddEventBuildForm extends StatefulWidget {
  const AddEventBuildForm(
      {Key key,
      this.action,
      this.coursetype,
      this.timetable,
      this.staffdata,
      this.appBarTitle,
      this.sem,
      this.selectEvent,
      this.allsubjectdata,
      this.timetableController,
      this.selectedDate})
      : super(key: key);

  final String action;
  final String coursetype;
  final String appBarTitle;
  final Timetable timetable;
  final String selectEvent;
  final List<Map<String, String>> allsubjectdata;
  final Semester sem;
  final List<Staff> staffdata;
  final TimetableController timetableController;
  final DateTime selectedDate;

  @override
  _AddEventBuildFormState createState() => _AddEventBuildFormState();
}

class _AddEventBuildFormState extends State<AddEventBuildForm> {
  FocusNode courseNameFocus;
  FocusNode courseGroupFocus;
  FocusNode courseVenueFocus;

  GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();

  Timetable timetable;
  Semester sem;

  String selectEvent = "";
  String selectedRecType = "";
  bool recurringVal, reminderVal;
  bool screenImageLoading = false;

  @override
  void initState() {
    courseNameFocus = FocusNode();
    courseGroupFocus = FocusNode();
    courseVenueFocus = FocusNode();

    timetable = widget.timetable;
    selectEvent = widget.selectEvent;
    sem = widget.sem;
    reminderVal = timetable.remind == 0 ? false : true;
    recurringVal = timetable.recurring != "N" ? true : false;
    selectedRecType = timetable.recurring != "N" ? timetable.recurring : "W";

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                        decoration: BoxDecoration(
                            color: Theme.of(context).buttonColor,
                            borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(5.0),
                                topRight: const Radius.circular(5.0))),
                        child: Center(
                            child: Text(
                          "${widget.appBarTitle} Information",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        )),
                      ),
                      Container(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(children: <Widget>[
                                Expanded(
                                    flex: 3,
                                    child: Text(
                                      widget.appBarTitle,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.blueGrey[700]),
                                    )),
                                widget.action == "Add"
                                    ? Expanded(
                                        flex: 7,
                                        child: SmartSelect<String>.single(
                                          title: '',
                                          modalConfig: SmartSelectModalConfig(
                                              useFilter: true,
                                              title: 'Subject'),
                                          modalType:
                                              SmartSelectModalType.bottomSheet,
                                          value: selectEvent,
                                          options: SmartSelectOption.listFrom<
                                                  String, Map>(
                                              source: widget.allsubjectdata,
                                              value: (key, item) =>
                                                  item['session'] +
                                                  ":" +
                                                  item['courseCode'] +
                                                  ":" +
                                                  item['courseName'],
                                              title: (key, item) =>
                                                  item['courseName'],
                                              group: (key, item) =>
                                                  item['session'] == "Other"
                                                      ? "Other"
                                                      : "Session " +
                                                          item['session']),
                                          choiceConfig: SmartSelectChoiceConfig(
                                              isGrouped: true),
                                          onChange: (val) async {
                                            if (val.isNotEmpty) {
                                              List<String> _temp =
                                                  val.split(":");
                                              if (_temp.length > 1) {
                                                selectEvent = val;
                                                if (selectEvent != "Other") {
                                                  sem =
                                                      await sessionToStartDate(
                                                          _temp[0]);
                                                  timetable =
                                                      await getTimetable(
                                                          widget.action,
                                                          widget.selectedDate,
                                                          sem.startDate,
                                                          _temp[1],
                                                          _temp[2],
                                                          widget.coursetype);
                                                }
                                                _fbKey = GlobalKey<
                                                    FormBuilderState>();
                                                setState(() {});
                                              }
                                            }
                                          },
                                        ))
                                    : Container(
                                        height: 55,
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.7,
                                        padding:
                                            const EdgeInsets.only(right: 15),
                                        child: Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(timetable.courseName,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16,
                                                    color: Colors.blue)))),
                              ]),
                              Visibility(
                                  visible: widget.coursetype == "A" &&
                                      timetable.courseCode == "Other",
                                  child: Column(children: <Widget>[
                                    SizedBox(height: 7),
                                    Row(children: <Widget>[
                                      Expanded(
                                          flex: 3,
                                          child: Text(
                                            "Name",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 16,
                                                color: Colors.blueGrey[700]),
                                          )),
                                      Expanded(
                                          flex: 7,
                                          child: SizedBox(
                                              height: 45,
                                              child: FormBuilderTextField(
                                                attribute: "courseName",
                                                initialValue:
                                                    timetable.courseName,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontStyle:
                                                        FontStyle.normal),
                                                keyboardType:
                                                    TextInputType.text,
                                                textInputAction:
                                                    TextInputAction.next,
                                                focusNode: courseNameFocus,
                                                onFieldSubmitted: (term) {
                                                  _fieldFocusChange(
                                                      context,
                                                      courseNameFocus,
                                                      courseVenueFocus);
                                                },
                                                textAlign: TextAlign.right,
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: "Event Name",
                                                  contentPadding:
                                                      const EdgeInsets.only(
                                                          right: 15,
                                                          bottom: 10),
                                                ),
                                                validators: [
                                                  FormBuilderValidators
                                                      .required(),
                                                  FormBuilderValidators
                                                      .maxLength(40)
                                                ],
                                              )))
                                    ]),
                                  ])),
                              Visibility(
                                  visible: !["E", "S", "A"]
                                      .contains(widget.coursetype),
                                  child: Row(children: <Widget>[
                                    Expanded(
                                        flex: 3,
                                        child: Text(
                                          "Group",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              color: Colors.blueGrey[700]),
                                        )),
                                    Expanded(
                                        flex: 7,
                                        child: SizedBox(
                                            height: 45,
                                            child: FormBuilderTextField(
                                              attribute: "courseGroup",
                                              initialValue: timetable
                                                  .courseGroup
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontStyle: FontStyle.normal),
                                              keyboardType:
                                                  TextInputType.number,
                                              textInputAction:
                                                  TextInputAction.next,
                                              focusNode: courseGroupFocus,
                                              onFieldSubmitted: (term) {
                                                _fieldFocusChange(
                                                    context,
                                                    courseGroupFocus,
                                                    courseVenueFocus);
                                              },
                                              textAlign: TextAlign.right,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: "Group No",
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                        right: 15, bottom: 10),
                                              ),
                                              validators: [
                                                FormBuilderValidators.numeric(),
                                                FormBuilderValidators.max(99),
                                                FormBuilderValidators.required()
                                              ],
                                            )))
                                  ])),
                              SizedBox(height: 7),
                              Row(children: <Widget>[
                                Expanded(
                                    flex: 3,
                                    child: Text(
                                      "Location",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.blueGrey[700]),
                                    )),
                                Expanded(
                                    flex: 7,
                                    child: SizedBox(
                                        height: 45,
                                        child: FormBuilderTextField(
                                          attribute: "courseVenue",
                                          initialValue: timetable.courseVenue,
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontStyle: FontStyle.normal),
                                          keyboardType: TextInputType.text,
                                          textInputAction: TextInputAction.next,
                                          focusNode: courseVenueFocus,
                                          onFieldSubmitted: (term) {
                                            _fieldFocusChange(
                                                context,
                                                courseVenueFocus,
                                                courseVenueFocus);
                                          },
                                          textAlign: TextAlign.right,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "Venue",
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    right: 15, bottom: 10),
                                          ),
                                          validators: [
                                            FormBuilderValidators.required(),
                                            FormBuilderValidators.maxLength(10)
                                          ],
                                        )))
                              ]),
                              SizedBox(height: 7),
                              Divider(
                                color: Colors.black,
                              ),
                              SizedBox(height: 17),
                              Text(
                                "${widget.appBarTitle} Date Time",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: Colors.blueGrey[700]),
                              ),
                              SizedBox(height: 22),
                              Row(children: <Widget>[
                                Expanded(
                                    flex: 3,
                                    child: Text(
                                      "Date",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.blueGrey[700]),
                                    )),
                                Expanded(
                                    flex: 7,
                                    child: SizedBox(
                                        height: 32,
                                        child: FormBuilderDateTimePicker(
                                          attribute: "courseDate",
                                          initialValue: timetable
                                                  .courseDate.isNotEmpty
                                              ? DateFormat("yyyy-MM-dd")
                                                  .parse(timetable.courseDate)
                                              : DateTime.now(),
                                          inputType: InputType.date,
                                          format: DateFormat("yyyy-MM-dd"),
                                          textAlign: TextAlign.right,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "2020-12-31",
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    right: 15),
                                          ),
                                          validators: [
                                            FormBuilderValidators.required(),
                                            (val) {
                                              if (timetable
                                                      .startDate.isNotEmpty &&
                                                  val != null) {
                                                DateTime startDate = DateFormat(
                                                        "yyyy-MM-dd")
                                                    .parse(timetable.startDate);
                                                DateTime endDate =
                                                    DateFormat("yyyy-MM-dd")
                                                        .parse(sem.endDate);
                                                DateTime courseDate = val;

                                                if (!["E", "A"]
                                          .contains(widget.coursetype) && (courseDate
                                                        .isBefore(startDate) ||
                                                    courseDate
                                                        .isAfter(endDate))) {
                                                  return "Date must within semester period";
                                                }
                                              }
                                              return null;
                                            }
                                          ],
                                        )))
                              ]),
                              SizedBox(height: 17),
                              Row(children: <Widget>[
                                Expanded(
                                    flex: 3,
                                    child: Text(
                                      "Start Time",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.blueGrey[700]),
                                    )),
                                Expanded(
                                    flex: 7,
                                    child: SizedBox(
                                        height: 32,
                                        child: FormBuilderDateTimePicker(
                                          attribute: "courseStartTime",
                                          initialValue: timetable
                                                  .courseStartTime.isNotEmpty
                                              ? DateFormat("HH:mm").parse(
                                                  timetable.courseStartTime)
                                              : DateTime.now(),
                                          inputType: InputType.time,
                                          format: DateFormat("HH:mm"),
                                          textAlign: TextAlign.right,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "16:00",
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    right: 15, bottom: 10),
                                          ),
                                          validators: [
                                            FormBuilderValidators.required(),
                                            (val) {
                                              if (_fbKey
                                                          .currentState
                                                          .fields[
                                                              'courseEndTime']
                                                          .currentState
                                                          .value !=
                                                      null &&
                                                  val != null) {
                                                DateTime endTime = DateFormat(
                                                        "HH:mm")
                                                    .parse(DateFormat("HH:mm")
                                                        .format(_fbKey
                                                            .currentState
                                                            .fields[
                                                                'courseEndTime']
                                                            .currentState
                                                            .value));
                                                DateTime startTime =
                                                    DateFormat("HH:mm").parse(
                                                        DateFormat("HH:mm")
                                                            .format(val));

                                                if (endTime
                                                        .isBefore(startTime) &&
                                                    !endTime.isAtSameMomentAs(
                                                        startTime)) {
                                                  return "Start time is after end time";
                                                }
                                              }
                                              return null;
                                            }
                                          ],
                                        )))
                              ]),
                              SizedBox(height: 17),
                              Row(children: <Widget>[
                                Expanded(
                                    flex: 3,
                                    child: Text(
                                      "End Time",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.blueGrey[700]),
                                    )),
                                Expanded(
                                    flex: 7,
                                    child: SizedBox(
                                        height: 32,
                                        child: FormBuilderDateTimePicker(
                                          attribute: "courseEndTime",
                                          initialValue:
                                              timetable.courseEndTime.isNotEmpty
                                                  ? DateFormat("HH:mm").parse(
                                                      timetable.courseEndTime)
                                                  : DateTime.now(),
                                          inputType: InputType.time,
                                          format: DateFormat("HH:mm"),
                                          textAlign: TextAlign.right,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: "16:00",
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    right: 15),
                                          ),
                                          validators: [
                                            FormBuilderValidators.required(),
                                            (val) {
                                              if (_fbKey
                                                          .currentState
                                                          .fields[
                                                              'courseStartTime']
                                                          .currentState
                                                          .value !=
                                                      null &&
                                                  val != null) {
                                                DateTime startTime = DateFormat(
                                                        "HH:mm")
                                                    .parse(DateFormat("HH:mm")
                                                        .format(_fbKey
                                                            .currentState
                                                            .fields[
                                                                'courseStartTime']
                                                            .currentState
                                                            .value));
                                                DateTime endTime =
                                                    DateFormat("HH:mm").parse(
                                                        DateFormat("HH:mm")
                                                            .format(val));

                                                if (endTime
                                                        .isBefore(startTime) &&
                                                    !endTime.isAtSameMomentAs(
                                                        startTime)) {
                                                  return "Start time is after end time";
                                                }
                                              }
                                              return null;
                                            }
                                          ],
                                        )))
                              ]),
                              SizedBox(height: 17),
                              Divider(
                                color: Colors.black,
                              ),
                              SizedBox(height: 10),
                              FormBuilderSwitch(
                                label: Text(
                                  'Reminder',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Colors.blueGrey[700]),
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(0),
                                ),
                                attribute: "reminder",
                                initialValue: reminderVal,
                                onChanged: (val) {
                                  reminderVal = val;
                                },
                              ),
                              SizedBox(height: 5),
                              FormBuilderSwitch(
                                label: Text(
                                  'Recurring',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Colors.blueGrey[700]),
                                ),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(0),
                                ),
                                attribute: "recurring",
                                initialValue: recurringVal,
                                onChanged: (val) {
                                  setState(() {
                                    recurringVal = val;
                                    selectedRecType = "N";
                                  });
                                },
                              ),
                              Visibility(
                                  visible: recurringVal,
                                  child: Row(children: <Widget>[
                                    Expanded(
                                        flex: 7,
                                        child: Text(
                                          "Every ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                              color: Colors.blueGrey[700]),
                                        )),
                                    Expanded(
                                        flex: 3,
                                        child: SizedBox(
                                            height: 50,
                                            child: DropdownButton(
                                              style: TextStyle(
                                                  letterSpacing: 1.2,
                                                  color: Colors.blueGrey[700],
                                                  fontWeight: FontWeight.w700),
                                              isExpanded: true,
                                              itemHeight: 70,
                                              value: selectedRecType,
                                              underline: SizedBox(),
                                              onChanged: (val) {
                                                setState(() {
                                                  selectedRecType = val;
                                                });
                                              },
                                              items: TimetableConfig
                                                  .recType.entries
                                                  .map((l) => DropdownMenuItem(
                                                      value: l.key,
                                                      child: Center(
                                                          child:
                                                              Text(l.value))))
                                                  .toList(),
                                            )))
                                  ])),
                              SizedBox(height: 7),
                              Visibility(
                                visible: widget.coursetype != "A",
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Divider(
                                      color: Colors.black,
                                    ),
                                    SizedBox(height: 17),
                                    Text(
                                      "Staff Information",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          color: Colors.blueGrey[700]),
                                    ),
                                    SizedBox(height: 7),
                                    Row(children: <Widget>[
                                      Text(
                                        "Name",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                            color: Colors.blueGrey[700]),
                                      ),
                                      Expanded(
                                          child: SmartSelect<String>.single(
                                              title: '',
                                              modalConfig:
                                                  SmartSelectModalConfig(
                                                      useFilter: true,
                                                      title: 'Staff'),
                                              modalType:
                                                  SmartSelectModalType.fullPage,
                                              value: timetable.lecturerID,
                                              options:
                                                  SmartSelectOption
                                                      .listFrom<String, Staff>(
                                                          source:
                                                              widget.staffdata,
                                                          value: (key, item) =>
                                                              item.sid,
                                                          title: (key, item) =>
                                                              item.name,
                                                          group: (key, item) =>
                                                              item.faculty),
                                              choiceConfig:
                                                  SmartSelectChoiceConfig(
                                                isGrouped: true,
                                                secondaryBuilder:
                                                    (context, item) {
                                                  return CircleAvatar(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .backgroundColor,
                                                    child:
                                                        ImgRetrieve.imgCircle(
                                                            item.value),
                                                  );
                                                },
                                              ),
                                              onChange: (val) {
                                                if (val.isNotEmpty) {
                                                  timetable.lecturerID = val;
                                                  timetable.lecturerName =
                                                      widget.staffdata
                                                          .firstWhere((s) =>
                                                              s.sid == val)
                                                          .name;
                                                }
                                              }))
                                    ]),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Center(
                                  child: MaterialButton(
                                color: Theme.of(context).buttonColor,
                                textColor: Colors.white,
                                padding: const EdgeInsets.all(0.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 2.2,
                                  height: 50,
                                  child: Center(
                                    child: screenImageLoading
                                        ? CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          )
                                        : Text(
                                            'Save Now',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500),
                                          ),
                                  ),
                                ),
                                onPressed: () async {
                                  if (!screenImageLoading) {
                                    if (_fbKey.currentState.saveAndValidate()) {
                                      setState(() {
                                        screenImageLoading = true;
                                      });

                                      if (widget.action == "Modify") {
                                        await widget.timetableController
                                            .removeRecurringTimetable(
                                                widget.timetable.courseCode,
                                                widget.timetable.courseType,
                                                widget
                                                    .timetable.courseStartDate,
                                                widget
                                                    .timetable.courseStartTime,
                                                widget.timetable.startDate,
                                                widget.timetable.recurring);
                                      }

                                      if (widget.coursetype == "A" &&
                                          timetable.courseCode == "Other")
                                        timetable.courseName = _fbKey
                                            .currentState
                                            .fields['courseName']
                                            .currentState
                                            .value;

                                      timetable.courseDate =
                                          DateFormat("yyyy-MM-dd").format(_fbKey
                                              .currentState
                                              .fields['courseDate']
                                              .currentState
                                              .value);

                                      timetable.courseStartDate =
                                          timetable.courseDate;

                                      DateTime _tempCourseDate = _fbKey
                                          .currentState
                                          .fields['courseDate']
                                          .currentState
                                          .value;

                                      DateTime _tempDateStart = DateFormat(
                                              "yyyy-MM-dd HH:mm")
                                          .parse(timetable.courseDate +
                                              " " +
                                              DateFormat("HH:mm").format(_fbKey
                                                  .currentState
                                                  .fields['courseStartTime']
                                                  .currentState
                                                  .value));

                                      DateTime _tempDateEnd = DateFormat(
                                              "yyyy-MM-dd HH:mm")
                                          .parse(timetable.courseDate +
                                              " " +
                                              DateFormat("HH:mm").format(_fbKey
                                                  .currentState
                                                  .fields['courseEndTime']
                                                  .currentState
                                                  .value));

                                      timetable.courseStartTime =
                                          DateFormat("HH:mm")
                                              .format(_tempDateStart);

                                      timetable.courseEndTime =
                                          DateFormat("HH:mm")
                                              .format(_tempDateEnd);

                                      timetable
                                          .courseHrs = double.parse((_tempDateEnd
                                                      .difference(
                                                          _tempDateStart)
                                                      .inMinutes /
                                                  60)
                                              .floor()
                                              .toString() +
                                          "." +
                                          ((_tempDateEnd
                                                              .difference(
                                                                  _tempDateStart)
                                                              .inMinutes %
                                                          60) ==
                                                      30
                                                  ? 5
                                                  : (_tempDateEnd
                                                          .difference(
                                                              _tempDateStart)
                                                          .inMinutes %
                                                      60))
                                              .toString());

                                      if (!["E", "A", "S"]
                                          .contains(widget.coursetype)) {
                                        timetable.courseGroup = int.parse(_fbKey
                                            .currentState
                                            .fields['courseGroup']
                                            .currentState
                                            .value);
                                      }

                                      timetable.courseVenue = _fbKey
                                          .currentState
                                          .fields['courseVenue']
                                          .currentState
                                          .value;

                                      timetable.remind = !reminderVal ? 0 : 1;
                                      timetable.recurring = selectedRecType;

                                      if (recurringVal) {
                                        DateTime _tempEndDate =
                                            DateFormat("yyyy-MM-dd")
                                                .parse(sem.endDate);

                                        if (timetable.recurring == "D") {
                                          int dayDiff = _tempEndDate
                                              .difference(_tempCourseDate)
                                              .inDays;
                                          for (int i = 0; i <= dayDiff; i++) {
                                            _tempCourseDate =
                                                _tempCourseDate.add(Duration(
                                                    days: i == 0 ? 0 : 1));
                                            timetable.courseDate =
                                                DateFormat("yyyy-MM-dd")
                                                    .format(_tempCourseDate);
                                            await widget.timetableController
                                                .insertTimetable(timetable);
                                          }
                                        } else if (timetable.recurring == "W") {
                                          int weekDiff = (_tempEndDate
                                                      .difference(
                                                          _tempCourseDate)
                                                      .inDays /
                                                  7)
                                              .floor();
                                          for (int i = 0; i <= weekDiff; i++) {
                                            _tempCourseDate =
                                                _tempCourseDate.add(Duration(
                                                    days: i == 0 ? 0 : 7));
                                            timetable.courseDate =
                                                DateFormat("yyyy-MM-dd")
                                                    .format(_tempCourseDate);
                                            await widget.timetableController
                                                .insertTimetable(timetable);
                                          }
                                        } else {
                                          for (int i = 0; i == i; i++) {
                                            DateTime _tempCourseDateCheck =
                                                DateFormat("yyyy-M-dd").parse(
                                                    _tempCourseDate.year
                                                            .toString() +
                                                        "-" +
                                                        (_tempCourseDate.month +
                                                                i)
                                                            .toString() +
                                                        "-" +
                                                        _tempCourseDate.day
                                                            .toString());
                                            if (_tempCourseDateCheck.isBefore(
                                                    _tempEndDate.add(
                                                        Duration(days: 1))) &&
                                                _tempCourseDate.day ==
                                                    _tempCourseDateCheck.day) {
                                              timetable.courseDate = DateFormat(
                                                      "yyyy-MM-dd")
                                                  .format(_tempCourseDateCheck);
                                              await widget.timetableController
                                                  .insertTimetable(timetable);
                                            } else if (_tempCourseDateCheck
                                                .isAfter(_tempEndDate)) {
                                              break;
                                            }
                                          }
                                        }
                                      } else {
                                        timetable.recurring = "N";
                                        await widget.timetableController
                                            .insertTimetable(timetable);
                                      }

                                      final prefs =
                                          await SharedPreferences.getInstance();
                                      if (prefs
                                          .getBool('setting_lockScreenImage')) {
                                        /* await TimetableImage.startConvertImage(
                                            DateFormat("yyyy-MM-dd HH:mm")
                                                .parse(DateFormat("yyyy-MM-dd")
                                                        .format(widget
                                                            .selectedDate) +
                                                    " " +
                                                    timetable.courseStartTime)); */
                                      }
                                      ToastMsg.toToast("Saved");
                                      Navigator.of(context).pop();
                                    }
                                  }
                                },
                              )),
                            ],
                          ))
                    ]),
              ),
            )));
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }
}

Future<Semester> sessionToStartDate(String session) async {
  Semester _sem = await SemesterController().getSemesterBySession(session);
  return _sem;
}

Future<Semester> startDateToSession(String startDate) async {
  Semester _sem = await SemesterController().getSemesterByStartDate(startDate);
  return _sem;
}

Future<Timetable> getTimetable(
    String action,
    DateTime selectedDate,
    String startDate,
    String courseCode,
    String courseName,
    String courseType) async {
  Timetable timetable = await TimetableController()
      .getTimetableByKeyList(courseCode, courseName, courseType);
  if (timetable.courseCode.isEmpty) {
    timetable = Timetable(courseCode, courseName, courseType, 0, "", startDate,
        "", "", 0.0, "", "", "", 1, "", "N");
  }
  if (action == "Add") {
    timetable.courseDate = DateFormat("yyyy-MM-dd").format(selectedDate);
    timetable.recurring = "N";
  }

  return timetable;
}
