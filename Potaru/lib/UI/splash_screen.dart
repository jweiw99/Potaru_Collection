import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:simple_animations/simple_animations.dart';
import 'package:flutter/material.dart';

import 'package:potaru/UI/utils/errorMsg.dart';

class AnimatedSplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  final tween = MultiTrackTween([
    Track("color1").add(Duration(seconds: 3),
        ColorTween(begin: Colors.grey[100], end: Colors.white)),
    Track("color2").add(Duration(seconds: 3),
        ColorTween(begin: Colors.grey[50], end: Colors.white))
  ]);

  double start = 3.0;

  AnimationController _progressController;
  Tween<double> valueTween;

  @override
  void initState() {
    startTimer();

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    valueTween = Tween<double>(
      begin: 0,
      end: 1,
    );
    _progressController.forward();
    super.initState();
  }

  @override
  void dispose() {
    this._progressController.dispose();
    super.dispose();
  }

  startTimer() async {
    try {
      await InternetAddress.lookup('google.com');
    } on SocketException catch (_) {
      ErrorMsg.internetMsg();
    }
    var _duration = Duration(milliseconds: 100);
    Timer.periodic(
      _duration,
      (Timer timer) => setState(
        () {
          double beginValue = 0.0;
          if (start < 0) {
            timer.cancel();
            beginValue = 1.0;
            navigationPage();
          } else {
            start -= 0.1;
            beginValue = valueTween?.evaluate(_progressController) ?? 0;
          }
          // Update the value tween.
          valueTween = Tween<double>(
            begin: beginValue,
            end: 1,
          );
          _progressController
            ..value = 0
            ..forward();
        },
      ),
    );
  }

  void navigationPage() {
    Navigator.of(context).pushNamedAndRemoveUntil('/homeUI', (route) => false);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ControlledAnimation(
            playback: Playback.MIRROR,
            tween: tween,
            duration: tween.duration,
            builder: (context, animation) {
              return Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [animation["color1"], animation["color2"]])),
              );
            },
          ),
          onBottom(AnimatedWave(
            height: MediaQuery.of(context).size.height * 0.3,
            speed: 1.0,
          )),
          onBottom(AnimatedWave(
            height: MediaQuery.of(context).size.height * 0.2,
            speed: 0.9,
            offset: pi,
          )),
          onBottom(AnimatedWave(
            height: MediaQuery.of(context).size.height * 0.4,
            speed: 1.2,
            offset: pi / 2,
          )),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/logo/logo.png',
                  height: 120,
                  fit: BoxFit.scaleDown,
                ),
                SizedBox(
                  height: 50,
                ),
                Text(
                  (valueTween.begin < 1 ? "Loading " : "Completed ") +
                      (valueTween.evaluate(_progressController) * 100)
                          .floor()
                          .toString() +
                      "%",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 200,
                  height: 3,
                  child: AnimatedBuilder(
                      animation: _progressController,
                      child: Container(),
                      builder: (context, child) {
                        return LinearProgressIndicator(
                            backgroundColor: Colors.transparent,
                            value: valueTween.evaluate(_progressController));
                      }),
                )
              ]),
        ],
      ),
    );
  }

  onBottom(Widget child) => Positioned.fill(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      );
}

class AnimatedWave extends StatelessWidget {
  final double height;
  final double speed;
  final double offset;

  AnimatedWave({this.height, this.speed, this.offset = 0.0});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: height,
        width: constraints.biggest.width,
        child: ControlledAnimation(
            playback: Playback.LOOP,
            duration: Duration(milliseconds: (5000 / speed).round()),
            tween: Tween(begin: 0.0, end: 2 * pi),
            builder: (context, value) {
              return CustomPaint(
                foregroundPainter: SplashScreenCurvePainter(value + offset),
              );
            }),
      );
    });
  }
}

class SplashScreenCurvePainter extends CustomPainter {
  final double value;

  SplashScreenCurvePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.blueAccent.withAlpha(15);
    final path = Path();

    final y1 = sin(value);
    final y2 = sin(value + pi / 2);
    final y3 = sin(value + pi);

    final startPointY = size.height * (0.5 + 0.4 * y1);
    final controlPointY = size.height * (0.5 + 0.4 * y2);
    final endPointY = size.height * (0.5 + 0.4 * y3);

    path.moveTo(size.width * 0, startPointY);
    path.quadraticBezierTo(
        size.width * 0.5, controlPointY, size.width, endPointY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
