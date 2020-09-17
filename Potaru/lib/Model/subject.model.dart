class Subject {
  String _courseCode;
  String _courseName;
  List<SubTypeHrs> _subTypeHrs;
  String _startDate;

  Subject(
      this._courseCode, this._courseName, this._subTypeHrs, this._startDate);

  String get courseCode => _courseCode;
  String get courseName => _courseName;
  List<SubTypeHrs> get subTypeHrs => _subTypeHrs;
  String get startDate => _startDate;

  set courseCode(String value) {
    _courseCode = value;
  }

  set courseName(String value) {
    _courseName = value;
  }

  set subTypeHrs(List<SubTypeHrs> value) {
    _subTypeHrs = value;
  }

  set startDate(String value) {
    _startDate = value;
  }
}

class SubTypeHrs {
  String _courseType;
  String _courseDate;
  double _courseHrs;
  String _courseStartTime;
  String _courseEndTime;

  SubTypeHrs(this._courseType, this._courseDate, this._courseHrs,
      this._courseStartTime,
      this._courseEndTime);

  String get courseType => _courseType;
  String get courseDate => _courseDate;
  double get courseHrs => _courseHrs;
  String get courseStartTime => _courseStartTime;
  String get courseEndTime => _courseEndTime;

  set courseType(String value) {
    _courseType = value;
  }

  set courseDate(String value) {
    _courseDate = value;
  }

  set courseHrs(double value) {
    _courseHrs = value;
  }

  set courseStartTime(String value) {
    _courseStartTime = value;
  }

  set courseEndTime(String value) {
    _courseEndTime = value;
  }
}
