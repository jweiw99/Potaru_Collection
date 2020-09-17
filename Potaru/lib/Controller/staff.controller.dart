import 'package:sqflite/sqflite.dart';

import 'package:potaru/Model/staff.model.dart';
import 'package:potaru/database/database_helper.dart';

class StaffController {
  String tableName = 'Staff';

  DataBaseHelper dbHelp = DataBaseHelper();

  StaffController() : super();

  Future<DataBaseHelper> get databaseHelper async {
    return dbHelp;
  }

  Future<List<Map<String, dynamic>>> getStaffMapList() async {
    Database db = await dbHelp.database;

    var result = await db.rawQuery(
        'SELECT * FROM $tableName ORDER BY facultyCode ASC , administrativePost1 IS NULL');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  // Insert

  Future<int> insertStaff(Staff staff) async {
    Database db = await dbHelp.database;
    var result = await db.insert(tableName, staff.toMap());
    return result;
  }

  // Delete all

  Future<int> removeStaff() async {
    Database db = await dbHelp.database;
    var result = db.delete(tableName);
    return result;
  }

  // Select all

  Future<List<Staff>> getStaffList() async {
    var staffMapList = await getStaffMapList(); // Get 'Map List' from database
    int count =
        staffMapList.length; // Count the number of map entries in db table

    List<Staff> staffList = List<Staff>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      staffList.add(Staff.fromMapObject(staffMapList[i]));
    }

    return staffList;
  }

  // Select by id

  Future<List<Staff>> getStaffByID(String id) async {
    Database db = await dbHelp.database;

    var result =
        await db.rawQuery('SELECT * FROM $tableName WHERE Staff.sid = "$id"');

    int count = result.length; // Count the number of map entries in db table

    List<Staff> staffList = List<Staff>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      staffList.add(Staff.fromMapObject(result[i]));
    }

    return staffList;
  }
}
