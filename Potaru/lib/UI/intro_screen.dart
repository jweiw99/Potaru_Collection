import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatelessWidget {
  IntroScreen({Key key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IntroViewsFlutter(
      [
        _buildFirstPage(context),
        _buildSecondPage(context),
        _buildThirdPage(context),
        _buildFouthPage(context),
        _buildFifthPage(context)
      ],
      doneText: Text(
        "Start",
        style: TextStyle(
            letterSpacing: 1,
            color: Colors.blueGrey[600],
            fontSize: ScreenUtil().setSp(55)),
      ),
      showSkipButton: false,
      pageButtonTextStyles: TextStyle(
        color: Colors.blueGrey[700],
        fontSize: ScreenUtil().setSp(30),
      ),
      onTapDoneButton: () async {
        final prefs = await SharedPreferences.getInstance();
        prefs.setBool('appFirstRun', false);
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/homeUI', (route) => false);
      },
    );
  }

  PageViewModel _buildFirstPage(context) => getPageModel(context,
      title: "Welcome to Potaru",
      icon: Icons.school,
      mainColor: Colors.blueGrey,
      titleColor: Colors.blueGrey[600],
      imagePath: 'assets/images/logo/logo.png',
      imageSize: 120,
      desc:
          "This application is an unoffocial client of the UTAR and has no relation to its administration.");

  PageViewModel _buildSecondPage(context) => getPageModel(context,
      title: "Login UTAR Account",
      icon: Icons.web,
      mainColor: Colors.blueGrey,
      titleColor: Colors.blueGrey[700],
      imagePath: 'assets/images/firstrun/firstRunPage2.png',
      desc:
          "You must log in to your UTAR account to activate all functions of the app.");

  PageViewModel _buildThirdPage(context) => getPageModel(context,
      title: "Download Academic Data",
      icon: Icons.web_asset,
      mainColor: Colors.blueGrey,
      titleColor: Colors.blueGrey[700],
      imagePath: 'assets/images/firstrun/firstRunPage3.png',
      desc:
          "You can download the latest grades and current semester attendance, timetable by get UTAR data every semester.");

  PageViewModel _buildFouthPage(context) => getPageModel(context,
      title: "Lock Screen Timetable",
      icon: Icons.settings,
      mainColor: Colors.blueGrey,
      titleColor: Colors.blueGrey[700],
      imagePath: 'assets/images/firstrun/firstRunPage4.png',
      desc:
          "By enabling the lock screen timetable function, you can view the timetable on the locked screen at any time");

  PageViewModel _buildFifthPage(context) => getPageModel(context,
      title: "Change your preference",
      icon: Icons.settings,
      mainColor: Colors.blueGrey,
      titleColor: Colors.blueGrey[700],
      imagePath: 'assets/images/firstrun/firstRunPage5.png',
      desc:
          "You can disable silent mode and reminders at any time on the settings page.");

  PageViewModel getPageModel(context,
      {String title,
      IconData icon,
      String desc,
      String imagePath,
      Color mainColor,
      Color titleColor,
      int imageSize = 50}) {
    return PageViewModel(
      bubbleBackgroundColor: mainColor,
      pageColor: Color(0xFFF2F3F8),
      bubble: Icon(
        icon,
        size: 20,
        color: Colors.white,
      ),
      title: Container(
          height: MediaQuery.of(context).size.height / 2.3,
          child: Align(
              alignment: Alignment.bottomCenter,
              child: Image(
                image: AssetImage(
                  imagePath,
                ),
                width: MediaQuery.of(context).size.width - imageSize,
              ))),
      body: SizedBox(),
      mainImage: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    title,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: titleColor,
                        fontSize: ScreenUtil().setSp(50)),
                  )),
              SizedBox(
                height: 20,
              ),
              Text(
                desc,
                style: TextStyle(
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0,
                    color: mainColor,
                    fontSize: ScreenUtil().setSp(40)),
                textAlign: TextAlign.justify,
              ),
            ],
          )),
    );
  }
}
