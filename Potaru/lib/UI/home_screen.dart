import 'package:flutter/material.dart';

import 'package:potaru/UI/Widgets/ui_view.dart';
import 'package:potaru/UI/Widgets/modules_list.dart';
import 'package:potaru/UI/Widgets/dashboard.dart';
import 'package:potaru/UI/Widgets/module.model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key, this.animationController, this.onHomeListCall})
      : super(key: key);
  final AnimationController animationController;
  final Function(ModuleIndex) onHomeListCall;
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var bottomNavigationBarIndex = 0;
  List<Widget> listViews = <Widget>[];

  @override
  void initState() {
    addAllListData();

    super.initState();
  }

  void addAllListData() {
    int count = 5;
    listViews.add(SizedBox(
      height: 50,
    ));
    listViews.add(
      DashBoardTaskView(
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController,
            curve:
                Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController,
      ),
    );
    listViews.add(SizedBox(
      height: 20,
    ));
    listViews.add(TitleView(
      titleTxt: 'Apps',
      icon: Icons.apps,
      animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: widget.animationController,
          curve: Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn))),
      animationController: widget.animationController,
    ));
    listViews.add(HomeModule(
      animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
          parent: widget.animationController,
          curve: Interval((1 / count) * 2, 1.0, curve: Curves.fastOutSlowIn))),
      animationController: widget.animationController,
      callBackIndex: (ModuleIndex indexType) {
        widget.onHomeListCall(indexType);
      },
    ));
  }

  Future<bool> getData() async {
    //await Future<dynamic>.delayed(const Duration(milliseconds: 0));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //appBar: mainappbar(context),
        backgroundColor: Color(0xFFF2F3F8),
        body: FutureBuilder<bool>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            } else {
              return Padding(
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                child: getMainListViewUI(),
              );
            }
          },
        ));
  }

  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          return ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.only(bottom: 55),
            itemBuilder: (BuildContext context, int index) {
              widget.animationController.forward();
              return listViews[index];
            },
          );
        }
      },
    );
  }
}
