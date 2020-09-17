double calcAlgorithm(int gpa, int credit) {
  Map<int, int> noDivide = {0: 1, 1: 1, 2: 10, 3: 100, 4: 1000, 5: 10000};
  int _temptotalSemGPA = gpa * 100;

  int _tempLength = (_temptotalSemGPA / credit).toStringAsFixed(0).length;
  double total = (_temptotalSemGPA / credit) / noDivide[_tempLength];
  if (total.isNaN) total = 0.0;
  total = double.parse(total.toStringAsFixed(4));
  return total;
}

double calcAlgorithm2(int gpa, int credit) {
  Map<int, int> noDivide = {0: 1, 1: 1, 2: 10, 3: 100, 4: 1000, 5: 10000};
  int _temptotalSemGPA = gpa;

  int _tempLength = (_temptotalSemGPA / credit).toStringAsFixed(0).length;
  double total = (_temptotalSemGPA / credit) / noDivide[_tempLength];
  if (total.isNaN) total = 0.0;
  total = double.parse(total.toStringAsFixed(4));
  return total;
}
