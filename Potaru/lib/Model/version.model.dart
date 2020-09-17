
class Version {
  String _app;
  int _lastUpdateDate;

  Version(this._app, this._lastUpdateDate);

  String get app => _app;
  int get lastUpdateDate => _lastUpdateDate;

  set app(String value) {
    _app = value;
  }

  set lastUpdateDate(int value) {
    _lastUpdateDate = value;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['app'] = _app;
    map['lastUpdateDate'] = _lastUpdateDate;
    return map;
  }

  Version.fromMapObject(Map<String, dynamic> map) {
    this._app = map['app'];
    this._lastUpdateDate = map['lastUpdateDate'];
  }
}

