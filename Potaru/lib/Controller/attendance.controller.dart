import 'package:sqflite/sqflite.dart';

import 'package:potaru/Model/attendance.model.dart';
import 'package:potaru/database/database_helper.dart';

class AttendanceController {
  String tableName = 'Attendance';

  DataBaseHelper dbHelp = DataBaseHelper();

  AttendanceController() : super();

  Future<DataBaseHelper> get databaseHelper async {
    return dbHelp;
  }

  Future<List<Map<String, dynamic>>> getAttendanceMapList() async {
    Database db = await dbHelp.database;
    var result = await db.rawQuery(
        'SELECT * FROM $tableName ORDER BY courseCode');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  Future<List<Map<String, dynamic>>> getAttendanceCodeMapList(
      String session, String courseCode) async {
    Database db = await dbHelp.database;
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE courseCode == "$courseCode" AND session == "$session" ORDER BY courseCode, courseType');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  // Insert
  Future<int> insertAttendance(Attendance attendance) async {
    Database db = await dbHelp.database;
    var result = await db.rawInsert(
        'INSERT OR REPLACE INTO $tableName (session, courseCode, courseType, courseDate, courseStartTime, attendance)' +
            ' VALUES ("' +
            attendance.session +
            '","' +
            attendance.courseCode +
            '","' +
            attendance.courseType +
            '","' +
            attendance.courseDate +
            '","' +
            attendance.courseStartTime +
            '","' +
            attendance.attendance +
            '");');

    return result;
  }

  // Delete By primary key
  Future<int> removeAttendanceByKey(String courseCode, String courseType,
      String courseDate, String courseStartTime) async {
    Database db = await dbHelp.database;
    var result = await db.rawDelete(
        'DELETE FROM $tableName WHERE courseCode == "$courseCode" AND courseType == "$courseType" ' +
            'AND courseDate == "$courseDate" AND courseStartTime == "$courseStartTime";');

    return result;
  }

  // Select all attendance
  Future<List<Attendance>> getAttendanceList() async {
    var attendanceMapList =
        await getAttendanceMapList(); // Get 'Map List' from database
    int count =
        attendanceMapList.length; // Count the number of map entries in db table

    List<Attendance> attendanceList = List<Attendance>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      var _temp = Attendance.fromMapObject(attendanceMapList[i]);
      attendanceList.add(_temp);
    }
    return attendanceList;
  }

  // Select attendance by courseCode
  Future<List<Attendance>> getAttendanceCodeList(
      String session, String courseCode) async {
    var attendanceMapList = await getAttendanceCodeMapList(
        session, courseCode); // Get 'Map List' from database
    int count =
        attendanceMapList.length; // Count the number of map entries in db table

    List<Attendance> attendanceList = List<Attendance>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      var _temp = Attendance.fromMapObject(attendanceMapList[i]);
      attendanceList.add(_temp);
    }
    return attendanceList;
  }
}
