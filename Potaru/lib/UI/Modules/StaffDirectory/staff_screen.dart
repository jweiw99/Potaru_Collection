import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:potaru/UI/Bar/appbar.dart';
import 'package:potaru/Model/staff.model.dart';
import 'package:potaru/UI/Modules/StaffDirectory/utils/staffImgRetrieve.dart';

class StaffScreen extends StatelessWidget {
  const StaffScreen(
      {Key key, this.animationController, this.staff, this.appBarTitle})
      : super(key: key);

  final AnimationController animationController;
  final String appBarTitle;
  final Staff staff;

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color(0xFFF2F3F8),
        child: Scaffold(
            appBar: subappBar(context, appBarTitle, 2),
            backgroundColor: Colors.transparent,
            body: Container(
                child: ListView(
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                        height: 210.0,
                        child: Padding(
                            padding: EdgeInsets.only(top: 5.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(
                                  width: 130.0,
                                  height: 150.0,
                                  child:
                                      Center(child: ImgRetrieve.img(staff.sid)),
                                )
                              ],
                            ))),
                    Container(
                      child: Padding(
                        padding: EdgeInsets.only(left: 25.0, right: 25.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(top: 0.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'Name',
                                          style: TextStyle(
                                              fontSize: ScreenUtil().setSp(40),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.only(top: 2.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Flexible(
                                        child: Text(staff.name,
                                            style: TextStyle(
                                                fontSize:
                                                    ScreenUtil().setSp(40)))),
                                  ],
                                )),
                            staff.faculty != ""
                                ? Column(children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(top: 10.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Text(
                                              'Faculty / Institute / Centre / Division',
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(40),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )),
                                    Padding(
                                        padding: EdgeInsets.only(top: 2.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Flexible(
                                                child: Text(staff.faculty,
                                                    style: TextStyle(
                                                        fontSize: ScreenUtil()
                                                            .setSp(40)))),
                                          ],
                                        ))
                                  ])
                                : SizedBox(),
                            staff.department != ""
                                ? Column(children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(top: 10.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Text(
                                              'Department / Unit',
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(40),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )),
                                    Padding(
                                        padding: EdgeInsets.only(top: 2.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Flexible(
                                                child: Text(staff.department,
                                                    style: TextStyle(
                                                        fontSize: ScreenUtil()
                                                            .setSp(40)))),
                                          ],
                                        ))
                                  ])
                                : SizedBox(),
                            staff.designation != ""
                                ? Column(children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(top: 10.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Text(
                                              'Designation',
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(40),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )),
                                    Padding(
                                        padding: EdgeInsets.only(top: 2.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Flexible(
                                                child: Text(staff.designation,
                                                    style: TextStyle(
                                                        fontSize: ScreenUtil()
                                                            .setSp(40)))),
                                          ],
                                        ))
                                  ])
                                : SizedBox(),
                            staff.administrativePost1 != "" ||
                                    staff.administrativePost1 != ""
                                ? Column(children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(top: 10.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Text(
                                              'Administrative Post',
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(40),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )),
                                    staff.administrativePost1 != ""
                                        ? Padding(
                                            padding: EdgeInsets.only(top: 2.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                Flexible(
                                                    child: Text(
                                                        staff
                                                            .administrativePost1,
                                                        style: TextStyle(
                                                            fontSize:
                                                                ScreenUtil()
                                                                    .setSp(
                                                                        40)))),
                                              ],
                                            ))
                                        : SizedBox(),
                                    staff.administrativePost2 != ""
                                        ? Padding(
                                            padding: EdgeInsets.only(top: 2.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                Flexible(
                                                    child: Text(
                                                        staff
                                                            .administrativePost2,
                                                        style: TextStyle(
                                                            fontSize:
                                                                ScreenUtil()
                                                                    .setSp(
                                                                        40)))),
                                              ],
                                            ))
                                        : SizedBox()
                                  ])
                                : SizedBox(),
                            staff.roomNo != ""
                                ? Column(children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(top: 10.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Text(
                                              'Room Number',
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(40),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )),
                                    Padding(
                                        padding: EdgeInsets.only(top: 2.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Flexible(
                                                child: Text(staff.roomNo,
                                                    style: TextStyle(
                                                        fontSize: ScreenUtil()
                                                            .setSp(40)))),
                                          ],
                                        ))
                                  ])
                                : SizedBox(),
                            staff.telNo1 != "" || staff.telNo2 != ""
                                ? Column(children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(top: 10.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Text(
                                              'Telephone No',
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(40),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )),
                                    staff.telNo1 != ""
                                        ? Padding(
                                            padding: EdgeInsets.only(top: 2.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                Flexible(
                                                    child: Text(staff.telNo1,
                                                        style: TextStyle(
                                                            fontSize:
                                                                ScreenUtil()
                                                                    .setSp(
                                                                        40)))),
                                              ],
                                            ))
                                        : SizedBox(),
                                    staff.telNo2 != ""
                                        ? Padding(
                                            padding: EdgeInsets.only(top: 2.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: <Widget>[
                                                Flexible(
                                                    child: Text(staff.telNo2,
                                                        style: TextStyle(
                                                            fontSize:
                                                                ScreenUtil()
                                                                    .setSp(
                                                                        40)))),
                                              ],
                                            ))
                                        : SizedBox()
                                  ])
                                : SizedBox(),
                            staff.email != ""
                                ? Column(children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(top: 10.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Text(
                                              'Email Address',
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(40),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )),
                                    Padding(
                                        padding: EdgeInsets.only(top: 2.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Flexible(
                                                child: InkWell(
                                              child: Text(staff.email,
                                                  style: TextStyle(
                                                      fontSize: ScreenUtil()
                                                          .setSp(40),
                                                      color: Theme.of(context)
                                                          .primaryColor)),
                                              onTap: () => launch(
                                                  'mailto:${staff.email}'),
                                            )),
                                          ],
                                        ))
                                  ])
                                : SizedBox(),
                            staff.proQualification != ""
                                ? Column(children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(top: 10.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Text(
                                              'Professional Qualification',
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(40),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )),
                                    Padding(
                                        padding: EdgeInsets.only(top: 2.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Flexible(
                                                child: Text(
                                                    staff.proQualification,
                                                    style: TextStyle(
                                                        fontSize: ScreenUtil()
                                                            .setSp(40)))),
                                          ],
                                        ))
                                  ])
                                : SizedBox(),
                            staff.qualification != ""
                                ? Column(children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(top: 10.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Text(
                                              'Qualification ',
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(40),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )),
                                    Padding(
                                        padding: EdgeInsets.only(top: 2.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Flexible(
                                                child: Text(staff.qualification,
                                                    style: TextStyle(
                                                        fontSize: ScreenUtil()
                                                            .setSp(40)))),
                                          ],
                                        ))
                                  ])
                                : SizedBox(),
                            staff.expertise != ""
                                ? Column(children: <Widget>[
                                    Padding(
                                        padding: EdgeInsets.only(top: 10.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Text(
                                              'Area of Expertise',
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(40),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )),
                                    Padding(
                                        padding: EdgeInsets.only(top: 2.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: <Widget>[
                                            Flexible(
                                                child: Text(
                                              staff.expertise,
                                              style: TextStyle(
                                                  fontSize:
                                                      ScreenUtil().setSp(40)),
                                            )),
                                          ],
                                        ))
                                  ])
                                : SizedBox(),
                            SizedBox(height: 30)
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ))));
  }
}
