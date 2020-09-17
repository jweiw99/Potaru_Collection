import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({Key key, this.animationController}) : super(key: key);
  final AnimationController animationController;

  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  List<Widget> listViews = <Widget>[];
  Animation animation;

  @override
  void initState() {
    widget.animationController.forward(from: 0.0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFF2F3F8),
        body: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: AnimatedBuilder(
                animation: widget.animationController,
                builder: (BuildContext context, Widget child) {
                  animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController,
                          curve: Interval((1 / 2) * 1, 1.0,
                              curve: Curves.fastOutSlowIn)));
                  return FadeTransition(
                      opacity: animation,
                      child: Transform(
                        transform: Matrix4.translationValues(
                            0.0, 30 * (1.0 - animation.value), 0.0),
                        child: Container(
                            padding:
                                const EdgeInsets.fromLTRB(30, 100, 30, 100),
                            child: Column(children: <Widget>[
                              Container(
                                  width: 220.0,
                                  height: 140.0,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: ExactAssetImage(
                                          'assets/images/logo/logo.png'),
                                      fit: BoxFit.contain,
                                    ),
                                  )),
                              SizedBox(height: 5),
                              Text(
                                "Potaru",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22,
                                    letterSpacing: 1.2,
                                    color: Colors.blueGrey[700]),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Version 1.0.0",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    letterSpacing: 1.0,
                                    color: Colors.blueGrey[700]),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "MIT (License)",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    letterSpacing: 1.0,
                                    color: Colors.blueGrey[400]),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "© Lucas Wong, 2020",
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                    letterSpacing: 1.0,
                                    color: Colors.blueGrey[400]),
                              ),
                              SizedBox(height: 30),
                              Text(
                                "An App That Saves You The Hassle Of Remembering Daily TimeTable And Managing Your Academic-Bunks.",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13.5,
                                    color: Colors.blueGrey[700]),
                              ),
                              SizedBox(height: 30.0),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Want To Contribute or Just see the code? ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13.5,
                                        color: Colors.blueGrey[700]),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: 'Github',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => launch(
                                            'https://github.com/jweiw99/Potaru_Collection'),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15.0),
                              Text(
                                'This project used icons made by the following authors',
                                style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13.5,
                                    color: Colors.blueGrey[700]),
                              ),
                              SizedBox(height: 15.0),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    ' -  Freepik : ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13.5,
                                        color: Colors.blueGrey[700]),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: ' link',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => launch(
                                            'https://www.flaticon.com/authors/freepik'),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 15.0),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    ' -  Flat Icons : ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 13.5,
                                        color: Colors.blueGrey[700]),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: ' link',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => launch(
                                            'https://www.flaticon.com/authors/flat-icons'),
                                    ),
                                  ),
                                ],
                              ),
                            ])),
                      ));
                })));
  }
}
