import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_menu/dropdown_menu.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:potaru/UI/Modules/GradeCalc/gradeHistDetail_screen.dart';
import 'package:potaru/UI/utils/customeRoute.dart';
import 'package:potaru/Controller/cgpa.controller.dart';
import 'package:potaru/Controller/grade.controller.dart';
import 'package:potaru/Controller/semester.controller.dart';
import 'package:potaru/Model/grade.model.dart';
import 'package:potaru/Model/cgpa.model.dart';
import 'package:potaru/UI/Bar/appbar.dart';
import 'package:potaru/UI/utils/errorMsg.dart';

class GradeHistScreen extends StatefulWidget {
  const GradeHistScreen(
      {Key key,
      this.animationController,
      this.dropDropList,
      this.dropDownINDEX,
      this.callBackIndex})
      : super(key: key);

  final AnimationController animationController;
  final List<Map<String, String>> dropDropList;
  final int dropDownINDEX;
  final Function(int, String) callBackIndex;
  @override
  _GradeHistScreenState createState() => _GradeHistScreenState();
}

class _GradeHistScreenState extends State<GradeHistScreen> {
  List<Map<String, String>> dropDropList;
  int dropDownINDEX;
  List<CGPA> semCGPA = [];
  String session = "";
  List<List<String>> grade = [
    ['A+', 'A', 'A-'],
    ['B+', 'B', "B-"],
    ['C+', 'C'],
    ['F', 'PS']
  ];

  SemesterController semesterController = SemesterController();
  GradeController gradeController = GradeController();
  CGPAController cgpaController = CGPAController();

  @override
  void initState() {
    dropDownINDEX = widget.dropDownINDEX;
    dropDropList = widget.dropDropList;
    super.initState();
  }

  Future<List<CGPA>> getData() async {
    semCGPA =
        semCGPA.length == 0 ? await cgpaController.getCGPAList() : semCGPA;
    int count = await semesterController
        .getPrevSemesterList()
        .then((val) => val.length);
    if (semCGPA.length > 0 && semCGPA.length > count) {
      session = semCGPA.last.session;
      semCGPA.removeLast();
    }
    return semCGPA;
  }

  Future<List<Grade>> getSubjectGrade(String grade) async {
    List<Grade> subject = await gradeController.getSubjectByGradeList(grade);
    subject.removeWhere((item) => item.session == session);
    return subject;
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
          appBar: subappbarWithdropdown(context, 'Grade Report'),
          backgroundColor: Colors.transparent,
          body: FutureBuilder<List>(
              future: getData(),
              builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    //print(snapshot.error);
                    return const SizedBox();
                  } else if (semCGPA.length == 0) {
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
                            widget.callBackIndex(index, "");
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
    var nf = NumberFormat();
    nf.maximumFractionDigits = 4;
    nf.minimumFractionDigits = 1;
    return SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.fromLTRB(5, 15, 5, 5),
                  width: double.infinity,
                  height: 350,
                  child: Card(
                      elevation: 2,
                      color: Colors.white,
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                          child: SfCartesianChart(
                            title: ChartTitle(
                                text: "Academic Performance", borderWidth: 5),
                            plotAreaBorderWidth: 0,
                            primaryXAxis: CategoryAxis(interval: 2),
                            legend: Legend(
                                isVisible: true,
                                position: LegendPosition.bottom),
                            primaryYAxis: NumericAxis(
                                numberFormat: nf,
                                rangePadding: ChartRangePadding.round,
                                axisLine: AxisLine(width: 0),
                                majorTickLines:
                                    MajorTickLines(color: Colors.transparent)),
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: getDefaultLineSeries(),
                          )))),
              Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 10, 5),
                  child: Text("Total Grade",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          fontSize: ScreenUtil().setSp(43)))),
              Padding(
                  padding: const EdgeInsets.fromLTRB(15, 0, 10, 5),
                  child: Text("Press to display subject",
                      style: TextStyle(fontSize: 13))),
              Container(
                  padding: const EdgeInsets.fromLTRB(10, 10, 7, 150),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(grade.length, (index) {
                        return Row(
                            children:
                                List.generate(grade[index].length, (subindex) {
                          return FutureBuilder<List>(
                              future: getSubjectGrade(grade[index][subindex]),
                              builder: (BuildContext context,
                                  AsyncSnapshot<List> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  if (snapshot.hasError) {
                                    //print(snapshot.error);
                                    return const SizedBox();
                                  } else {
                                    return Expanded(
                                        child: InkWell(
                                            onTap: () {
                                              if (snapshot.data.length > 0) {
                                                Navigator.of(context).push(
                                                    MyCustomRoute(
                                                        GradeHistDetailScreen(
                                                  animationController: widget
                                                      .animationController,
                                                  appBarTitle: "Grade " +
                                                      grade[index][subindex],
                                                  subject: snapshot.data,
                                                  callBackIndex:
                                                      widget.callBackIndex,
                                                )));
                                              } else {
                                                ErrorMsg
                                                    .subjectGradeNotFoundMsg();
                                              }
                                            },
                                            child: Container(
                                                height: 45,
                                                margin: EdgeInsets.only(
                                                    right: 3, bottom: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.blueGrey,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey[300],
                                                      offset: Offset(2.0, 2.0),
                                                      blurRadius: 5.0,
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Text(
                                                        grade[index][subindex] +
                                                            ' : ',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            letterSpacing: 2.5,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize:
                                                                ScreenUtil()
                                                                    .setSp(40)),
                                                      ),
                                                      Text(
                                                        snapshot.data.length
                                                            .toString(),
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            letterSpacing: 1.2,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize:
                                                                ScreenUtil()
                                                                    .setSp(40)),
                                                      )
                                                    ]))));
                                  }
                                } else {
                                  return Expanded(
                                      child: Container(
                                          height: 50,
                                          margin: EdgeInsets.only(
                                              right: 3, bottom: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.blueGrey,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey[300],
                                                offset: Offset(2.0, 2.0),
                                                blurRadius: 5.0,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  grade[index][subindex] +
                                                      ' : ',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      letterSpacing: 2.5,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 16),
                                                ),
                                                CircularProgressIndicator()
                                              ])));
                                }
                              });
                        }));
                      })))
            ]));
  }

  List<LineSeries<CGPA, String>> getDefaultLineSeries() {
    return <LineSeries<CGPA, String>>[
      LineSeries<CGPA, String>(
        animationDuration: 1000,
        enableTooltip: true,
        dataSource: semCGPA,
        xValueMapper: (CGPA cgpa, _) => cgpa.session,
        yValueMapper: (CGPA cgpa, _) => cgpa.cgpa,
        width: 2,
        name: 'CGPA',
        markerSettings: MarkerSettings(isVisible: true),
        dataLabelSettings: DataLabelSettings(isVisible: true),
      ),
      LineSeries<CGPA, String>(
        animationDuration: 1000,
        enableTooltip: true,
        dataSource: semCGPA,
        xValueMapper: (CGPA cgpa, _) => cgpa.session,
        yValueMapper: (CGPA cgpa, _) => cgpa.gpa,
        width: 2,
        name: 'GPA',
        markerSettings: MarkerSettings(isVisible: true),
        dataLabelSettings: DataLabelSettings(isVisible: true),
      )
    ];
  }
}
