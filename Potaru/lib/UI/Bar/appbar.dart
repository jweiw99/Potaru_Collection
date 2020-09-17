import 'package:flutter/material.dart';
//import 'package:gradient_app_bar/gradient_app_bar.dart';

/*
Widget mainappbar(BuildContext context) {
  return PreferredSize(
    //preferredSize: Size.fromHeight(75.0),
    //preferredSize: Size.fromHeight(123.0),
    preferredSize: Size.fromHeight(MediaQuery.of(context).size.height / 2.2),
    child: GradientAppBar(
      brightness: Brightness.dark,
      flexibleSpace: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          /*CustomPaint(
            painter: CircleOne(),
          ),
          CustomPaint(
            painter: CircleTwo(),
          ),*/
        ],
      ),
      elevation: 0,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromRGBO(56, 103, 213, 1),
          Color.fromRGBO(129, 199, 245, 1)
        ],
      ),
    ),
  );
}*/

Widget mainappbar(apptitle) {
  return SizedBox(
    height: AppBar().preferredSize.height,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                apptitle,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  letterSpacing: 1.2,
                  color: Color(0xFF17262A),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget subappBar(context, apptitle, page) {
  return PreferredSize(
      preferredSize: Size.fromHeight(50.0),
      child: Stack(children: <Widget>[
        page == 1
            ? Transform(
                transform: Matrix4.translationValues(0.0, 0.0, 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                ),
              )
            : SizedBox(),
        AppBar(
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Color(0xFF17262A), //change your color here
          ),
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: page == 1
                ? Icon(
                    Icons.home,
                    size: 22,
                  )
                : Icon(
                    Icons.arrow_back,
                    size: 22,
                  ),
            color: Color(0xFF17262A),
            onPressed: () => page == 1
                ? Navigator.of(context).pushNamedAndRemoveUntil(
                    '/homeUI', (Route<dynamic> route) => false)
                : Navigator.of(context).pop(),
          ),
          elevation: 0.0,
          title: Text(
            apptitle,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              letterSpacing: 1.2,
              color: Color(0xFF17262A),
            ),
          ),
        ),
      ]));
}

Widget subappbarWithdropdown(context, apptitle) {
  return PreferredSize(
      preferredSize: Size.fromHeight(50.0),
      child: Stack(children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(0.0, 0.0, 0.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
        ),
        AppBar(
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Color(0xFF17262A), //change your color here
          ),
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.home, size: 22),
            color: Color(0xFF17262A),
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                '/homeUI', (Route<dynamic> route) => false),
          ),
          title: Text(
            apptitle,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              letterSpacing: 1.2,
              color: Color(0xFF17262A),
            ),
          ),
        )
      ]));
}

Widget subappBarMenu(context, apptitle, page, widgets) {
  return PreferredSize(
      preferredSize: Size.fromHeight(60.0),
      child: Stack(children: <Widget>[
        page == 1
            ? Transform(
                transform: Matrix4.translationValues(0.0, 0.0, 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color: Colors.grey.withOpacity(0.4),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                ),
              )
            : SizedBox(),
        AppBar(
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Color(0xFF17262A), //change your color here
          ),
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: page == 1 ? Icon(Icons.home,size: 22,) : Icon(Icons.arrow_back,size: 22,),
            color: Color(0xFF17262A),
            onPressed: () => page == 1
                ? Navigator.of(context).pushNamedAndRemoveUntil(
                    '/homeUI', (Route<dynamic> route) => false)
                : Navigator.of(context).pop(),
          ),
          elevation: 0.0,
          title: Text(
            apptitle,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              letterSpacing: 1.2,
              color: Color(0xFF17262A),
            ),
          ),
          actions: <Widget>[widgets],
        ),
      ]));
}

class CircleOne extends CustomPainter {
  Paint _paint;

  CircleOne() {
    _paint = Paint()
      ..color = Color.fromRGBO(255, 255, 255, 0.17)
      ..strokeWidth = 10.0
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(50, 120), 50.0, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class CircleTwo extends CustomPainter {
  Paint _paint;

  CircleTwo() {
    _paint = Paint()
      ..color = Color.fromRGBO(255, 255, 255, 0.17)
      ..strokeWidth = 10.0
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(350.0, 40.0), 99.0, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
