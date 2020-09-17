
class Faculty {
  String _code;
  String _name;

  Faculty(this._code, this._name);

  String get code => _code;
  String get name => _name;
  String get title => _name;

  set code(String value) {
    _code = value;
  }

  set name(String value) {
    _name = value;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['code'] = _code;
    map['name'] = _name;
    return map;
  }

  Faculty.fromMapObject(Map<String, dynamic> map) {
    this._code = map['code'];
    this._name = map['name'];
  }
}

