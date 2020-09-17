import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';

import 'package:potaru/database/database_helper.dart';
import 'package:potaru/Model/todo.model.dart';

class TodoController {
  String tableName = 'Todo';

  DataBaseHelper dbHelp = DataBaseHelper();

  TodoController() : super();

  Future<DataBaseHelper> get databaseHelper async {
    return dbHelp;
  }

  Future<List<Map<String, dynamic>>> getTodoMapList() async {
    Database db = await dbHelp.database;
    var result = await db.rawQuery(
        'SELECT * FROM $tableName ORDER BY priority, title');
    //var result = await db.query(tableName, orderBy: '$id ASC');
    return result;
  }

  // Insert or Update
  Future<int> insertTodo(Todo todo) async {
    Database db = await dbHelp.database;
    var result = await db.rawInsert(
        'INSERT OR REPLACE INTO $tableName (tid, title, desc, recurring, recType, remind, remindTime, startTime, endTime, priority, status)' +
            ' VALUES ("' +
            todo.tid +
            '","' +
            todo.title +
            '","' +
            todo.desc +
            '",' +
            todo.recurring.toString() +
            ',"' +
            todo.recType +
            '",' +
            todo.remind.toString() +
            ',"' +
            todo.remindTime +
            '","' +
            todo.startTime +
            '","' +
            todo.endTime +
            '",' +
            todo.priority.toString() +
            ',' +
            todo.status.toString() +
            ');');

    return result;
  }

  // Delete by tid
  Future<int> removeTodoByID(String tid) async {
    Database db = await dbHelp.database;
    var result =
        await db.rawDelete('DELETE FROM $tableName WHERE tid == "$tid";');

    return result;
  }

  // Select by date
  Future<List<Todo>> getTodoList(DateTime date) async {
    var todoMapList = await getTodoMapList(); // Get 'Map List' from database
    int count =
        todoMapList.length; // Count the number of map entries in db table

    var _now =
        DateFormat("yyyy-MM-dd").parse(DateFormat("yyyy-MM-dd").format(date));
    Map<String, int> subString = {"D": 5, "M": 8, "Y": 5};
    List<Todo> todoList = List<Todo>();
    // For loop to create a 'Note List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      var _temp = Todo.fromMapObject(todoMapList[i]);
      var _endDate =
          DateFormat("yyyy-MM-dd").parse(_temp.endTime).add(Duration(days: 1));
      if (_temp.recurring == 0) {
        var _startDate = DateFormat("yyyy-MM-dd")
            .parse(_temp.startTime)
            .subtract(Duration(days: 1));
        if (_now.isAfter(_startDate) && _endDate.isAfter(_now)) {
          todoList.add(_temp);
        }
      } else if (_now.isAfter(_endDate.subtract(Duration(days: 2)))) {
        if (_temp.recType == "D") {
          todoList.add(_temp);
        } else if (_temp.recType == "W") {
          _endDate = DateFormat("yyyy-MM-dd").parse(_temp.endTime);
          if (_now.difference(_endDate).inDays % 7 == 0) {
            todoList.add(_temp);
          }
        } else {
          var _endTime = _temp.endTime.substring(subString[_temp.recType], 10);
          var dateFormat = _temp.recType == "Y" ? "MM-dd" : "dd";
          var _nowTime = DateFormat(dateFormat).format(_now);
          if (_endTime == _nowTime) {
            todoList.add(_temp);
          }
        }
      }
    }
    return todoList;
  }

  Future<List<Todo>> getTodayTodoList() async {
    List<Todo> todoList = await getTodoList(DateTime.now());
    todoList = todoList.where((todo) => todo.remind == 1).toList();
    return todoList;
  }
}
