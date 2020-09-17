import 'package:flutter/material.dart';

import 'package:potaru/UI/Bar/appbar.dart';
import 'package:potaru/UI/Bar/bottom_navbar_tabicon.dart';
import 'package:potaru/UI/Widgets/module.model.dart';
import 'package:potaru/UI/navigator_screen.dart';
//import 'package:potaru/UI/utils/roundedClipper.dart';
import 'package:potaru/UI/utils/toastMsg.dart';
import 'package:potaru/UI/Drawer/drawer.dart';
//import 'package:potaru/UI/Bar/appbar.dart';
import 'package:potaru/UI/Bar/bottom_navbar.dart';

class DrawerUserController extends StatefulWidget {
  const DrawerUserController(
      {Key key,
      this.drawerWidth = 250,
      this.onDrawerCall,
      this.screenView,
      this.animationController,
      this.animatedIconData = AnimatedIcons.arrow_menu,
      this.homeIconsList,
      this.menuView,
      this.drawerIsOpen,
      this.moduleIsOpen,
      this.screenIndex,
      this.appbarTitle,
      this.drawerScrollController})
      : super(key: key);

  final double drawerWidth;
  final Function(ModuleIndex) onDrawerCall;
  final Widget screenView;
  final Function(AnimationController) animationController;
  final Function(bool) drawerIsOpen;
  final bool moduleIsOpen;
  final AnimatedIconData animatedIconData;
  final List<TabIconData> homeIconsList;
  final Widget menuView;
  final ModuleIndex screenIndex;
  final String appbarTitle;
  final Function(ScrollController) drawerScrollController;

  @override
  _DrawerUserControllerState createState() => _DrawerUserControllerState();
}

class _DrawerUserControllerState extends State<DrawerUserController>
    with TickerProviderStateMixin {
  ScrollController scrollController;
  AnimationController iconAnimationController;
  AnimationController animationController;
  DateTime currentBackPressTime;

  double scrolloffset = 0.0;
  bool isSetDawer = false;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    iconAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 0));
    iconAnimationController.animateTo(1.0,
        duration: const Duration(milliseconds: 0), curve: Curves.fastOutSlowIn);
    scrollController =
        ScrollController(initialScrollOffset: widget.drawerWidth);
    scrollController
      ..addListener(() {
        if (scrollController.offset <= 0) {
          if (scrolloffset != 1.0) {
            setState(() {
              scrolloffset = 1.0;
              try {
                widget.drawerIsOpen(true);
              } catch (_) {}
            });
          }
          iconAnimationController.animateTo(0.0,
              duration: const Duration(milliseconds: 0), curve: Curves.linear);
        } else if (scrollController.offset <= widget.drawerWidth) {
          if (scrolloffset != 0.0) {
            setState(() {
              scrolloffset = 0.0;
              try {
                widget.drawerIsOpen(false);
              } catch (_) {}
            });
          }
          iconAnimationController.animateTo(1.0,
              duration: const Duration(milliseconds: 0), curve: Curves.linear);
        }

        if (scrollController.offset > 0 &&
            scrollController.offset < widget.drawerWidth) {
          iconAnimationController.animateTo(
              (scrollController.offset * 100 / (widget.drawerWidth)) / 100,
              duration: const Duration(milliseconds: 0),
              curve: Curves.linear);
        }
        widget.drawerScrollController(scrollController);
        if (scrollController.offset < widget.drawerWidth - 5 &&
            MediaQuery.of(context).viewInsets.bottom != 0) {
          FocusScope.of(context).unfocus();
        }
      });
    getInitState();
    super.initState();
  }

  Future<bool> getInitState() async {
    //await Future<dynamic>.delayed(const Duration(milliseconds: 300));
    try {
      widget.animationController(iconAnimationController);
    } catch (_) {}
    //await Future<dynamic>.delayed(const Duration(milliseconds: 100));
    if (scrollController.hasClients)
      scrollController.jumpTo(
        widget.drawerWidth,
      );
    setState(() {
      isSetDawer = true;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
        child: Opacity(
          opacity: isSetDawer ? 1 : 0,
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width + widget.drawerWidth,
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: widget.drawerWidth,
                  height: MediaQuery.of(context).size.height,
                  child: AnimatedBuilder(
                    animation: iconAnimationController,
                    builder: (BuildContext context, Widget child) {
                      return Transform(
                        transform: Matrix4.translationValues(
                            scrollController.offset, 0.0, 0.0),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: widget.drawerWidth,
                          child: HomeDrawer(
                            screenIndex: widget.screenIndex == null
                                ? ModuleIndex.HOME
                                : widget.screenIndex,
                            iconAnimationController: iconAnimationController,
                            callBackIndex: (ModuleIndex indexType) {
                              onDrawerClick();
                              try {
                                widget.onDrawerCall(indexType);
                              } catch (e) {}
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF2F3F8),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color: Colors.grey.withOpacity(0.6),
                            blurRadius: 24),
                      ],
                    ),
                    child: Stack(
                      children: <Widget>[
                        IgnorePointer(
                            ignoring: scrolloffset == 1.0 || false,
                            child: widget.screenIndex == null ||
                                    widget.screenIndex == ModuleIndex.HOME
                                ? WillPopScope(
                                    onWillPop: onWillPop,
                                    child: Stack(children: <Widget>[
                                      /*ClipPath(
                                      clipper: RoundedClipper(250),
                                      child: Container(
                                        height: 100,
                                        color: Color.fromRGBO(129, 199, 245, 1),
                                      ),
                                    ),*/
                                      widget.screenView,
                                      bottomBar()
                                    ]))
                                : WillPopScope(
                                    child: Stack(children: <Widget>[
                                      /*ClipPath(
                                      clipper: RoundedClipper(250),
                                      child: Container(
                                        height: 100,
                                        color: Color.fromRGBO(129, 199, 245, 1),
                                      ),
                                    ),*/
                                      widget.screenView,
                                      bottomBar()
                                    ]),
                                    onWillPop: () async {
                                      Navigator.pushReplacement(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (c, a1, a2) =>
                                              NavigatorScreen(),
                                          transitionsBuilder:
                                              (c, anim, a2, child) =>
                                                  SlideTransition(
                                                      position: Tween<Offset>(
                                                        begin: Offset(3.5, 0.0),
                                                        end: Offset.zero,
                                                      ).animate(anim),
                                                      child: child),
                                        ),
                                      );
                                      return false;
                                    })),
                        !widget.moduleIsOpen
                            ? Stack(children: <Widget>[
                                scrolloffset == 1.0
                                    ? InkWell(
                                        onTap: () {
                                          onDrawerClick();
                                        },
                                      )
                                    : SizedBox(),
                                Container(
                                    color: Color(0xFFF2F3F8),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                  .padding
                                                  .top +
                                              4),
                                      child: mainappbar(widget.appbarTitle),
                                    )),
                                Container(
                                    color: Color(0xFFF2F3F8),
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                  .padding
                                                  .top +
                                              8,
                                          left: 8),
                                      child: SizedBox(
                                        width:
                                            AppBar().preferredSize.height - 8,
                                        height:
                                            AppBar().preferredSize.height - 8,
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(
                                                AppBar().preferredSize.height),
                                            child: Center(
                                              child: widget.menuView != null
                                                  ? widget.menuView
                                                  : AnimatedIcon(
                                                      color: Color(0xFF17262A),
                                                      icon: widget.animatedIconData !=
                                                              null
                                                          ? widget
                                                              .animatedIconData
                                                          : AnimatedIcons
                                                              .arrow_menu,
                                                      progress:
                                                          iconAnimationController),
                                            ),
                                            onTap: () {
                                              FocusScope.of(context)
                                                  .requestFocus(FocusNode());
                                              onDrawerClick();
                                            },
                                          ),
                                        ),
                                      ),
                                    )),
                              ])
                            : Stack(children: <Widget>[
                                scrolloffset == 1.0
                                    ? InkWell(
                                        onTap: () {
                                          onDrawerClick();
                                        },
                                      )
                                    : SizedBox()
                              ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      ToastMsg.toToast('Tap back again to exit');
      return Future.value(false);
    }
    return Future.value(true);
  }

  void onDrawerClick() {
    if (scrollController.offset != 0.0) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      scrollController.animateTo(
        widget.drawerWidth,
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  Widget bottomBar() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        BottomNavigationBarApp(
            tabIconsList: widget.homeIconsList,
            addClick: () {},
            changeIndex: (ModuleIndex indexType) {
              widget.onDrawerCall(indexType);
            }),
      ],
    );
  }
}
