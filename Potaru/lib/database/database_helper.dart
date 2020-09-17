import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:io';

class DataBaseHelper {
  static DataBaseHelper _databaseHelper;
  static Database _database;

  DataBaseHelper._creatInstance();

  DataBaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DataBaseHelper._creatInstance();
    }
  }

  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + '/potaru.db';
    var utdatabase = await openDatabase(path, version: 1, onCreate: _creatDB);
    return utdatabase;
  }

  void _creatDB(Database db, int newVersion) async {
    await db.execute("""CREATE TABLE Version(
          app TEXT PRIMARY KEY
          , lastUpdateDate INTEGER
          )""");
    await db.execute("""CREATE TABLE Faculty(
          code TEXT PRIMARY KEY
          , name TEXT
          )""");
    await db.execute("""CREATE TABLE Staff(
          sid TEXT
          , facultyCode TEXT
          , administrativePost1 TEXT
          , administrativePost2 TEXT
          , department TEXT
          , designation TEXT
          , email TEXT
          , expertise TEXT
          , faculty TEXT
          , name TEXT
          , proQualification TEXT
          , qualification TEXT
          , telNo1 TEXT
          , telNo2 TEXT
          , roomNo TEXT
          , PRIMARY KEY(sid,facultyCode)
          )""");
    await db.execute("""CREATE TABLE Timetable(
          courseCode TEXT
          , courseName TEXT
          , courseType TEXT
          , courseDate TEXT
          , startDate TEXT
          , courseStartTime TEXT
          , courseEndTime TEXT
          , courseGroup INTEGER
          , courseHrs REAL
          , courseVenue TEXT
          , lecturerID TEXT
          , lecturerName TEXT
          , remind INTEGER
          , courseStartDate TEXT
          , recurring TEXT
          , PRIMARY KEY(courseCode,courseName,courseType,courseDate,courseStartTime)
          )""");
    await db.execute("""CREATE TABLE Attendance(
          session TEXT
          , courseCode TEXT
          , courseType TEXT
          , courseDate TEXT
          , courseStartTime TEXT
          , attendance TEXT
          , PRIMARY KEY(session,courseCode,courseType,courseDate,courseStartTime)
          )""");
    await db.execute("""CREATE TABLE Semester(
          session TEXT
          , startDate TEXT
          , endDate TEXT
          , totalWeek INTEGER
          , PRIMARY KEY(session)
          )""");
    await db.execute("""CREATE TABLE CGPA(
          session TEXT
          , gpa REAL
          , cgpa REAL
          , creditHrs INTEGER
          , PRIMARY KEY(session)
          )""");
    await db.execute("""CREATE TABLE SubjectGrade(
          session TEXT
          , courseCode TEXT
          , courseName TEXT
          , courseType TEXT
          , status INTEGER
          , grade TEXT
          , PRIMARY KEY(session,courseCode)
          )""");
    await db.execute("""CREATE TABLE Todo(
          tid TEXT
          , title TEXT
          , desc TEXT
          , recurring INTEGER
          , recType TEXT
          , remind INTEGER
          , remindTime TEXT
          , startTime TEXT
          , endTime TEXT
          , priority INTEGER
          , status INTEGER
          , PRIMARY KEY(tid)
          )""");
    await db.execute("""CREATE TABLE Task(
          tid TEXT
          , no INTEGER
          , task TEXT
          , date TEXT
          , completed INTEGER
          , PRIMARY KEY(tid,no,date)
          )""");
  }

  Future<Database> get database async {
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<DataBaseHelper> get databaseHelper async {
    return _databaseHelper;
  }
}
