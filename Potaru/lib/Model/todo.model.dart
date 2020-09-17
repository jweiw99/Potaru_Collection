class Todo {
  String _tid;
  String _title;
  String _desc;
  int _recurring;
  String _recType;
  int _status;
  int _priority;
  int _remind;
  String _remindTime;
  String _startTime;
  String _endTime;

  Todo(
      this._tid,
      this._title,
      this._desc,
      this._status,
      this._recurring,
      this._recType,
      this._remind,
      this._remindTime,
      this._priority,
      this._startTime,
      this._endTime);

  String get tid => _tid;
  String get title => _title;
  String get desc => _desc;
  String get startTime => _startTime;
  String get endTime => _endTime;
  int get recurring => _recurring;
  String get recType => _recType;
  int get priority => _priority;
  int get status => _status;
  int get remind => _remind;
  String get remindTime => _remindTime;

  set tid(String value) {
    _tid = value;
  }

  set title(String value) {
    _title = value;
  }

  set desc(String value) {
    _desc = value;
  }

  set startTime(String value) {
    _startTime = value;
  }

  set endTime(String value) {
    _endTime = value;
  }

  set recurring(int value) {
    _recurring = value;
  }

  set recType(String value) {
    _recType = value;
  }

  set priority(int value) {
    _priority = value;
  }

  set status(int value) {
    _status = value;
  }

  set remind(int value) {
    _remind = value;
  }

  set remindTime(String value) {
    _remindTime = value;
  }

  Map<dynamic, dynamic> toMap() {
    var map = Map<dynamic, dynamic>();
    map['tid'] = _tid;
    map['title'] = _title;
    map['desc'] = _desc;
    map['startTime'] = _startTime;
    map['endTime'] = _endTime;
    map['recurring'] = _recurring;
    map['recType'] = _recType;
    map['priority'] = _priority;
    map['status'] = _status;
    map['remind'] = _remind;
    map['remindTime'] = _remindTime;
    return map;
  }

  Todo.fromMapObject(Map<dynamic, dynamic> map) {
    this._tid = map['tid'].toString();
    this._title = map['title'].toString();
    this._desc = map['desc'].toString();
    this._startTime = map['startTime'].toString();
    this._endTime = map['endTime'].toString();
    this._recurring = int.parse(map['recurring'].toString());
    this._recType = map['recType'].toString();
    this._priority = int.parse(map['priority'].toString());
    this._status = int.parse(map['status'].toString());
    this._remind = int.parse(map['remind'].toString());
    this._remindTime = map['remindTime'].toString();
  }
}
