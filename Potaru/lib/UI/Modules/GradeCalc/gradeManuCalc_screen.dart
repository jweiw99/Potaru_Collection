import 'package:flutter/material.dart';
import 'package:dropdown_menu/dropdown_menu.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:potaru/Controller/cgpa.controller.dart';
import 'package:potaru/Controller/grade.controller.dart';
import 'package:potaru/Controller/semester.controller.dart';
import 'package:potaru/Model/cgpa.model.dart';
import 'package:potaru/Model/grade.model.dart';
import 'package:potaru/UI/Bar/appbar.dart';
import 'package:potaru/UI/Modules/GradeCalc/utils/calcAlgorithm.dart';
import 'package:potaru/UI/Modules/GradeCalc/utils/config.dart';
import 'package:potaru/UI/utils/config.dart';
import 'package:potaru/UI/utils/errorMsg.dart';

class GradeManualScreen extends StatefulWidget {
  const GradeManualScreen(
      {Key key,
      this.animationController,
      this.dropDropList,
      this.dropDownINDEX,
      this.callBackIndex})
      : super(key: key);

  final AnimationController animationController;
  final List<Map<String, String>> dropDropList;
  final int dropDownINDEX;
  final Function(int) callBackIndex;
  @override
  _GradeManualScreenState createState() => _GradeManualScreenState();
}

class _GradeManualScreenState extends State<GradeManualScreen> {
  List<Map<String, String>> dropDropList;
  int dropDownINDEX;
  List<CGPA> semCGPA = [];
  List<Map<String, String>> semester = [];
  List<Map<String, String>> prevsemester = [];

  final cgpaTextController = MaskedTextController(mask: '0.0000', text: "0.0");
  final crdHrsTextController = MaskedTextController(mask: '000', text: "0");
  final newcgpaTextController =
      MaskedTextController(mask: '0.0000', text: '0.0');
  final newgpaTextController =
      MaskedTextController(mask: '0.0000', text: '0.0');

  SemesterController semesterController = SemesterController();
  GradeController gradeController = GradeController();
  CGPAController cgpaController = CGPAController();

  @override
  void initState() {
    dropDownINDEX = widget.dropDownINDEX;
    dropDropList = widget.dropDropList;
    cgpaTextController.afterChange = (String previous, String next) {
      double _temp;
      if (next != "")
        _temp = double.parse(next);
      else
        return true;
      if (_temp > 4.0) {
        cgpaTextController.updateText("4.0");
        return false;
      }
      return true;
    };
    super.initState();
  }

  @override
  void dispose() {
    cgpaTextController.dispose();
    crdHrsTextController.dispose();
    newcgpaTextController.dispose();
    newgpaTextController.dispose();
    super.dispose();
  }

  Future<List<Map<String, String>>> getData() async {
    semester = semester.length == 0
        ? await semesterController.getSemesterList()
        : semester;
    /* prevsemester = prevsemester.length == 0
        ? await semesterController.getPrevSemesterList()
        : prevsemester;
    if (semester.length > 0 && semester.length > prevsemester.length) {
      semester.removeAt(0);
    } */

    if (semester.length > 0) {
      if (semCGPA.length == 0) {
        semCGPA = await cgpaController.getSemCGPAList(semester[0]['code']);
        int totalSemCreditHrs = 0;
        for (int i = semester.length - 1; i >= 0; i--) {
          List<Grade> _tempSubjectData =
              await gradeController.getSubjectList(semester[i]['code']);
          _tempSubjectData.forEach((f) {
            if (f.status == 1 && !f.grade.contains("PS")) {
              totalSemCreditHrs +=
                  int.parse(f.courseCode.substring(f.courseCode.length - 1));
            }
          });
        }
        semCGPA[0].creditHrs = totalSemCreditHrs;
      }
      updateCGPA(semCGPA[0]);
    } else {
      semCGPA.add(CGPA('', 0.0, 0.0, 0));
      updateCGPA(semCGPA[0]);
    }
    return semester;
  }

  DropdownHeader buildDropdownHeader({DropdownMenuHeadTapCallback onTap}) {
    return DropdownHeader(onTap: onTap, titles: [dropDropList[dropDownINDEX]]);
  }

  DropdownMenu buildDropdownMenu() {
    return DropdownMenu(maxMenuHeight: kDropdownMenuItemHeight * 6, menus: [
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
          resizeToAvoidBottomInset: false,
          appBar: subappbarWithdropdown(context, 'Manual Calculator'),
          backgroundColor: Colors.transparent,
          body: FutureBuilder<List>(
              future: getData(),
              builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    //print(snapshot.error);
                    return const SizedBox();
                  } else if (semester.length == 0) {
                    ErrorMsg.gradeNotFoundMsg();
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
                          if (dropDownINDEX != index) {
                            widget.callBackIndex(index);
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
    return KeyboardDismissOnTap(
        child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
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
                      padding: const EdgeInsets.fromLTRB(15, 0, 10, 5),
                      child: Text(
                          "Please exclude PS/FL/Duplicate subject from total credit.",
                          style: TextStyle(fontSize: 13))),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
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
                                        topLeft: const Radius.circular(10.0),
                                        bottomLeft:
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
                                    controller: crdHrsTextController,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.done,
                                    inputFormatters: <TextInputFormatter>[
                                      LengthLimitingTextInputFormatter(3)
                                    ],
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Credit Hrs",
                                      hintStyle: TextStyle(color: Colors.grey),
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
                                    controller: cgpaTextController,
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    textInputAction: TextInputAction.done,
                                    inputFormatters: <TextInputFormatter>[
                                      LengthLimitingTextInputFormatter(6)
                                    ],
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "CGPA",
                                      hintStyle: TextStyle(color: Colors.grey),
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
                                    color: Colors.blueGrey[50],
                                    borderRadius: BorderRadius.only(
                                        topRight: const Radius.circular(10.0)),
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
                                      controller: newgpaTextController,
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                      style: TextStyle(
                                          color: Color(0xFF4A6572),
                                          fontWeight: FontWeight.w700,
                                          fontSize: ScreenUtil().setSp(40)),
                                    ),
                                  )),
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
                                    color: Colors.blueGrey[50],
                                    borderRadius: BorderRadius.only(
                                        topRight: const Radius.circular(10.0),
                                        bottomRight:
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
                                      readOnly: true,
                                      focusNode: AlwaysDisabledFocusNode(),
                                      controller: newcgpaTextController,
                                      textAlign: TextAlign.center,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                      style: TextStyle(
                                          color: Color(0xFF4A6572),
                                          fontWeight: FontWeight.w700,
                                          fontSize: ScreenUtil().setSp(40)),
                                    ),
                                  )),
                            ]))
                          ])),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(15, 25, 10, 5),
                      child: Text("Subject",
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              fontSize: ScreenUtil().setSp(43)))),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(15, 0, 10, 5),
                      child: Text("Enter credit and grade below to calculate.",
                          style: TextStyle(fontSize: 13))),
                  GradeManualSubjectListScreen(
                    calcCGPA: (subjectList) => calcCGPA(subjectList),
                  )
                ])));
  }

  void calcCGPA(List<Map<String, String>> subjectList) {
    int totalSemGPA = 0;
    int totalSemCreditHrs = 0;
    int totalALLGPA = 0;
    int totalAllCredit = 0;

    subjectList.forEach((f) {
      totalSemGPA += gradeGPA[f['grade']] * int.parse(f['credit']);
      totalSemCreditHrs += int.parse(f['credit']);
    });
    totalAllCredit += int.parse(
        crdHrsTextController.text.isNotEmpty ? crdHrsTextController.text : "0");
    totalALLGPA += (double.parse(cgpaTextController.text.isNotEmpty
                ? cgpaTextController.text
                : "0.0") *
            10000)
        .toInt();
    totalALLGPA *= totalAllCredit;
    totalAllCredit += totalSemCreditHrs;
    totalALLGPA += totalSemGPA * 100;

    double totalGPA = calcAlgorithm(totalSemGPA, totalSemCreditHrs);
    double totalCGPA = calcAlgorithm2(totalALLGPA, totalAllCredit);
    updateResult(CGPA('', totalGPA, totalCGPA, totalSemCreditHrs));
  }

  void updateResult(CGPA cgpadata) {
    newgpaTextController.text = cgpadata.gpa.toString();
    newcgpaTextController.text = cgpadata.cgpa.toString();
  }

  void updateCGPA(CGPA cgpadata) {
    cgpaTextController.text = cgpadata.cgpa.toString();
    crdHrsTextController.text = cgpadata.creditHrs.toString();
  }
}

class GradeManualSubjectListScreen extends StatefulWidget {
  const GradeManualSubjectListScreen({Key key, this.calcCGPA})
      : super(key: key);

  final Function(List<Map<String, String>>) calcCGPA;

  @override
  _GradeManualSubjectListScreenState createState() =>
      _GradeManualSubjectListScreenState();
}

class _GradeManualSubjectListScreenState
    extends State<GradeManualSubjectListScreen> {
  List<Map<String, String>> subjectList = [
    {"credit": "0", "grade": "A+"}
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(15, 10, 10, 150),
        child: Column(children: <Widget>[
          Column(
              children: List.generate(subjectList.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                      flex: 4,
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
                          child: Center(
                              child: TextField(
                            textAlign: TextAlign.center,
                            controller: TextEditingController()
                              ..text = subjectList[index]['credit'],
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            inputFormatters: <TextInputFormatter>[
                              LengthLimitingTextInputFormatter(3),
                              WhitelistingTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              hintText: "Credit",
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                            style: TextStyle(
                                color: Color(0xFF4A6572),
                                fontWeight: FontWeight.w700,
                                fontSize: ScreenUtil().setSp(40)),
                            onChanged: (val) {
                              if (val.isEmpty) val = "0";
                              subjectList[index]['credit'] = val;
                            },
                          )))),
                  Expanded(
                      flex: 4,
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
                              padding: const EdgeInsets.fromLTRB(30, 0, 10, 0),
                              child: DropdownButton(
                                isExpanded: true,
                                itemHeight: 70,
                                value: subjectList[index]['grade'],
                                hint: Text(
                                  'Grade',
                                  style: TextStyle(
                                    fontSize: ScreenUtil().setSp(40),
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                underline: SizedBox(),
                                onChanged: (val) {
                                  setState(() {
                                    subjectList[index]['grade'] = val;
                                  });
                                },
                                items: gradeGPA.entries
                                    .where((val) => val.key != "PS")
                                    .map((val) => DropdownMenuItem(
                                        value: val.key,
                                        child: Text(
                                          val.key,
                                          style: TextStyle(
                                              fontSize: ScreenUtil().setSp(40)),
                                        )))
                                    .toList(),
                              )))),
                  Expanded(
                      flex: 2,
                      child: Container(
                          height: 35,
                          width: 35,
                          child: Center(
                            child: index == 0
                                ? InkWell(
                                    onTap: () => addRow(),
                                    child: CircleAvatar(
                                        radius: 25,
                                        backgroundColor:
                                            Theme.of(context).buttonColor,
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 25,
                                        )))
                                : InkWell(
                                    onTap: () => removeRow(index),
                                    child: CircleAvatar(
                                        radius: 25,
                                        backgroundColor: Colors.red,
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 25,
                                        ))),
                          )))
                ],
              ),
            );
          })),
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
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
                      "Calculate Now",
                      style: TextStyle(fontSize: ScreenUtil().setSp(40)),
                    ),
                    onPressed: () {
                      widget.calcCGPA(subjectList);
                    },
                  ))),
        ]));
  }

  void addRow() {
    subjectList.add({"credit": "0", "grade": "A+"});
    setState(() {});
  }

  void removeRow(int index) {
    subjectList.removeAt(index);
    setState(() {});
  }
}
