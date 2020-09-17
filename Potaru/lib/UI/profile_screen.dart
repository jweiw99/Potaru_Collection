import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key key, this.animationController}) : super(key: key);
  final AnimationController animationController;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>{
  Animation animation;

  @override
  void initState() {
    widget.animationController.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFF2F3F8),
        body: ListView(children: <Widget>[
          Column(children: <Widget>[
            AnimatedBuilder(
                animation: widget.animationController,
                builder: (BuildContext context, Widget child) {
                  animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(
                          parent: widget.animationController,
                          curve: Interval((1 / 2) * 0, 1.0,
                              curve: Curves.fastOutSlowIn)));
                  return FadeTransition(
                      opacity: animation,
                      child: Transform(
                        transform: Matrix4.translationValues(
                            0.0, 30 * (1.0 - animation.value), 0.0),
                        child: Container(
                            child: Column(children: <Widget>[
                          Padding(
                              padding: EdgeInsets.only(top: 20.0),
                              child: Stack(
                                fit: StackFit.loose,
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                          width: 140.0,
                                          height: 140.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white,
                                            image: DecorationImage(
                                              image: ExactAssetImage(
                                                  'assets/images/portfolio/000-profile.png'),
                                              fit: BoxFit.cover,
                                            ),
                                          )),
                                    ],
                                  ),
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: 90.0, right: 100.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          CircleAvatar(
                                            backgroundColor: Colors.blue,
                                            radius: 25.0,
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: Colors.white,
                                            ),
                                          )
                                        ],
                                      )),
                                ],
                              ))
                        ])),
                      ));
                }),
            AnimatedBuilder(
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
                            child: Padding(
                                padding: EdgeInsets.only(
                                    left: 5, top: 40, bottom: 25.0, right: 5),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                          padding: EdgeInsets.only(
                                              left: 25.0,
                                              right: 25.0,
                                              top: 25.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Text(
                                                    'User Information',
                                                    style: TextStyle(
                                                        fontSize: 18.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )),
                                      Padding(
                                          padding: EdgeInsets.only(
                                              left: 25.0,
                                              right: 25.0,
                                              top: 25.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Text(
                                                    'Email',
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )),
                                      Padding(
                                          padding: EdgeInsets.only(
                                              left: 25.0,
                                              right: 25.0,
                                              top: 2.0),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Flexible(
                                                child: TextField(
                                                  onChanged: (value) {},
                                                  decoration:
                                                      const InputDecoration(
                                                    hintText:
                                                        "guest@1utar.edu.my",
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                                      Padding(
                                        padding: EdgeInsets.only(
                                            left: 25.0, right: 25.0, top: 45.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                  child: RaisedButton(
                                                child: Text("Google Sign-In"),
                                                textColor: Colors.white,
                                                color: Colors.blue,
                                                onPressed: () {
                                                  //action
                                                },
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0)),
                                              )),
                                              flex: 2,
                                            ),
                                          ],
                                        ),
                                      )
                                    ])),
                          )));
                })
          ])
        ]));
  }
}
