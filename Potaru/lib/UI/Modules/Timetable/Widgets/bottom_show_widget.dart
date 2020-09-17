import 'dart:math';
import 'package:flutter/material.dart';
import 'package:circle_list/circle_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:potaru/Model/timetable.model.dart';

import 'package:potaru/UI/Modules/Timetable/Widgets/addEvent.dart';
import 'package:potaru/UI/Modules/Timetable/utils/config.dart';

class BottomShowWidget extends StatefulWidget {
  BottomShowWidget({this.onExit, this.selectedDate});

  final VoidCallback onExit;
  final DateTime selectedDate;

  @override
  _BottomShowWidgetState createState() => _BottomShowWidgetState();
}

class _BottomShowWidgetState extends State<BottomShowWidget>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  List<String> buttonList =
      TimetableConfig.courseType.entries.map((ent) => ent.value).toList();

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine));
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final minSize = min(size.height, size.width);
    final circleSize = minSize;
    final Offset circleOrigin = Offset((size.width - circleSize) / 2, 0);

    return WillPopScope(
      onWillPop: () {
        doExit(context, _controller);
        return Future.value(false);
      },
      child: GestureDetector(
        onTap: () {
          doExit(context, _controller);
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            width: size.width,
            height: size.height,
            child: Stack(
              children: <Widget>[
                Positioned(
                  bottom: 20,
                  left: size.width / 2 - 28,
                  child: AnimatedBuilder(
                      animation: _animation,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            shape: BoxShape.circle),
                      ),
                      builder: (ctx, child) {
                        return Transform.scale(
                          scale: (max(size.height, size.width) / 28) *
                              (_animation.value),
                          child: child,
                        );
                      }),
                ),
                Positioned(
                  left: circleOrigin.dx,
                  top: circleOrigin.dy,
                  child: AnimatedBuilder(
                    animation: _animation,
                    child: CircleList(
                      origin: Offset(0, 0),
                      showInitialAnimation: true,
                      children: List.generate(buttonList.length, (index) {
                        return RaisedButton(
                            onPressed: () {
                              doExit(context, _controller);
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return AddEventScreen(
                                    action: "Add",
                                    type: TimetableConfig.courseType.entries
                                        .firstWhere((val) =>
                                            val.value == buttonList[index])
                                        .key,
                                    timetable: Timetable("", "", "", 0, "", "",
                                        "", "", 0.0, "", "", "", 1, "", "N"),
                                    selectedDate: widget.selectedDate,
                                    appBarTitle: buttonList[index]);
                              }));
                            },
                            shape: CircleBorder(),
                            padding: const EdgeInsets.all(35.0),
                            elevation: 5,
                            color: Colors.white,
                            textColor: Theme.of(context).textSelectionColor,
                            child: Text(buttonList[index],
                                style: TextStyle(
                                    fontSize: ScreenUtil().setSp(32))));
                      }),
                      outerCircleColor: Colors.transparent,
                      innerCircleColor: Colors.transparent,
                      innerCircleRotateWithChildren: true,
                      /*
                      centerWidget: GestureDetector(
                          onTap: () {
                            doExit(context, _controller);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 5.5,
                            height: MediaQuery.of(context).size.width / 5.5,
                            decoration: BoxDecoration(
                              color: Color(0xFF2633C5),
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.blue,
                                    Color(0xff6A88E5),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight),
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              color: Colors.transparent,
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          )),*/
                    ),
                    builder: (ctx, child) {
                      return Transform.translate(
                          offset: Offset(
                              0,
                              MediaQuery.of(context).size.height -
                                  (_animation.value) * circleSize),
                          child: Transform.scale(
                              scale: _animation.value, child: child));
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void doExit(BuildContext context, AnimationController controller) {
    widget?.onExit();
    controller.reverse().then((r) {
      Navigator.of(context).pop();
    });
  }
}
