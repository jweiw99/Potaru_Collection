import 'package:sqflite/sqflite.dart';

import 'package:potaru/Model/cgpa.model.dart';
import 'package:potaru/database/database_helper.dart';

class CGPAController {
  String tableName = 'CGPA';

  DataBaseHelper dbHelp = DataBaseHelper();

  CGPAController() : super();

  Future<DataBaseHelper> get databaseHelper async {
    return dbHelp;
  }

  Future<List<Map<String, dynamic>>> getCGPAMapList() async {
    Database db = await dbHelp.database;
    var result = await db
        .rawQuery('SELECT * FROM $tableName ORDER BY session');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  Future<List<Map<String, dynamic>>> getSemCGPAMapList(String session) async {
    Database db = await dbHelp.database;
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE session = "$session"');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  // Insert
  Future<int> insertCGPA(CGPA cgpa) async {
    Database db = await dbHelp.database;
    var result = await db.rawInsert(
        'INSERT OR IGNORE INTO $tableName (session, gpa, cgpa, creditHrs)' +
            ' VALUES ("' +
            cgpa.session +
            '",' +
            cgpa.gpa.toString() +
            ',' +
            cgpa.cgpa.toString() +
            ',' +
            cgpa.creditHrs.toString() +
            ');');

    return result;
  }

  Future<int> updateCGPA(CGPA cgpa) async {
    Database db = await dbHelp.database;
    var result = await db.rawInsert('UPDATE $tableName' +
        ' SET cgpa = ' +
        cgpa.cgpa.toString() +
        ', creditHrs = ' +
        cgpa.creditHrs.toString() +
        ', gpa = ' +
        cgpa.gpa.toString() +
        ' WHERE session = "' +
        cgpa.session +
        '";');

    return result;
  }

  // Select All sem CGPA
  Future<List<CGPA>> getCGPAList() async {
    var cgpaMapList = await getCGPAMapList(); // Get 'Map List' from database
    int count =
        cgpaMapList.length; // Count the number of map entries in db table

    List<CGPA> cgpaList = List<CGPA>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      var _temp = CGPA.fromMapObject(cgpaMapList[i]);
      cgpaList.add(_temp);
    }
    return cgpaList;
  }

  // Select current semester CGPA
  Future<List<CGPA>> getSemCGPAList(String session) async {
    var cgpaMapList =
        await getSemCGPAMapList(session); // Get 'Map List' from database
    int count =
        cgpaMapList.length; // Count the number of map entries in db table

    List<CGPA> cgpaList = List<CGPA>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      var _temp = CGPA.fromMapObject(cgpaMapList[i]);
      cgpaList.add(_temp);
    }
    return cgpaList;
  }
}
