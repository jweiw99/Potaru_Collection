class Grade {
  String _session;
  String _courseCode;
  String _courseName;
  String _courseType;
  int _status;
  String _grade;

  Grade(this._session, this._courseCode, this._courseName, this._courseType,
      this._status, this._grade);

  String get session => _session;
  String get courseCode => _courseCode;
  String get courseName => _courseName;
  String get courseType => _courseType;
  int get status => _status;
  String get grade => _grade;

  set session(String value) {
    _session = value;
  }

  set courseCode(String value) {
    _courseCode = value;
  }

  set courseName(String value) {
    _courseName = value;
  }

  set courseType(String value) {
    _courseType = value;
  }

  set status(int value) {
    _status = value;
  }

  set grade(String value) {
    _grade = value;
  }

  Map<dynamic, dynamic> toMap() {
    var map = Map<dynamic, dynamic>();
    map['session'] = _session;
    map['courseCode'] = _courseCode;
    map['courseName'] = _courseName;
    map['courseType'] = _courseType;
    map['status'] = _status;
    map['grade'] = _grade;
    return map;
  }

  Grade.fromMapObject(Map<dynamic, dynamic> map) {
    this._session = map['session'].toString();
    this._courseCode = map['courseCode'].toString();
    this._courseName = map['courseName'].toString();
    this._courseType = map['courseType'].toString();
    this._status = int.parse(map['status'].toString());
    this._grade = map['grade'].toString();
  }
}
