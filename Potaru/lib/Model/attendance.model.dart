class Attendance {
  String _session;
  String _courseCode;
  String _courseType;
  String _courseDate;
  String _courseStartTime;
  String _attendance;

  Attendance(
      this._session,
      this._courseCode,
      this._courseType,
      this._courseDate,
      this._courseStartTime,
      this._attendance);

  String get session => _session;
  String get courseCode => _courseCode;
  String get courseType => _courseType;
  String get courseDate => _courseDate;
  String get courseStartTime => _courseStartTime;
  String get attendance => _attendance;

  set session(String value) {
    _session = value;
  }

  set courseCode(String value) {
    _courseCode = value;
  }

  set courseType(String value) {
    _courseType = value;
  }

  set courseDate(String value) {
    _courseDate = value;
  }

  set courseStartTime(String value) {
    _courseStartTime = value;
  }

  set attendance(String value) {
    _attendance = value;
  }

  Map<dynamic, dynamic> toMap() {
    var map = Map<dynamic, dynamic>();
    map['session'] = _session;
    map['courseCode'] = _courseCode;
    map['courseType'] = _courseType;
    map['courseDate'] = _courseDate;
    map['courseStartTime'] = _courseStartTime;
    map['attendance'] = _attendance;
    return map;
  }

  Attendance.fromMapObject(Map<dynamic, dynamic> map) {
    this._session = map['session'].toString();
    this._courseCode = map['courseCode'].toString();
    this._courseType = map['courseType'].toString();
    this._courseDate = map['courseDate'].toString();
    this._courseStartTime = map['courseStartTime'].toString();
    this._attendance = map['attendance'].toString();
  }
}
