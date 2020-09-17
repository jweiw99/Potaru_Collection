import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class ErrorMsg {
  ErrorMsg._();

  static internetMsg() => Fluttertoast.showToast(
      msg: 'No Internet Access',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.grey[700],
      textColor: Colors.white,
      fontSize: 16.0);

  static serverErrorMsg() => Fluttertoast.showToast(
      msg: 'Server Error\nPlease try again later.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.grey[700],
      textColor: Colors.white,
      fontSize: 16.0);

  static staffNotFoundMsg() => Fluttertoast.showToast(
      msg: 'No staff data found\nPlease try again later.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.grey[700],
      textColor: Colors.white,
      fontSize: 16.0);

  static courseNameNotFoundMsg() => Fluttertoast.showToast(
      msg:
          'No Subject record found\nPlease download records through\n"Get UTAR Data".',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.grey[700],
      textColor: Colors.white,
      fontSize: 16.0);

  static attendanceNotFoundMsg() => Fluttertoast.showToast(
      msg:
          'No attendance record found\nPlease download records through\n"Get UTAR Data".',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.grey[700],
      textColor: Colors.white,
      fontSize: 16.0);

  static classAttendanceNotFoundMsg() => Fluttertoast.showToast(
      msg: 'No attendance record found.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.grey[700],
      textColor: Colors.white,
      fontSize: 16.0);

  static semesterNotFoundMsg() => Fluttertoast.showToast(
      msg:
          'No semester record found\nPlease download records through\n"Get UTAR Data".',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.grey[700],
      textColor: Colors.white,
      fontSize: 16.0);

  static gradeNotFoundMsg() => Fluttertoast.showToast(
      msg: 'No grade record found\n It will not included current semester.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.grey[700],
      textColor: Colors.white,
      fontSize: 16.0);

  static subjectGradeNotFoundMsg() => Fluttertoast.showToast(
      msg: 'No subject record found',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.grey[700],
      textColor: Colors.white,
      fontSize: 16.0);

  static markOver(String grade) => Fluttertoast.showToast(
      msg: 'Unable obtain Grade ' +
          grade +
          ' with current coursework mark earned.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.grey[700],
      textColor: Colors.white,
      fontSize: 16.0);

  static cannotPass(String grade) => Fluttertoast.showToast(
      msg: 'Unable obtain Grade ' +
          grade +
          ' with current coursework mark earned.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.grey[700],
      textColor: Colors.white,
      fontSize: 16.0);

  static appError() => Fluttertoast.showToast(
      msg: 'Application Error\nYou might need to clear application cache.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.grey[700],
      textColor: Colors.white,
      fontSize: 16.0);
}
