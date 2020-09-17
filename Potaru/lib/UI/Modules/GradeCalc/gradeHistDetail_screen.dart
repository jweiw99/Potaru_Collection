import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:potaru/Model/grade.model.dart';
import 'package:potaru/UI/Bar/appbar.dart';

class GradeHistDetailScreen extends StatelessWidget {
  const GradeHistDetailScreen(
      {Key key,
      this.animationController,
      this.callBackIndex,
      this.subject,
      this.appBarTitle})
      : super(key: key);

  final AnimationController animationController;
  final String appBarTitle;
  final List<Grade> subject;
  final Function(int, String) callBackIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color(0xFFF2F3F8),
        child: Scaffold(
            appBar: subappBar(context, appBarTitle, 2),
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.fromLTRB(15, 20, 10, 10),
                          child: Text("Subject List",
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  fontSize: ScreenUtil().setSp(45)))),
                      Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 10, 5),
                          child: Text("Long Press to go grade calculator",
                              style: TextStyle(fontSize: 13))),
                      Padding(
                          padding: const EdgeInsets.only(top: 15, bottom: 25),
                          child: Column(
                              children:
                                  List.generate(subject.length, (subIndex) {
                            return InkWell(
                                onLongPress: () {
                                  callBackIndex(0, subject[subIndex].session);
                                  Navigator.of(context).pop();
                                },
                                child: Card(
                                    color: Colors.white,
                                    elevation: 1.0,
                                    child: Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 15.0, top: 15.0),
                                        child: ListTile(
                                            subtitle: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                              Text(subject[subIndex].courseCode,
                                                  style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(40),
                                                      color: Theme.of(context)
                                                          .textSelectionColor,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 1.2)),
                                              Text(subject[subIndex].courseName,
                                                  style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(40),
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      letterSpacing: 1.2)),
                                              Text(
                                                  "Session " +
                                                      subject[subIndex].session,
                                                  style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(40),
                                                      letterSpacing: 1.2))
                                            ])))));
                          })))
                    ]))));
  }
}
