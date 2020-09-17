class CGPA {
  String _session;
  double _gpa;
  double _cgpa;
  int _creditHrs;

  CGPA(this._session, this._gpa, this._cgpa, this._creditHrs);

  String get session => _session;
  double get gpa => _gpa;
  double get cgpa => _cgpa;
  int get creditHrs => _creditHrs;

  set session(String value) {
    _session = value;
  }

  set gpa(double value) {
    _gpa = value;
  }

  set cgpa(double value) {
    _cgpa = value;
  }

  set creditHrs(int value) {
    _creditHrs = value;
  }

  Map<dynamic, dynamic> toMap() {
    var map = Map<dynamic, dynamic>();
    map['session'] = _session;
    map['cgpa'] = _cgpa;
    map['gpa'] = _gpa;
    map['creditHrs'] = _creditHrs;
    return map;
  }

  CGPA.fromMapObject(Map<dynamic, dynamic> map) {
    this._session = map['session'].toString();
    this._gpa = double.parse(map['gpa'].toString());
    this._cgpa = double.parse(map['cgpa'].toString());
    this._creditHrs = int.parse(map['creditHrs'].toString());
  }
}
