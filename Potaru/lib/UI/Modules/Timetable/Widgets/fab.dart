import 'dart:math';
import 'package:flutter/material.dart';

import 'package:potaru/UI/Modules/Timetable/Widgets/bottom_show_widget.dart';
import 'package:potaru/UI/utils/full_screen_dialog_util.dart';

class AnimatedTimetableFloatingButton extends StatefulWidget {
  const AnimatedTimetableFloatingButton(
      {Key key, this.animationController, this.selectedDate})
      : super(key: key);

  final DateTime selectedDate;
  final AnimationController animationController;
  @override
  _AnimatedTimetableFloatingButtonState createState() =>
      _AnimatedTimetableFloatingButtonState();
}

class _AnimatedTimetableFloatingButtonState
    extends State<AnimatedTimetableFloatingButton>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation _animation;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animation = Tween(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (ctx, child) {
        return Transform.translate(
          offset: Offset(0, (_animation.value) * 56),
          child: Transform.scale(scale: 1 - _animation.value, child: child),
        );
      },
      child: Transform.rotate(
        angle: -pi / 2,
        child: SizedBox(
          width: 38 * 2.0,
          height: 38 + 62.0,
          child: SizedBox(
            width: 38 * 2.0,
            height: 38 * 2.0,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: ScaleTransition(
                alignment: Alignment.center,
                scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                        parent: widget.animationController,
                        curve: Curves.fastOutSlowIn)),
                child: Container(
                  // alignment: Alignment.center,s
                  decoration: BoxDecoration(
                    color: Color(0xFF2633C5),
                    gradient: LinearGradient(colors: [
                      Theme.of(context).buttonColor,
                      Color(0xff6A88E5),
                    ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          offset: const Offset(-10.0, 10.0),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.white.withOpacity(0.1),
                      highlightColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      onTap: () {
                        FullScreenDialog.getInstance().showDialog(
                            context,
                            BottomShowWidget(
                              selectedDate: widget.selectedDate,
                              onExit: () {
                                _controller.reverse();
                              },
                            ));
                        _controller.forward();
                      },
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
