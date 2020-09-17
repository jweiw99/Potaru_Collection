import 'package:flutter/material.dart';

import 'package:potaru/UI/Bar/appbar.dart';
import 'package:potaru/UI/Modules/Tasks/Widgets/fab.dart';
import 'package:potaru/UI/Modules/Tasks/Widgets/tasks_list_view.dart';
import 'package:potaru/UI/Widgets/calendar_view.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key key, this.animationController}) : super(key: key);
  final AnimationController animationController;

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Widget> listViews = <Widget>[];
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    addAllListData();
    super.initState();
  }

  void addAllListData() {
    const int count = 2;
    listViews.add(
      CalendarView(
        onDaySelected: _onDaySelected,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController,
            curve:
                Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController,
      ),
    );
    listViews.add(
      TasksListView(
        selectedDate: selectedDate,
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: widget.animationController,
            curve:
                Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn))),
        animationController: widget.animationController,
      ),
    );
  }

  void _onDaySelected(DateTime day, List events) {
    setState(() {
      listViews = <Widget>[];
      selectedDate = day;
      addAllListData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFF2F3F8),
      child: Scaffold(
        appBar: subappBar(context, "Tasks", 1),
        backgroundColor: Colors.transparent,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: AnimatedTaskFloatingButton(
            animationController: widget.animationController),
        body: Stack(
          children: <Widget>[
            getMainListViewUI(),
          ],
        ),
      ),
    );
  }

  Widget getMainListViewUI() {
    return ListView.builder(
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: 80 + MediaQuery.of(context).padding.bottom,
      ),
      itemCount: listViews.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        widget.animationController.forward();
        return listViews[index];
      },
    );
  }
}
