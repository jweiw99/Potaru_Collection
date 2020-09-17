import 'package:flutter/material.dart';
import 'package:dropdown_menu/dropdown_menu.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:smart_select/smart_select.dart';

import 'package:potaru/UI/utils/config.dart';
import 'package:potaru/UI/Bar/appbar.dart';
import 'package:potaru/Controller/semester.controller.dart';
import 'package:potaru/Controller/cgpa.controller.dart';
import 'package:potaru/Controller/grade.controller.dart';
import 'package:potaru/Model/grade.model.dart';
import 'package:potaru/Model/cgpa.model.dart';
import 'package:potaru/UI/utils/errorMsg.dart';
import 'package:potaru/UI/Modules/GradeCalc/utils/config.dart';
import 'package:potaru/UI/Modules/GradeCalc/utils/calcAlgorithm.dart';

class GradeCalcScreen extends StatefulWidget {
  const GradeCalcScreen(
      {Key key,
      this.animationController,
      this.dropDropList,
      this.dropDownINDEX,
      this.session,
      this.callBackIndex})
      : super(key: key);

  final AnimationController animationController;
  final List<Map<String, String>> dropDropList;
  final int dropDownINDEX;
  final String session;
  final Function(int) callBackIndex;
  @override
  _GradeCalcScreenState createState() => _GradeCalcScreenState();
}

class _GradeCalcScreenState extends State<GradeCalcScreen> {
  List<Map<String, String>> semester = [];
  List<Grade> subject = [];
  List<CGPA> semCGPA = [];
  List<Map<String, String>> dropDropList;

  int dropDownINDEX;
  int semesterINDEX = 0;

  final gpaTextController = TextEditingController();
  final cgpaTextController = TextEditingController();
  final crdHrsTextController = TextEditingController();

  SemesterController semesterController = SemesterController();
  GradeController gradeController = GradeController();
  CGPAController cgpaController = CGPAController();

  Future<List<Map<String, String>>> getData() async {
    semester = semester.length == 0
        ? await semesterController.getSemesterList()
        : semester;
    if (widget.session != "") {
      semesterINDEX =
          semester.indexWhere((item) => item['code'] == widget.session);
    }
    if (semester.length > 0) {
      semCGPA = semCGPA.length == 0
          ? await cgpaController.getSemCGPAList(semester[semesterINDEX]['code'])
          : semCGPA;
      subject = subject.length == 0
          ? await gradeController
              .getSubjectList(semester[semesterINDEX]['code'])
          : subject;
      if (semCGPA[0].creditHrs == 0) {
        await calcCGPA();
      } else {
        updateCGPA(semCGPA[0]);
      }
    }
    return semester;
  }

  @override
  void initState() {
    dropDownINDEX = widget.dropDownINDEX;
    dropDropList = widget.dropDropList;
    super.initState();
  }

  DropdownHeader buildDropdownHeader({DropdownMenuHeadTapCallback onTap}) {
    return DropdownHeader(
        onTap: onTap,
        titles: [semester[semesterINDEX], dropDropList[dropDownINDEX]]);
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
                                    color: Theme.of(context).disabledColor,
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
      DropdownMenuBuilder(
          builder: (BuildContext context) {
            return DropdownListMenu(
                selectedIndex: dropDownINDEX,
                data: dropDropList,
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
                                    color: Theme.of(context).disabledColor,
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
          height: kDropdownMenuItemHeight * dropDropList.length),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF2F3F8),
      child: Scaffold(
          appBar: subappbarWithdropdown(context, 'Grade Calculator'),
          backgroundColor: Colors.transparent,
          body: FutureBuilder<List>(
              future: getData(),
              builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    //print(snapshot.error);
                    return const SizedBox();
                  } else if (semester.length == 0) {
                    ErrorMsg.semesterNotFoundMsg();
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
                          if (menuIndex == 0) {
                            if (semesterINDEX != index) {
                              onSemesterChanged(index);
                            }
                          } else if (menuIndex == 1) {
                            if (dropDownINDEX != index) {
                              widget.callBackIndex(index);
                            }
                          }
                        },
                        child: Stack(
                          children: <Widget>[
                            Transform(
                                transform:
                                    Matrix4.translationValues(0.0, 35, 0.0),
                                child: _buildbody()),
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

  Widget _buildbody() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.fromLTRB(15, 20, 10, 5),
              child: Text("CGPA Calculator",
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      fontSize: ScreenUtil().setSp(43)))),
          Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                        child: Column(children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text("Credit",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  fontSize: ScreenUtil().setSp(40)))),
                      Container(
                          height: 45,
                          margin: EdgeInsets.only(right: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(5.0),
                                bottomLeft: const Radius.circular(5.0)),
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
                            readOnly: true,
                            focusNode: AlwaysDisabledFocusNode(),
                            controller: crdHrsTextController,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                                color: Color(0xFF4A6572),
                                fontWeight: FontWeight.w700,
                                fontSize: ScreenUtil().setSp(40)),
                          )))
                    ])),
                    Expanded(
                        child: Column(children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text("GPA",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  fontSize: ScreenUtil().setSp(40)))),
                      Container(
                          height: 45,
                          margin: EdgeInsets.only(right: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                            readOnly: true,
                            focusNode: AlwaysDisabledFocusNode(),
                            controller: gpaTextController,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                                color: Color(0xFF4A6572),
                                fontWeight: FontWeight.w700,
                                fontSize: ScreenUtil().setSp(40)),
                          )))
                    ])),
                    Expanded(
                        child: Column(children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Text("CGPA",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  fontSize: ScreenUtil().setSp(40)))),
                      Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topRight: const Radius.circular(5.0),
                                bottomRight: const Radius.circular(5.0)),
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
                            readOnly: true,
                            focusNode: AlwaysDisabledFocusNode(),
                            controller: cgpaTextController,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                                color: Color(0xFF4A6572),
                                fontWeight: FontWeight.w700,
                                fontSize: ScreenUtil().setSp(40)),
                          )))
                    ])),
                  ])),
          subject.length != 0
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 10, 5),
                  child: Text("Subject",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          fontSize: ScreenUtil().setSp(43))))
              : SizedBox(),
          subject.length != 0
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 10, 5),
                  child: Text("Select Grade or Swipe left to have more option",
                      style: TextStyle(fontSize: 13)))
              : SizedBox(),
          GradeCalcSubjectListScreen(
              subject: subject,
              callCGPACalc: () {
                calcCGPA();
              })
        ]);
  }

  Future<bool> calcCGPA() async {
    int totalSemGPA = 0;
    int _temptotalSemCreditHrs = 0;
    int totalSemCreditHrs = 0;

    int count = await semesterController
        .getPrevSemesterList()
        .then((val) => val.length);

    for (int i = semester.length - 1; i >= 0; i--) {
      int _semGPA = 0;
      int _semCreditHrs = 0;
      List<Grade> _tempSubjectData =
          await gradeController.getSubjectList(semester[i]['code']);
      _tempSubjectData.forEach((f) {
        if (f.status == 1 && !f.grade.contains("PS")) {
          int _tempGPA = gradeGPA[f.grade] *
              int.parse(f.courseCode.substring(f.courseCode.length - 1));
          totalSemGPA += _tempGPA;
          _semGPA += _tempGPA;
          int _tempCredit =
              int.parse(f.courseCode.substring(f.courseCode.length - 1));
          _temptotalSemCreditHrs += _tempCredit;
          _semCreditHrs += _tempCredit;
        }
        if ((count != semester.length && i == 0 && f.status == 0) ||
            (f.status == 0 && !f.grade.contains("PS"))) return;
        totalSemCreditHrs +=
            int.parse(f.courseCode.substring(f.courseCode.length - 1));
      });
      if (semesterINDEX >= i) {
        double totalCGPA = calcAlgorithm(totalSemGPA, _temptotalSemCreditHrs);
        double totalGPA = calcAlgorithm(_semGPA, _semCreditHrs);

        await cgpaController.updateCGPA(
            CGPA(semester[i]['code'], totalGPA, totalCGPA, totalSemCreditHrs));
        if (i == semesterINDEX) {
          semCGPA[0] =
              CGPA(semester[i]['code'], totalGPA, totalCGPA, totalSemCreditHrs);
          updateCGPA(CGPA(
              semester[i]['code'], totalGPA, totalCGPA, totalSemCreditHrs));
        }
      }
    }
    return true;
  }

  updateCGPA(CGPA cgpadata) {
    gpaTextController.text = cgpadata.gpa.toString();
    cgpaTextController.text = cgpadata.cgpa.toString();
    crdHrsTextController.text = cgpadata.creditHrs.toString();
  }

  onSemesterChanged(int index) async {
    semesterINDEX = index;
    semCGPA = await cgpaController.getSemCGPAList(semester[index]['code']);
    subject = await gradeController.getSubjectList(semester[index]['code']);
    setState(() {});
  }
}

class GradeCalcSubjectListScreen extends StatefulWidget {
  const GradeCalcSubjectListScreen({Key key, this.subject, this.callCGPACalc})
      : super(key: key);

  final List<Grade> subject;
  final Function() callCGPACalc;
  @override
  _GradeCalcSubjectListScreenState createState() =>
      _GradeCalcSubjectListScreenState();
}

class _GradeCalcSubjectListScreenState
    extends State<GradeCalcSubjectListScreen> {
  List<SmartSelectOption<String>> gradeoptions = [];

  final List<RadioModel> radioText = [
    RadioModel(false, "Not Counted Subject"),
    RadioModel(false, "Counted Subject")
  ];
  Map<String, String> courseTypeList = {
    "P": "Practical",
    "T": "Tutorial",
    "F": "-"
  };

  GradeController gradeController = GradeController();

  @override
  void initState() {
    gradeGPA.forEach((g, c) =>
        gradeoptions.add(SmartSelectOption<String>(value: g, title: g)));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView.builder(
            padding: EdgeInsets.only(top: 10, bottom: 100),
            physics: BouncingScrollPhysics(),
            itemCount: widget.subject.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return Slidable(
                  actionPane: SlidableDrawerActionPane(),
                  actionExtentRatio: 0.25,
                  secondaryActions: <Widget>[
                    InkWell(
                        onTap: () {
                          updateCourseStatus(index);
                        },
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                            child: Container(
                              height: double.maxFinite,
                              child: Center(
                                child: Text(
                                    radioText[widget.subject[index].status]
                                        .buttonText,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.white,
                                        //fontWeight: FontWeight.bold,
                                        fontSize: ScreenUtil().setSp(38))),
                              ),
                              decoration: BoxDecoration(
                                color: _onchangeButtonColor(
                                    widget.subject[index].status),
                                border: Border.all(
                                    width: 2.0,
                                    color: _onchangeButtonBorderColor(
                                        widget.subject[index].status)),
                                borderRadius: const BorderRadius.all(
                                    const Radius.circular(5.0)),
                              ),
                            )))
                  ],
                  child: Card(
                      color: Colors.white,
                      elevation: 1.0,
                      child: Padding(
                          padding:
                              const EdgeInsets.only(bottom: 10.0, top: 10.0),
                          child: ListTile(
                            subtitle: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(widget.subject[index].courseCode,
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(40),
                                          color: Theme.of(context)
                                              .textSelectionColor,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.2)),
                                  Text(widget.subject[index].courseName,
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(38),
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.2)),
                                  Text(
                                      courseTypeList[
                                          widget.subject[index].courseType],
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(36),
                                          letterSpacing: 1.2))
                                ]),
                            trailing: SizedBox(
                              height: 100.0,
                              width: 100.0,
                              child: Padding(
                                  child: SmartSelect<String>.single(
                                      title: '',
                                      modalConfig: SmartSelectModalConfig(
                                          title: 'Grades'),
                                      modalType:
                                          SmartSelectModalType.bottomSheet,
                                      value: widget.subject[index].grade,
                                      options: gradeoptions,
                                      onChange: (val) async {
                                        if (widget.subject[index].grade !=
                                            val) {
                                          if (val.contains("PS"))
                                            widget.subject[index].status = 0;
                                          else
                                            widget.subject[index].status = 1;
                                          widget.subject[index].grade = val;
                                          await gradeController.updateSubject(
                                              widget.subject[index]);
                                          await widget.callCGPACalc();
                                          setState(() {});
                                        }
                                      }),
                                  padding: EdgeInsets.fromLTRB(12, 0, 0, 0)),
                            ),
                          ))));
            }));
  }

  Color _onchangeButtonColor(int buttonIndex) {
    if (buttonIndex == 1) {
      return Colors.blue;
    }
    return Colors.grey;
  }

  Color _onchangeButtonBorderColor(int buttonIndex) {
    if (buttonIndex == 1) {
      return Colors.blue;
    }
    return Colors.grey;
  }

  updateCourseStatus(int index) async {
    if (!widget.subject[index].grade.contains("PS")) {
      widget.subject[index].status = widget.subject[index].status == 1 ? 0 : 1;
      await gradeController.updateStatus(widget.subject[index]);
      await widget.callCGPACalc();
      setState(() {});
    }
  }
}

class RadioModel {
  bool isSelected;
  String buttonText;

  RadioModel(this.isSelected, this.buttonText);
}
