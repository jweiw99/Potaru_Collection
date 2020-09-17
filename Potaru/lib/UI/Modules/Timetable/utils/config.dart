class TimetableConfig {
  TimetableConfig._();
  static Map<String, String> courseType = <String, String>{
    "T": "Tutorial",
    "P": "Practical",
    "A": "Event",
    "S": "Submission",
    "E": "Exam",
    "L": "Lecture"
  };
  static Map<String, String> recType = <String, String>{
    "N": "Select",
    "D": "Day",
    "W": "Week",
    "M": "Month"
  };
}
