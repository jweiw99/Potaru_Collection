import 'package:sqflite/sqflite.dart';

import 'package:potaru/Model/semester.model.dart';
import 'package:potaru/database/database_helper.dart';

class SemesterController {
  String tableName = 'Semester';

  DataBaseHelper dbHelp = DataBaseHelper();

  SemesterController() : super();

  Future<DataBaseHelper> get databaseHelper async {
    return dbHelp;
  }

  Future<List<Map<String, dynamic>>> getActiveSemesterMap() async {
    Database db = await dbHelp.database;
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE startDate != "" AND startDate is not null');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  Future<List<Map<String, dynamic>>> getSemesterBySessionMap(
      String session) async {
    Database db = await dbHelp.database;
    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE session == "$session"');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  Future<List<Map<String, dynamic>>> getSemesterByStartDateMap(
      String startDate) async {
    Database db = await dbHelp.database;
    var result = await db
        .rawQuery('SELECT * FROM $tableName WHERE startDate == "$startDate"');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  Future<List<Map<String, dynamic>>> getSemesterMapList() async {
    Database db = await dbHelp.database;
    var result =
        await db.rawQuery('SELECT * FROM $tableName ORDER BY session DESC');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  Future<List<Map<String, dynamic>>> getPrevSemesterMapList() async {
    Database db = await dbHelp.database;
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE date(\'now\') >= endDate ORDER BY session DESC');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  // Insert
  Future<int> insertSemester(Semester semester) async {
    Database db = await dbHelp.database;
    var result = await db.rawInsert(
        'INSERT OR REPLACE INTO $tableName (session, startDate, endDate, totalWeek)' +
            ' VALUES ("' +
            semester.session +
            '","' +
            semester.startDate +
            '","' +
            semester.endDate +
            '",' +
            semester.totalWeek.toString() +
            ');');

    return result;
  }

  // Select active semester
  Future<List<Semester>> getActiveSemester() async {
    var semesterMapList =
        await getActiveSemesterMap(); // Get 'Map List' from database
    int count =
        semesterMapList.length; // Count the number of map entries in db table

    List<Semester> semesterList = [];
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      var _temp = Semester.fromMapObject(semesterMapList[i]);
      semesterList.add(_temp);
    }
    return semesterList;
  }

  // Select by session
  Future<Semester> getSemesterBySession(String session) async {
    var semesterMapList =
        await getSemesterBySessionMap(session); // Get 'Map List' from database
    int count =
        semesterMapList.length; // Count the number of map entries in db table

    Semester semesterList = Semester("", "", "", 0);
    if (count > 0) {
      semesterList = Semester.fromMapObject(semesterMapList[0]);
    }
    return semesterList;
  }

  // Select by Start Date
  Future<Semester> getSemesterByStartDate(String startDate) async {
    var semesterMapList = await getSemesterByStartDateMap(
        startDate); // Get 'Map List' from database
    int count =
        semesterMapList.length; // Count the number of map entries in db table

    Semester semesterList = Semester("", "", "", 0);
    if (count > 0) {
      semesterList = Semester.fromMapObject(semesterMapList[0]);
    }
    return semesterList;
  }

  // Select all semester
  Future<List<Map<String, String>>> getSemesterList() async {
    var semesterMapList =
        await getSemesterMapList(); // Get 'Map List' from database
    int count =
        semesterMapList.length; // Count the number of map entries in db table

    List<Map<String, String>> semesterList = List<Map<String, String>>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      final s = Semester.fromMapObject(semesterMapList[i]);
      semesterList.add({
        "title": "Session " + s.session,
        "code": s.session,
        "startDate": s.startDate,
        "endDate": s.endDate,
        "totalWeek": s.totalWeek.toString()
      });
    }
    return semesterList;
  }

  // get Previous Semester
  Future<List<Map<String, String>>> getPrevSemesterList() async {
    var semesterMapList =
        await getPrevSemesterMapList(); // Get 'Map List' from database
    int count =
        semesterMapList.length; // Count the number of map entries in db table
    List<Map<String, String>> semesterList = List<Map<String, String>>();

    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      final s = Semester.fromMapObject(semesterMapList[i]);
      semesterList.add({
        "title": "Session " + s.session,
        "code": s.session,
        "startDate": s.startDate,
        "endDate": s.endDate,
        "totalWeek": s.totalWeek.toString()
      });
    }
    return semesterList;
  }
}
