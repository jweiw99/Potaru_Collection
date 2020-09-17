import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarView extends StatefulWidget {
  const CalendarView(
      {Key key, this.onDaySelected, this.animationController, this.animation})
      : super(key: key);

  final AnimationController animationController;
  final Animation animation;
  final onDaySelected;

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  CalendarController _calendarController;

  @override
  void initState() {
    _calendarController = CalendarController();
    super.initState();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: widget.animationController,
        builder: (BuildContext context, Widget child) {
          return FadeTransition(
              opacity: widget.animation,
              child: Transform(
                  transform: Matrix4.translationValues(
                      0.0, 30 * (1.0 - widget.animation.value), 0.0),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 10.0, top: 5.0, right: 10.0, bottom: 5.0),
                    child: Card(
                      child: _buildTableCalendar(),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      elevation: 2,
                      color: Colors.white,
                    ),
                  )));
        });
  }

  Widget _buildTableCalendar() {
    return TableCalendar(
        locale: 'en_US',
        calendarController: _calendarController,
        initialCalendarFormat: CalendarFormat.week,
        formatAnimation: FormatAnimation.slide,
        startingDayOfWeek: StartingDayOfWeek.sunday,
        availableGestures: AvailableGestures.all,
        onDaySelected: widget.onDaySelected,
        availableCalendarFormats: const {
          CalendarFormat.month: 'Week',
          CalendarFormat.twoWeeks: 'Month',
          CalendarFormat.week: '2 Weeks',
        },
        calendarStyle: CalendarStyle(
            outsideStyle: TextStyle(
                color: Colors.grey[500], fontSize: ScreenUtil().setSp(38)),
            outsideHolidayStyle: TextStyle(
                color: Colors.grey[500], fontSize: ScreenUtil().setSp(38)),
            outsideWeekendStyle: TextStyle(
                color: Colors.grey[500], fontSize: ScreenUtil().setSp(38)),
            unavailableStyle: TextStyle(
                color: Colors.white, fontSize: ScreenUtil().setSp(38)),
            todayStyle: TextStyle(
                color: Colors.white, fontSize: ScreenUtil().setSp(38)),
            holidayStyle:
                TextStyle(color: Colors.red, fontSize: ScreenUtil().setSp(38)),
            selectedStyle: TextStyle(
                color: Colors.white, fontSize: ScreenUtil().setSp(38)),
            selectedColor: Theme.of(context).buttonColor,
            todayColor: Colors.cyan,
            markersColor: Theme.of(context).buttonColor,
            markersMaxAmount: 0,
            weekendStyle: TextStyle(
                color: Color(0xFF17262A), fontSize: ScreenUtil().setSp(38)),
            weekdayStyle: TextStyle(
                color: Color(0xFF17262A), fontSize: ScreenUtil().setSp(38))),
        daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
                color: Color(0xFF17262A), fontSize: ScreenUtil().setSp(38)),
            weekendStyle: TextStyle(
                color: Color(0xFF17262A), fontSize: ScreenUtil().setSp(38))),
        headerStyle: HeaderStyle(
            formatButtonTextStyle: TextStyle().copyWith(
                color: Colors.white, fontSize: ScreenUtil().setSp(43)),
            formatButtonDecoration: BoxDecoration(
              color: Theme.of(context).buttonColor,
              borderRadius: BorderRadius.circular(20.0),
            ),
            titleTextStyle: TextStyle().copyWith(
                color: Color(0xFF17262A), fontSize: ScreenUtil().setSp(43)),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: Color(0xFF17262A),
              size: 22,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: Color(0xFF17262A),
              size: 22,
            )));
  }
}
