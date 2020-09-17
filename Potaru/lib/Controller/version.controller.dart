import 'package:sqflite/sqflite.dart';

import 'package:potaru/Model/version.model.dart';
import 'package:potaru/database/database_helper.dart';

class VersionController {
  String tableName = 'Version';
  String fieldName = 'app';
  
  DataBaseHelper dbHelp = DataBaseHelper();

  VersionController() : super();

  Future<DataBaseHelper> get databaseHelper async {
    return dbHelp;
  }

  Future<List<Map<String, dynamic>>> getVersionMapList() async {
    Database db = await dbHelp.database;

    var result = await db.rawQuery('SELECT * FROM $tableName');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  // Select by

   Future<List<Map<String, dynamic>>> getVersion(String app) async {
    var db = await dbHelp.database;
    var result = await db.rawQuery('SELECT * FROM $tableName WHERE $fieldName = "$app"');
    return result;
  }

  // Insert

  Future<int> insertVersion(Version version) async {
    Database db = await dbHelp.database;
    var result = await db.insert(tableName, version.toMap());
    return result;
  }

  // Update

  Future<int> updateVersion(Version version) async {
    Database db = await dbHelp.database;
    var result = await db.update(tableName, version.toMap(),
        where: '$fieldName = ?', whereArgs: [version.app]);
    return result;
  }

  // Delete all
  Future<int> removeVersion() async {
    Database db = await dbHelp.database;
    var result = db.delete(tableName);
    return result;
  }

  // Select all

  Future<List<Version>> getVersionList() async {
    var versionMapList =
        await getVersionMapList(); // Get 'Map List' from database
    int count =
        versionMapList.length; // Count the number of map entries in db table

    List<Version> versionList = List<Version>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      versionList.add(Version.fromMapObject(versionMapList[i]));
    }

    return versionList;
  }
}
