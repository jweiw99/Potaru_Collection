import 'package:potaru/Model/task.model.dart';

double percentCalc(List<Task> task) {
  if (task.length == 0) {
    return 1.0;
  }
  int completed = 0;
  task.forEach((t) {
    if (t.completed == 1) {
      completed++;
    }
  });
  return completed / task.length;
}

String taskLeft(List<Task> task) {
  if (task.length == 0) {
    return "0";
  }
  int completed = 0;
  task.forEach((t) {
    if (t.completed == 1) {
      completed++;
    }
  });
  return (task.length - completed).toString();
}
