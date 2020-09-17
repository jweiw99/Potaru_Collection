class Semester {
  String _session;
  String _startDate;
  String _endDate;
  int _totalWeek;

  Semester(
      this._session,
      this._startDate,
      this._endDate,
      this._totalWeek);

  String get session => _session;
  String get startDate => _startDate;
  String get endDate => _endDate;
  int get totalWeek => _totalWeek;

  set session(String value) {
    _session = value;
  }

  set startDate(String value) {
    _startDate = value;
  }

  set endDate(String value) {
    _endDate = value;
  }

  set totalWeek(int value) {
    _totalWeek = value;
  }

  Map<dynamic, dynamic> toMap() {
    var map = Map<dynamic, dynamic>();
    map['session'] = _session;
    map['startDate'] = _startDate;
    map['endDate'] = _endDate;
    map['totalWeek'] = _totalWeek;
    return map;
  }

  Semester.fromMapObject(Map<dynamic, dynamic> map) {
    this._session = map['session'].toString();
    this._startDate = map['startDate'].toString();
    this._endDate = map['endDate'].toString();
    this._totalWeek = int.parse(map['totalWeek'].toString());
  }
}
