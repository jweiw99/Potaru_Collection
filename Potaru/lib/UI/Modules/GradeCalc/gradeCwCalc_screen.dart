import 'package:flutter/material.dart';
import 'package:dropdown_menu/dropdown_menu.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:potaru/UI/Bar/appbar.dart';
import 'package:potaru/UI/Modules/GradeCalc/utils/config.dart';
import 'package:potaru/UI/utils/config.dart';
import 'package:potaru/UI/utils/errorMsg.dart';

class GradeCWScreen extends StatefulWidget {
  const GradeCWScreen(
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
  _GradeCWScreenState createState() => _GradeCWScreenState();
}

class _GradeCWScreenState extends State<GradeCWScreen> {
  List<Map<String, String>> dropDropList;
  int dropDownINDEX;

  @override
  void initState() {
    dropDownINDEX = widget.dropDownINDEX;
    dropDropList = widget.dropDropList;
    super.initState();
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
            appBar: subappbarWithdropdown(context, 'CourseWork Marks'),
            backgroundColor: Colors.transparent,
            body: DefaultDropdownMenuController(
                onSelected: (
                    {int menuIndex, int index, int subIndex, dynamic data}) {
                  if (dropDownINDEX != index) {
                    widget.callBackIndex(index);
                  }
                },
                child: Stack(
                  children: <Widget>[
                    Transform(
                        transform: Matrix4.translationValues(0.0, 35, 0.0),
                        child: GradeCWBodyScreen()),
                    Transform(
                        transform: Matrix4.translationValues(0.0, 35, 0.0),
                        child: buildDropdownMenu()),
                    Transform(
                      transform: Matrix4.translationValues(0.0, -15.0, 0.0),
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
                ))));
  }
}

class GradeCWBodyScreen extends StatefulWidget {
  const GradeCWBodyScreen(
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
  _GradeCWBodyScreenState createState() => _GradeCWBodyScreenState();
}

class _GradeCWBodyScreenState extends State<GradeCWBodyScreen> {
  String subjectGrade = "A";
  final cwtotalMarkTextController =
      MaskedTextController(mask: '000', text: "40");
  final cwMarkTextController = MaskedTextController(mask: '00.00', text: "0");
  final finalExamTextController =
      MaskedTextController(mask: '000.00', text: "0");

  @override
  void initState() {
    cwtotalMarkTextController.afterChange = (String previous, String next) {
      int _temp;
      if (next != "")
        _temp = int.parse(next);
      else
        return true;
      if (_temp > 100) {
        cwtotalMarkTextController.updateText("100");
        return false;
      }
      return true;
    };
    cwMarkTextController.afterChange = (String previous, String next) {
      double _temp;
      int _totalCW = int.parse(cwtotalMarkTextController.text);
      if (next != "")
        _temp = double.parse(next);
      else
        return true;
      if (_temp > _totalCW) {
        cwMarkTextController.updateText(_totalCW.toString());
        return false;
      }
      return true;
    };
    super.initState();
  }

  @override
  void dispose() {
    cwtotalMarkTextController.dispose();
    cwMarkTextController.dispose();
    finalExamTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissOnTap(
        child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding: const EdgeInsets.fromLTRB(15, 20, 10, 5),
                    child: Text("CW Calculator",
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            fontSize: ScreenUtil().setSp(43)))),
                Padding(
                    padding: const EdgeInsets.fromLTRB(15, 0, 10, 5),
                    child: Text(
                        "Please enter total coursework mark below.\nEx. Practical: 50, Tutorial: 40, No-Final: 100\nFinal exam marks uses out of 100",
                        style: TextStyle(fontSize: 13))),
                Padding(
                    padding: const EdgeInsets.fromLTRB(15, 20, 10, 5),
                    child: Row(children: <Widget>[
                      Expanded(
                          flex: 4,
                          child: Column(children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Text("Total CW",
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
                                      bottomLeft: const Radius.circular(10.0)),
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
                                  controller: cwtotalMarkTextController,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: <TextInputFormatter>[
                                    LengthLimitingTextInputFormatter(3)
                                  ],
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "CW Marks",
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                  style: TextStyle(
                                      color: Color(0xFF4A6572),
                                      fontWeight: FontWeight.w700,
                                      fontSize: ScreenUtil().setSp(40)),
                                )))
                          ])),
                      Expanded(
                          flex: 7,
                          child: Column(children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Text("Min Final Exam Marks",
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
                                      bottomRight: const Radius.circular(10.0)),
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
                                    controller: finalExamTextController,
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
                    ])),
                Padding(
                    padding: const EdgeInsets.fromLTRB(15, 25, 15, 0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                              child: Column(children: <Widget>[
                            Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Text("CW Earned",
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
                                      topLeft: const Radius.circular(10.0)),
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
                                  controller: cwMarkTextController,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  inputFormatters: <TextInputFormatter>[
                                    LengthLimitingTextInputFormatter(5)
                                  ],
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "CW Marks",
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
                                child: Text("Grade",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                        fontSize: ScreenUtil().setSp(40)))),
                            Container(
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.white,
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
                                child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(50, 0, 10, 0),
                                    child: DropdownButton(
                                      isExpanded: true,
                                      itemHeight: 70,
                                      value: subjectGrade,
                                      hint: Text(
                                        'Grade',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      underline: SizedBox(),
                                      onChanged: (val) {
                                        setState(() {
                                          subjectGrade = val;
                                        });
                                      },
                                      items: gradeMarks.entries
                                          .map((val) => DropdownMenuItem(
                                              value: val.key,
                                              child: Text(
                                                val.key,
                                                style: TextStyle(
                                                    fontSize:
                                                        ScreenUtil().setSp(40)),
                                              )))
                                          .toList(),
                                    )))
                          ])),
                        ])),
                Padding(
                    padding: const EdgeInsets.fromLTRB(15, 5, 15, 0),
                    child: ButtonTheme(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: const Radius.circular(10.0),
                                bottomRight: const Radius.circular(10.0))),
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
                            calcCW(true);
                          },
                        ))),
              ],
            )));
  }

  void calcCW(bool msg) {
    int totalcw = 0;
    double cwEarn = 0.0;
    double totalMark = 100.0;
    int passmark = 40;
    double _tempfinalMark = 0.0;
    double _temptotalfinalMark = 0.0;
    int result = 0;

    if (cwtotalMarkTextController.text.isNotEmpty) {
      totalcw = int.parse(cwtotalMarkTextController.text);
    } else {
      cwtotalMarkTextController.updateText("40");
    }
    if (cwMarkTextController.text.isNotEmpty) {
      cwEarn = double.parse(cwMarkTextController.text);
      if (cwEarn > totalcw) {
        cwEarn = totalcw.toDouble();
        cwMarkTextController.updateText(cwEarn.toString());
      }
    } else {
      cwMarkTextController.updateText("0");
    }

    if (totalMark != totalcw) {
      _temptotalfinalMark = totalMark - totalcw;
      _tempfinalMark = gradeMarks[subjectGrade];
      _tempfinalMark -= cwEarn;
      _tempfinalMark = _tempfinalMark / _temptotalfinalMark;
      _tempfinalMark *= totalMark;
      result = double.parse(_tempfinalMark.toStringAsFixed(2)).ceil();
      if (result < passmark) result = passmark;
    } else {
      result = cwEarn.floor();
    }

    if (result > totalMark ||
        (totalMark == totalcw && result < gradeMarks[subjectGrade].toInt())) {
      if (msg) ErrorMsg.markOver(subjectGrade);
      int mark = gradeMarks[subjectGrade].toInt() - 1;
      List<MapEntry<String, double>> _tempgrade =
          gradeMarks.entries.where((k) => k.value < mark).toList();
      print(_tempgrade);
      if (_tempgrade.length == 0) {
        subjectGrade = "C";
        finalExamTextController.updateText("0");
        if (!msg) ErrorMsg.cannotPass(subjectGrade);
      } else {
        subjectGrade = _tempgrade.first.key;
        calcCW(false);
      }
      setState(() {});
    } else {
      if (totalMark == totalcw) result = 0;
      finalExamTextController.updateText(result.toString());
    }
  }
}
