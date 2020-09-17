import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:potaru/UI/utils/toastMsg.dart';
import 'package:potaru/UI/Modules/Timetable/utils/timetableToImage.dart';
import 'package:wallpaper_manager/wallpaper_manager.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key key, this.animationController}) : super(key: key);
  final AnimationController animationController;

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  Animation animation;
  SharedPreferences prefs;

  @override
  void initState() {
    widget.animationController.forward(from: 0.0);
    super.initState();
  }

  Future<bool> getData() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('setting_attendShortSem') == null) {
      await prefs.setBool('setting_timeReminder', true);
      await prefs.setBool('setting_silentMode', true);
      await prefs.setInt('setting_timeNotifyBefore', 5);
      await prefs.setBool('setting_lockScreenImage', true);
      await prefs.setBool('setting_taskReminder', true);
      await prefs.setInt('setting_attendShortSem', 5);
      await prefs.setInt('setting_attendLongSem', 12);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFF2F3F8),
        body: FutureBuilder<bool>(
            future: getData(),
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  //print(snapshot.error);
                  return SizedBox(
                      child: Center(
                          child: Text("Data Error",
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(43)))));
                } else {
                  return KeyboardDismissOnTap(
                      child: SingleChildScrollView(
                          physics: BouncingScrollPhysics(),
                          child: AnimatedBuilder(
                              animation: widget.animationController,
                              builder: (BuildContext context, Widget child) {
                                animation = Tween<double>(begin: 0.0, end: 1.0)
                                    .animate(CurvedAnimation(
                                        parent: widget.animationController,
                                        curve: Interval((1 / 2) * 1, 1.0,
                                            curve: Curves.fastOutSlowIn)));
                                return FadeTransition(
                                    opacity: animation,
                                    child: Transform(
                                        transform: Matrix4.translationValues(
                                            0.0,
                                            30 * (1.0 - animation.value),
                                            0.0),
                                        child:
                                            BuildSettingScreen(prefs: prefs)));
                              })));
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
            }));
  }
}

class BuildSettingScreen extends StatefulWidget {
  const BuildSettingScreen({Key key, this.prefs}) : super(key: key);

  final SharedPreferences prefs;

  @override
  _BuildSettingScreenState createState() => _BuildSettingScreenState();
}

class _BuildSettingScreenState extends State<BuildSettingScreen> {
  GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  bool imageConvertLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(20, 100, 20, 80),
        child: FormBuilder(
            key: _fbKey,
            autovalidate: true,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Timetable",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          fontSize: ScreenUtil().setSp(43))),
                  SizedBox(height: 10),
                  FormBuilderSwitch(
                    label: Text(
                      'Reminder',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: ScreenUtil().setSp(40),
                          color: Colors.blueGrey[700]),
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(0),
                    ),
                    attribute: "timeReminder",
                    initialValue: widget.prefs.getBool('setting_timeReminder'),
                    onChanged: (val) {
                      widget.prefs.setBool('setting_timeReminder', val);
                      ToastMsg.toToast("Saved");
                    },
                  ),
                  FormBuilderSwitch(
                    label: Text(
                      'Silent Mode',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: ScreenUtil().setSp(40),
                          color: Colors.blueGrey[700]),
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(0),
                    ),
                    attribute: "silentMode",
                    initialValue: widget.prefs.getBool('setting_silentMode'),
                    onChanged: (val) {
                      widget.prefs.setBool('setting_silentMode', val);
                      ToastMsg.toToast("Saved");
                    },
                  ),
                  SizedBox(height: 10),
                  Row(children: <Widget>[
                    Expanded(
                        flex: 3,
                        child: Text(
                          'Notify Before Event Start',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: ScreenUtil().setSp(40),
                              color: Colors.blueGrey[700]),
                        )),
                    Expanded(
                        flex: 7,
                        child: SizedBox(
                            height: 45,
                            child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: FormBuilderTextField(
                                  attribute: "NotifyBefore",
                                  initialValue: widget.prefs
                                      .getInt('setting_timeNotifyBefore')
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(40),
                                      fontStyle: FontStyle.normal),
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Minutes",
                                    contentPadding: const EdgeInsets.only(
                                        right: 15, bottom: 10),
                                  ),
                                  validators: [
                                    FormBuilderValidators.numeric(),
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.max(30),
                                    FormBuilderValidators.maxLength(2)
                                  ],
                                  onFieldSubmitted: (val) {
                                    if (val.isNotEmpty) {
                                      widget.prefs.setInt(
                                          'setting_timeNotifyBefore',
                                          int.parse(val));
                                      ToastMsg.toToast("Saved");
                                    }
                                  },
                                ))))
                  ]),
                  FormBuilderSwitch(
                    label: Text(
                      'Lock Screen',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: ScreenUtil().setSp(40),
                          color: Colors.blueGrey[700]),
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(0),
                    ),
                    attribute: "lockScreen",
                    initialValue:
                        widget.prefs.getBool('setting_lockScreenImage'),
                    onChanged: (val) {
                      widget.prefs.setBool('setting_lockScreenImage', val);
                      ToastMsg.toToast("Saved");
                      setState(() {});
                    },
                  ),
                  Visibility(
                      visible: widget.prefs.getBool('setting_lockScreenImage'),
                      child: Row(children: <Widget>[
                        Expanded(
                            flex: 3,
                            child: Text(
                              'Refresh Lock Screen Image',
                              style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: ScreenUtil().setSp(40),
                                  color: Colors.blueGrey[700]),
                            )),
                        Expanded(
                            flex: 7,
                            child: !imageConvertLoading
                                ? IconButton(
                                    alignment: Alignment.centerRight,
                                    icon: Icon(Icons.refresh),
                                    color: Theme.of(context).buttonColor,
                                    padding: const EdgeInsets.only(right: 15),
                                    highlightColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    onPressed: () async {
                                      setState(() {
                                        imageConvertLoading = true;
                                      });
                                      await TimetableImage.startConvertImage(DateTime.now());
                                      ToastMsg.toToast("Refreshed");
                                      setState(() {
                                        imageConvertLoading = false;
                                      });
                                    })
                                : Container(
                                    height: 48,
                                    child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                            width: 15,
                                            height: 15,
                                            margin: const EdgeInsets.only(
                                                top: 5, right: 18),
                                            child:
                                                CircularProgressIndicator()))))
                      ])),
                  SizedBox(height: 30),
                  Text("Task",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          fontSize: ScreenUtil().setSp(43))),
                  SizedBox(height: 10),
                  FormBuilderSwitch(
                    label: Text(
                      'Reminder',
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: ScreenUtil().setSp(40),
                          color: Colors.blueGrey[700]),
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(0),
                    ),
                    attribute: "taskReminder",
                    initialValue: widget.prefs.getBool('setting_taskReminder'),
                    onChanged: (val) {
                      widget.prefs.setBool('setting_taskReminder', val);
                      ToastMsg.toToast("Saved");
                    },
                  ),
                  SizedBox(height: 30),
                  Text("Attendance Calculation",
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          fontSize: ScreenUtil().setSp(43))),
                  SizedBox(height: 20),
                  Row(children: <Widget>[
                    Expanded(
                        flex: 3,
                        child: Text(
                          'Short Semester',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: ScreenUtil().setSp(40),
                              color: Colors.blueGrey[700]),
                        )),
                    Expanded(
                        flex: 7,
                        child: SizedBox(
                            height: 45,
                            child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: FormBuilderTextField(
                                  attribute: "shortSem",
                                  initialValue: widget.prefs
                                      .getInt('setting_attendShortSem')
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(40),
                                      fontStyle: FontStyle.normal),
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Week No",
                                    contentPadding: const EdgeInsets.only(
                                        right: 15, bottom: 10),
                                  ),
                                  validators: [
                                    FormBuilderValidators.numeric(),
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.max(7),
                                    FormBuilderValidators.maxLength(1)
                                  ],
                                  onFieldSubmitted: (val) {
                                    if (val.isNotEmpty) {
                                      widget.prefs.setInt(
                                          'setting_attendShortSem',
                                          int.parse(val));
                                      ToastMsg.toToast("Saved");
                                    }
                                  },
                                ))))
                  ]),
                  SizedBox(height: 5),
                  Row(children: <Widget>[
                    Expanded(
                        flex: 3,
                        child: Text(
                          'Long Semester',
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: ScreenUtil().setSp(40),
                              color: Colors.blueGrey[700]),
                        )),
                    Expanded(
                        flex: 7,
                        child: SizedBox(
                            height: 45,
                            child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: FormBuilderTextField(
                                  attribute: "longSem",
                                  initialValue: widget.prefs
                                      .getInt('setting_attendLongSem')
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(40),
                                      fontStyle: FontStyle.normal),
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Week No",
                                    contentPadding: const EdgeInsets.only(
                                        right: 15, bottom: 10),
                                  ),
                                  validators: [
                                    FormBuilderValidators.numeric(),
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.max(14),
                                    FormBuilderValidators.maxLength(2)
                                  ],
                                  onFieldSubmitted: (val) {
                                    if (val.isNotEmpty) {
                                      widget.prefs.setInt(
                                          'setting_attendLongSem',
                                          int.parse(val));
                                      ToastMsg.toToast("Saved");
                                    }
                                  },
                                ))))
                  ]),
                ])));
  }
}
