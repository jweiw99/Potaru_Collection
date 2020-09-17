import 'package:sqflite/sqflite.dart';

import 'package:potaru/Model/faculty.model.dart';
import 'package:potaru/database/database_helper.dart';

class FacultyController {
  String tableName = 'Faculty';

  DataBaseHelper dbHelp = DataBaseHelper();

  FacultyController() : super();

  Future<DataBaseHelper> get databaseHelper async {
    return dbHelp;
  }

  Future<List<Map<String, dynamic>>> getFacultyMapList() async {
    Database db = await dbHelp.database;

    var result = await db.rawQuery('SELECT * FROM $tableName');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  // Insert
  Future<int> insertFaculty(Faculty faculty) async {
    Database db = await dbHelp.database;
    var result = await db.insert(tableName, faculty.toMap());
    return result;
  }

  // Delete all
  Future<int> removeFaculty() async {
    Database db = await dbHelp.database;
    var result = db.delete(tableName);
    return result;
  }

  // Select all

  Future<List<Map<String, String>>> getFacultyList() async {
    var facultyMapList =
        await getFacultyMapList(); // Get 'Map List' from database
    int count =
        facultyMapList.length; // Count the number of map entries in db table

    List<Map<String, String>> facultyList = List<Map<String, String>>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      final f = Faculty.fromMapObject(facultyMapList[i]);
      facultyList.add({"title": f.name, "code": f.code});
    }

    return facultyList;
  }
}
