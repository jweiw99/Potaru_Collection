class Task {
  String _tid;
  int _no;
  String _task;
  String _date;
  int _completed;

  Task(this._tid, this._no, this._task,this._date, this._completed);

  String get tid => _tid;
  int get no => _no;
  String get task => _task;
  String get date => _date;
  int get completed => _completed;

  set tid(String value) {
    _tid = value;
  }

  set no(int value) {
    _no = value;
  }

  set task(String value) {
    _task = value;
  }

  set date(String value) {
    _date = value;
  }

  set completed(int value) {
    _completed = value;
  }

  Map<dynamic, dynamic> toMap() {
    var map = Map<dynamic, dynamic>();
    map['tid'] = _tid;
    map['no'] = _no;
    map['task'] = _task;
    map['date'] = _date;
    map['completed'] = _completed;
    return map;
  }

  Task.fromMapObject(Map<dynamic, dynamic> map) {
    this._tid = map['tid'].toString();
    this._no = int.parse(map['no'].toString());
    this._task = map['task'].toString();
    this._date = map['date'].toString();
    this._completed = int.parse(map['completed'].toString());
  }
}
