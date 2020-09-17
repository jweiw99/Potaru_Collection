import 'package:flutter/material.dart';

class TitleView extends StatelessWidget {
  final String titleTxt;
  final String subTxt;
  final double fontsize;
  final IconData icon;
  final double iconsize;
  final AnimationController animationController;
  final Animation animation;

  const TitleView(
      {Key key,
      this.titleTxt: "",
      this.subTxt: "",
      this.fontsize: 16,
      this.icon,
      this.iconsize: 16,
      this.animationController,
      this.animation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - animation.value), 0.0),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: Row(
                  children: <Widget>[
                    icon != null
                        ? Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(
                              icon,
                              size: iconsize,
                            ),
                          )
                        : SizedBox(),
                    Expanded(
                      child: Text(
                        titleTxt,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: fontsize,
                          letterSpacing: 0.5,
                          color: Color(0xFF4A6572),
                        ),
                      ),
                    ),
                    subText(subTxt)
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  subText(subTxt) {
    if (subTxt != "") {
      return InkWell(
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: <Widget>[
              Text(
                subTxt,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 16,
                  letterSpacing: 0.5,
                  color: Color(0xFF2633C5),
                ),
              ),
              SizedBox(
                height: 38,
                width: 26,
                child: Icon(
                  Icons.arrow_forward,
                  color: Color(0xFF253840),
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return const SizedBox(height: 0);
    }
  }
}

class ContentView extends StatelessWidget {
  final String txt;
  final double fontsize;
  final AnimationController animationController;
  final Animation animation;

  const ContentView(
      {Key key,
      this.txt: "",
      this.fontsize: 18,
      this.animationController,
      this.animation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - animation.value), 0.0),
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 24, right: 24),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        txt,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: fontsize,
                          letterSpacing: 0.5,
                          color: Color(0xFF4A6572),
                        ),
                      ),
                    ),
                    const SizedBox(height: 0)
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
