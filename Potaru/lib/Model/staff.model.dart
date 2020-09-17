class Staff {
  String _sid;
  String _facultyCode;
  String _administrativePost1;
  String _administrativePost2;
  String _department;
  String _designation;
  String _email;
  String _expertise;
  String _faculty;
  String _name;
  String _proQualification;
  String _qualification;
  String _telNo1;
  String _telNo2;
  String _roomNo;

  Staff(
      this._sid,
      this._facultyCode,
      this._administrativePost1,
      this._administrativePost2,
      this._department,
      this._designation,
      this._email,
      this._expertise,
      this._faculty,
      this._name,
      this._proQualification,
      this._qualification,
      this._telNo1,
      this._telNo2,
      this._roomNo);

  String get sid => _sid;
  String get facultyCode => _facultyCode;
  String get administrativePost1 => _administrativePost1;
  String get administrativePost2 => _administrativePost2;
  String get department => _department;
  String get designation => _designation;
  String get email => _email;
  String get expertise => _expertise;
  String get faculty => _faculty;
  String get name => _name;
  String get proQualification => _proQualification;
  String get qualification => _qualification;
  String get telNo1 => _telNo1;
  String get telNo2 => _telNo2;
  String get roomNo => _roomNo;

  set sid(String value) {
    _sid = value;
  }

  set facultyCode(String value) {
    _facultyCode = value;
  }

  set administrativePost1(String value) {
    _administrativePost1 = value;
  }

  set administrativePost2(String value) {
    _administrativePost2 = value;
  }

  set department(String value) {
    _department = value;
  }

  set designation(String value) {
    _designation = value;
  }

  set email(String value) {
    _email = value;
  }

  set expertise(String value) {
    _expertise = value;
  }

  set faculty(String value) {
    _faculty = value;
  }

  set name(String value) {
    _name = value;
  }

  set proQualification(String value) {
    _proQualification = value;
  }

  set qualification(String value) {
    _qualification = value;
  }

  set telNo1(String value) {
    _telNo1 = value;
  }

  set telNo2(String value) {
    _telNo2 = value;
  }

  set roomNo(String value) {
    _roomNo = value;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map['sid'] = _sid;
    map['facultyCode'] = _facultyCode;
    map['administrativePost1'] = _administrativePost1;
    map['administrativePost2'] = _administrativePost2;
    map['department'] = _department;
    map['designation'] = _designation;
    map['email'] = _email;
    map['expertise'] = _expertise;
    map['faculty'] = _faculty;
    map['name'] = _name;
    map['proQualification'] = _proQualification;
    map['qualification'] = _qualification;
    map['telNo1'] = _telNo1;
    map['telNo2'] = _telNo2;
    map['roomNo'] = _roomNo;
    return map;
  }

  Staff.fromMapObject(Map<String, dynamic> map) {
    this._sid = map['sid'];
    this._facultyCode = map['facultyCode'];
    this._administrativePost1 = map['administrativePost1'];
    this._administrativePost2 = map['administrativePost2'];
    this._department = map['department'];
    this._designation = map['designation'];
    this._email = map['email'];
    this._expertise = map['expertise'];
    this._faculty = map['faculty'];
    this._name = map['name'];
    this._proQualification = map['proQualification'];
    this._qualification = map['qualification'];
    this._telNo1 = map['telNo1'];
    this._telNo2 = map['telNo2'];
    this._roomNo = map['roomNo'];
  }
}
