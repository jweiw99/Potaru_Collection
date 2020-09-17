import 'package:sqflite/sqflite.dart';

import 'package:potaru/Model/grade.model.dart';
import 'package:potaru/database/database_helper.dart';

class GradeController {
  String tableName = 'SubjectGrade';

  DataBaseHelper dbHelp = DataBaseHelper();

  GradeController() : super();

  Future<DataBaseHelper> get databaseHelper async {
    return dbHelp;
  }

  Future<List<Map<String, dynamic>>> getSubjectMapList(String session) async {
    Database db = await dbHelp.database;
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE session == "$session" ORDER BY courseCode');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  Future<List<Map<String, dynamic>>> getAllSubjectMapList() async {
    Database db = await dbHelp.database;
    var result = await db.rawQuery(
        'SELECT * FROM $tableName ORDER BY session DESC, courseName');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  Future<List<Map<String, dynamic>>> getSubjectByGradeMapList(
      String grade) async {
    Database db = await dbHelp.database;
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE grade == "$grade" ORDER BY session');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  // Insert
  Future<int> insertSubject(Grade grade) async {
    Database db = await dbHelp.database;
    var result = await db.rawInsert(
        'INSERT OR IGNORE INTO $tableName (session, courseCode, courseName, courseType, status, grade)' +
            ' VALUES ("' +
            grade.session +
            '","' +
            grade.courseCode +
            '","' +
            grade.courseName +
            '","' +
            grade.courseType +
            '",' +
            grade.status.toString() +
            ',"' +
            grade.grade +
            '");');

    return result;
  }

  // Update subject grade
  Future<int> updateSubject(Grade grade) async {
    Database db = await dbHelp.database;
    var result = await db.rawInsert('UPDATE $tableName' +
        ' SET grade = "' +
        grade.grade +
        '" WHERE session = "' +
        grade.session +
        '" AND courseCode = "' +
        grade.courseCode +
        '";');

    return result;
  }

  // Update Status
  Future<int> updateStatus(Grade grade) async {
    Database db = await dbHelp.database;
    var result = await db.rawInsert('UPDATE $tableName' +
        ' SET status = ' +
        grade.status.toString() +
        ' WHERE session = "' +
        grade.session +
        '" AND courseCode = "' +
        grade.courseCode +
        '";');

    return result;
  }

  // Select All semester Subject
  Future<List<Map<String, String>>> getAllSubjectList() async {
    var gradeMapList =
        await getAllSubjectMapList(); // Get 'Map List' from database
    int count =
        gradeMapList.length; // Count the number of map entries in db table

    List<Map<String, String>> gradeList = List<Map<String, String>>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      var _temp = Grade.fromMapObject(gradeMapList[i]);
      gradeList.add({
        "session": _temp.session,
        "courseCode": _temp.courseCode,
        "courseName": _temp.courseName
      });
    }
    return gradeList;
  }

  // Select current semester Subject with Grade
  Future<List<Grade>> getSubjectList(String session) async {
    var gradeMapList =
        await getSubjectMapList(session); // Get 'Map List' from database
    int count =
        gradeMapList.length; // Count the number of map entries in db table

    List<Grade> gradeList = List<Grade>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      var _temp = Grade.fromMapObject(gradeMapList[i]);
      gradeList.add(_temp);
    }
    return gradeList;
  }

  // Select  Subject by Grade
  Future<List<Grade>> getSubjectByGradeList(String grade) async {
    var gradeMapList =
        await getSubjectByGradeMapList(grade); // Get 'Map List' from database
    int count =
        gradeMapList.length; // Count the number of map entries in db table

    List<Grade> gradeList = List<Grade>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      var _temp = Grade.fromMapObject(gradeMapList[i]);
      gradeList.add(_temp);
    }
    return gradeList;
  }
}
