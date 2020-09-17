import 'package:sqflite/sqflite.dart';

import 'package:potaru/database/database_helper.dart';
import 'package:potaru/Model/task.model.dart';

class TaskController {
  String tableName = 'Task';

  DataBaseHelper dbHelp = DataBaseHelper();

  TaskController() : super();

  Future<DataBaseHelper> get databaseHelper async {
    return dbHelp;
  }

  Future<List<Map<String, dynamic>>> getTaskMapList(String tid) async {
    Database db = await dbHelp.database;
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE tid == "$tid" ORDER BY date, no');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  Future<List<Map<String, dynamic>>> getLastTaskDateMapList(String tid) async {
    Database db = await dbHelp.database;
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE tid == "$tid" GROUP BY date ORDER BY date DESC LIMIT 1');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  Future<List<Map<String, dynamic>>> getRecurringTaskMapList(
      String tid, String date) async {
    Database db = await dbHelp.database;
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE  tid == "$tid" AND date == "$date" ORDER BY no');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  // Insert or Update
  Future<int> insertTask(Task task) async {
    Database db = await dbHelp.database;
    var result = await db.rawInsert(
        'INSERT OR REPLACE INTO $tableName (tid, no, task, date, completed)' +
            ' VALUES ("' +
            task.tid +
            '",' +
            task.no.toString() +
            ',"' +
            task.task +
            '","' +
            task.date +
            '",' +
            task.completed.toString() +
            ');');

    return result;
  }

  // Delete by tid
  Future<int> removeTaskBytid(String tid) async {
    Database db = await dbHelp.database;
    var result =
        await db.rawDelete('DELETE FROM $tableName WHERE tid == "$tid";');

    return result;
  }

  // Delete by tid
  Future<int> removeTaskByRecurringDate(String tid, String date) async {
    Database db = await dbHelp.database;
    var result = await db.rawDelete(
        'DELETE FROM $tableName WHERE tid == "$tid" AND date == "$date";');

    return result;
  }

  // Delete by tid
  Future<int> removeTaskByDate(Task task) async {
    Database db = await dbHelp.database;
    var result = await db.rawDelete('DELETE FROM $tableName WHERE tid == "' +
        task.tid +
        '" AND no == ' +
        task.no.toString() +
        ' AND date == "' +
        task.date +
        '";');

    return result;
  }

  // Select by tid
  Future<List<Task>> getTaskList(String tid) async {
    var taskMapList = await getTaskMapList(tid); // Get 'Map List' from database
    int count =
        taskMapList.length; // Count the number of map entries in db table

    List<Task> taskList = List<Task>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      var _temp = Task.fromMapObject(taskMapList[i]);
      taskList.add(_temp);
    }
    return taskList;
  }

  // Select by tid
  Future<String> getLastTaskDateList(String tid) async {
    var taskMapList =
        await getLastTaskDateMapList(tid); // Get 'Map List' from database
    int count =
        taskMapList.length; // Count the number of map entries in db table

    String date = "";
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      var _temp = Task.fromMapObject(taskMapList[i]);
      date = _temp.date;
    }
    return date;
  }

  // Select by tid
  Future<List<Task>> getRecurringTaskList(String tid, String date) async {
    var taskMapList = await getRecurringTaskMapList(
        tid, date); // Get 'Map List' from database
    int count =
        taskMapList.length; // Count the number of map entries in db table

    List<Task> taskList = List<Task>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      var _temp = Task.fromMapObject(taskMapList[i]);
      taskList.add(_temp);
    }
    return taskList;
  }
}
