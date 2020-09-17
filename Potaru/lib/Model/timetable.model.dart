class Timetable {
  String _courseCode;
  String _courseName;
  String _courseType;
  String _courseDate;
  String _startDate;
  String _courseStartTime;
  String _courseEndTime;
  int _courseGroup;
  double _courseHrs;
  String _courseVenue;
  String _lecturerID;
  String _lecturerName;
  int _remind;
  String _courseStartDate;
  String _recurring;

  Timetable(
      this._courseCode,
      this._courseName,
      this._courseType,
      this._courseGroup,
      this._courseDate,
      this._startDate,
      this._courseStartTime,
      this._courseEndTime,
      this._courseHrs,
      this._courseVenue,
      this._lecturerID,
      this._lecturerName,
      this._remind,
      this._courseStartDate,
      this._recurring);

  String get courseCode => _courseCode;
  String get courseName => _courseName;
  String get courseType => _courseType;
  int get courseGroup => _courseGroup;
  String get courseDate => _courseDate;
  String get startDate => _startDate;
  String get courseStartTime => _courseStartTime;
  String get courseEndTime => _courseEndTime;
  double get courseHrs => _courseHrs;
  String get courseVenue => _courseVenue;
  String get lecturerID => _lecturerID;
  String get lecturerName => _lecturerName;
  int get remind => _remind;
  String get courseStartDate => _courseStartDate;
  String get recurring => _recurring;

  set courseCode(String value) {
    _courseCode = value;
  }

  set courseName(String value) {
    _courseName = value;
  }

  set courseType(String value) {
    _courseType = value;
  }

  set courseGroup(int value) {
    _courseGroup = value;
  }

  set courseDate(String value) {
    _courseDate = value;
  }

  set startDate(String value) {
    _startDate = value;
  }

  set courseStartTime(String value) {
    _courseStartTime = value;
  }

  set courseEndTime(String value) {
    _courseEndTime = value;
  }

  set courseHrs(double value) {
    _courseHrs = value;
  }

  set courseVenue(String value) {
    _courseVenue = value;
  }

  set lecturerID(String value) {
    _lecturerID = value;
  }

  set lecturerName(String value) {
    _lecturerName = value;
  }

  set remind(int value) {
    _remind = value;
  }

  set courseStartDate(String value) {
    _courseStartDate = value;
  }

  set recurring(String value) {
    _recurring = value;
  }

  Map<dynamic, dynamic> toMap() {
    var map = Map<dynamic, dynamic>();
    map['courseCode'] = _courseCode;
    map['courseName'] = _courseName;
    map['courseType'] = _courseType;
    map['courseGroup'] = _courseGroup;
    map['courseDate'] = _courseDate;
    map['startDate'] = _startDate;
    map['courseStartTime'] = _courseStartTime;
    map['courseEndTime'] = _courseEndTime;
    map['courseHrs'] = _courseHrs;
    map['courseVenue'] = _courseVenue;
    map['lecturerID'] = _lecturerID;
    map['lecturerName'] = _lecturerName;
    map['remind'] = _remind;
    map['courseStartDate'] = _courseStartDate;
    map['recurring'] = _recurring;
    return map;
  }

  Timetable.fromMapObject(Map<dynamic, dynamic> map) {
    this._courseCode = map['courseCode'].toString();
    this._courseName = map['courseName'].toString();
    this._courseType = map['courseType'].toString();
    this._courseGroup = int.parse(map['courseGroup'].toString());
    this._courseDate = map['courseDate'].toString();
    this._startDate = map['startDate'].toString();
    this._courseStartTime = map['courseStartTime'].toString();
    this._courseEndTime = map['courseEndTime'].toString();
    this._courseHrs = double.parse(map['courseHrs'].toString());
    this._courseVenue = map['courseVenue'].toString();
    this._lecturerID = map['lecturerID'].toString();
    this._lecturerName = map['lecturerName'].toString();
    this._remind = int.parse(map['remind'].toString());
    this._courseStartDate = map['courseStartDate'].toString();
    this._recurring = map['recurring'].toString();
  }
}
