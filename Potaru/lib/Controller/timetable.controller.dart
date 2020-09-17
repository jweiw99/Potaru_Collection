import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

import 'package:potaru/Model/timetable.model.dart';
import 'package:potaru/database/database_helper.dart';
import 'package:potaru/Model/subject.model.dart';

class TimetableController {
  String tableName = 'Timetable';

  DataBaseHelper dbHelp = DataBaseHelper();

  TimetableController() : super();

  Future<DataBaseHelper> get databaseHelper async {
    return dbHelp;
  }

  Future<int> checkExistTimetable(String courseCode, String courseType,
      String courseDate, String courseStartTime, String startDate) async {
    Database db = await dbHelp.database;
    var result = await db.rawQuery('SELECT * FROM $tableName WHERE ' +
        'courseCode == "' +
        courseCode +
        '" AND courseType == "' +
        courseType +
        '" AND courseDate == "' +
        courseDate +
        '" AND courseStartTime == "' +
        courseStartTime +
        '" AND startDate == "' +
        startDate +
        '";');

    int count = result.length; // Count the number of map entries in db table

    return count;
  }

  Future<List<Map<String, dynamic>>> getAllTimetableMapList() async {
    Database db = await dbHelp.database;
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE courseType IN ("L", "P", "T") GROUP BY courseCode, courseType ORDER BY courseName');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  Future<List<Map<String, dynamic>>> getTimetableMapList(
      String courseDate) async {
    Database db = await dbHelp.database;
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE courseDate == "$courseDate" ORDER BY courseStartTime');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  Future<List<Map<String, dynamic>>> getTimetableByKeyMapList(
      String courseCode, String courseName, String courseType) async {
    Database db = await dbHelp.database;
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE courseCode == "$courseCode" AND courseName == "$courseName" AND courseType == "$courseType" ORDER BY courseDate DESC LIMIT 1');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  Future<List<Map<String, dynamic>>> getCurSemSubjectMapList(
      String startDate) async {
    Database db = await dbHelp.database;
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE startDate == "$startDate" AND courseType IN ("L","P","T","E") ORDER BY courseCode, courseDate, courseStartTime');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  Future<List<Map<String, dynamic>>> getNextExamDateMapList(
      String startDate) async {
    Database db = await dbHelp.database;
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE startDate == "$startDate" AND courseType == "E" AND courseDate > strftime(\'%Y-%m-%d\', date(\'now\')) AND courseStartTime > strftime(\'%H:%M\', date(\'now\')) ORDER BY courseDate, courseStartTime LIMIT 1');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  Future<List<Map<String, dynamic>>> getNextSubmissonDateMapList(
      String startDate) async {
    Database db = await dbHelp.database;
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE startDate == "$startDate" AND courseType == "S" AND courseDate > strftime(\'%Y-%m-%d\', date(\'now\')) AND courseStartTime > strftime(\'%H:%M\', date(\'now\')) ORDER BY courseDate, courseStartTime LIMIT 1');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  Future<List<Map<String, dynamic>>> getAllRecurringTimetableMapList(
      String courseCode,
      String courseType,
      String courseStartDate,
      String courseStartTime,
      String startDate,
      String recurring) async {
    Database db = await dbHelp.database;
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE courseCode == "$courseCode" AND courseType == "$courseType" AND courseStartDate == "$courseStartDate" AND courseStartTime == "$courseStartTime" AND startDate == "$startDate" AND recurring == "$recurring"');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  Future<List<Map<String, dynamic>>> getCurWeekTimetableMapList(
      String weekStart, String weekEnd) async {
    Database db = await dbHelp.database;
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE courseType IN ("L", "P", "T", "E") AND courseDate >= "$weekStart" AND courseDate <= "$weekEnd" AND courseStartTime >= "07:00" AND courseEndTime <= "23:00" ORDER BY courseDate, courseStartTime');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  // Insert
  Future<int> insertTimetable(Timetable timetable) async {
    Database db = await dbHelp.database;
    var result = await db.rawInsert(
        'INSERT OR REPLACE INTO $tableName (courseCode, courseName, courseType, courseGroup, courseDate, courseStartTime, courseEndTime, courseHrs, courseVenue, startDate, lecturerID, lecturerName, remind, courseStartDate, recurring)' +
            ' VALUES ("' +
            timetable.courseCode +
            '","' +
            timetable.courseName +
            '","' +
            timetable.courseType +
            '",' +
            timetable.courseGroup.toString() +
            ',"' +
            timetable.courseDate +
            '","' +
            timetable.courseStartTime +
            '","' +
            timetable.courseEndTime +
            '",' +
            timetable.courseHrs.toString() +
            ',"' +
            timetable.courseVenue +
            '","' +
            timetable.startDate +
            '","' +
            timetable.lecturerID +
            '","' +
            timetable.lecturerName +
            '",' +
            timetable.remind.toString() +
            ',"' +
            timetable.courseStartDate +
            '","' +
            timetable.recurring +
            '");');

    return result;
  }

  // Delete By primary key
  Future<int> removeTimetableByPrimary(String courseCode, String courseType,
      String courseDate, String courseStartTime, String startDate) async {
    Database db = await dbHelp.database;
    var result = await db.rawDelete(
        'DELETE FROM $tableName WHERE courseCode == "$courseCode" AND courseType == "$courseType" ' +
            'AND courseDate == "$courseDate" AND courseStartTime == "$courseStartTime" AND startDate == "$startDate";');

    return result;
  }

  // Delete recurring recording
  Future<int> removeRecurringTimetable(
      String courseCode,
      String courseType,
      String courseStartDate,
      String courseStartTime,
      String startDate,
      String recurring) async {
    Database db = await dbHelp.database;
    var result = await db.rawDelete(
        'DELETE FROM $tableName WHERE courseCode == "$courseCode" AND courseType == "$courseType" AND courseStartDate == "$courseStartDate" ' +
            'AND courseStartTime == "$courseStartTime" AND startDate == "$startDate" AND recurring == "$recurring" ;');

    return result;
  }

  // Select All
  Future<List<Timetable>> getAllTimetableList() async {
    var timetableMapList =
        await getAllTimetableMapList(); // Get 'Map List' from database
    int count =
        timetableMapList.length; // Count the number of map entries in db table

    List<Timetable> timetableList = List<Timetable>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      var _temp = Timetable.fromMapObject(timetableMapList[i]);
      timetableList.add(_temp);
    }
    return timetableList;
  }

  // Select timetable by key
  Future<Timetable> getTimetableByKeyList(
      String courseCode, String courseName, String courseType) async {
    var timetableMapList = await getTimetableByKeyMapList(
        courseCode, courseName, courseType); // Get 'Map List' from database
    int count =
        timetableMapList.length; // Count the number of map entries in db table

    Timetable timetableList =
        Timetable("", "", "", 0, "", "", "", "", 0.0, "", "", "", 1, "", "N");

    if (count > 0) {
      timetableList = Timetable.fromMapObject(timetableMapList[0]);
    }
    return timetableList;
  }

  // Select all from current Sem
  Future<List<Subject>> getCurSemSubjectList(String startDate) async {
    var subjectMapList = await getCurSemSubjectMapList(
        startDate); // Get 'Map List' from database
    int count =
        subjectMapList.length; // Count the number of map entries in db table

    List<Subject> subjectList = List<Subject>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      var _temp = Timetable.fromMapObject(subjectMapList[i]);

      final res = subjectList
          .where((sub) => sub.courseCode.contains(_temp.courseCode))
          .toList();
      if (res.length > 0) {
        res[0].subTypeHrs.add(SubTypeHrs(_temp.courseType, _temp.courseDate,
            _temp.courseHrs, _temp.courseStartTime, _temp.courseEndTime));
      } else {
        subjectList.add(Subject(
            _temp.courseCode,
            _temp.courseName,
            [
              SubTypeHrs(_temp.courseType, _temp.courseDate, _temp.courseHrs,
                  _temp.courseStartTime, _temp.courseEndTime)
            ],
            _temp.startDate));
      }
    }
    return subjectList;
  }

  // Select today
  Future<List<Timetable>> getTimetableList(String coursedate) async {
    var timetableMapList =
        await getTimetableMapList(coursedate); // Get 'Map List' from database
    int count =
        timetableMapList.length; // Count the number of map entries in db table

    List<Timetable> timetableList = List<Timetable>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      var _temp = Timetable.fromMapObject(timetableMapList[i]);
      timetableList.add(_temp);
    }
    return timetableList;
  }

  // Select Next Exam Date
  Future<List<Timetable>> getNextExamData(String startDate) async {
    var timetableMapList =
        await getNextExamDateMapList(startDate); // Get 'Map List' from database
    int count =
        timetableMapList.length; // Count the number of map entries in db table

    List<Timetable> timetableList = List<Timetable>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      var _temp = Timetable.fromMapObject(timetableMapList[i]);
      timetableList.add(_temp);
    }
    return timetableList;
  }

  // Select Next Submisson date
  Future<List<Timetable>> getNextSubmissionData(String startDate) async {
    var timetableMapList = await getNextSubmissonDateMapList(
        startDate); // Get 'Map List' from database
    int count =
        timetableMapList.length; // Count the number of map entries in db table

    List<Timetable> timetableList = List<Timetable>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      var _temp = Timetable.fromMapObject(timetableMapList[i]);
      timetableList.add(_temp);
    }
    return timetableList;
  }

// Select all recuring timetable
  Future<List<Timetable>> getAllRecurringTimetable(
      String courseCode,
      String courseType,
      String courseStartDate,
      String courseStartTime,
      String startDate,
      String recurring) async {
    var timetableMapList = await getAllRecurringTimetableMapList(
        courseCode,
        courseType,
        courseStartDate,
        courseStartTime,
        startDate,
        recurring); // Get 'Map List' from database
    int count =
        timetableMapList.length; // Count the number of map entries in db table

    List<Timetable> timetableList = List<Timetable>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      var _temp = Timetable.fromMapObject(timetableMapList[i]);
      timetableList.add(_temp);
    }
    return timetableList;
  }

  // Select all timetable current week
  Future<List<Timetable>> getCurWeekTimetable() async {
    DateTime today = DateFormat("yyyy-MM-dd")
        .parse(DateFormat("yyyy-MM-dd").format(DateTime.now()));
    DateTime datetimeWeekStart =
        today.subtract(new Duration(days: today.weekday - 1));
    String weekStart = DateFormat("yyyy-MM-dd").format(datetimeWeekStart);
    String weekEnd = DateFormat("yyyy-MM-dd")
        .format(datetimeWeekStart.add(new Duration(days: 6)));
    var timetableMapList = await getCurWeekTimetableMapList(
        weekStart, weekEnd); // Get 'Map List' from database
    int count =
        timetableMapList.length; // Count the number of map entries in db table

    List<Timetable> timetableList = List<Timetable>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      var _temp = Timetable.fromMapObject(timetableMapList[i]);
      timetableList.add(_temp);
    }
    return timetableList;
  }
}
