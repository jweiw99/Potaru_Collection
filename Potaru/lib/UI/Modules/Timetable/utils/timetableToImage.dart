import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:wallpaper_manager/wallpaper_manager.dart';

import 'package:potaru/Controller/timetable.controller.dart';
import 'package:potaru/Model/timetable.model.dart';
import 'package:potaru/UI/utils/toastMsg.dart';

class TimetableImage {
  TimetableImage._();

  static Function startConvertImage = (DateTime dateSelected) async {
    DateTime today = DateFormat("yyyy-MM-dd")
        .parse(DateFormat("yyyy-MM-dd").format(DateTime.now()));
    DateTime weekStart = today.subtract(new Duration(days: today.weekday - 1));
    DateTime weekEnd = weekStart.add(new Duration(days: 7));
    
    if (dateSelected.isBefore(weekStart) || weekEnd.isBefore(dateSelected)) {
      return;
    }

    DateTime startTime = DateFormat("HH:mm").parse("07:00");
    Map<String, int> row = {};
    Map<String, List<Map<String, String>>> content = {};
    List<Timetable> timetable =
        await TimetableController().getCurWeekTimetable();

    for (Timetable val in timetable) {
      String courseDate = DateFormat("EEE")
          .format(DateFormat("yyyy-MM-dd").parse(val.courseDate));
      DateTime courseStartTime = DateFormat("HH:mm").parse(val.courseStartTime);
      Duration diffhours = courseStartTime.difference(startTime);
      int courseHours = ((diffhours.inMinutes ~/ 60) * 2) +
          ((diffhours.inMinutes % 60) >= 30 ? 1 : 0);

      String _tempData = json.encode({
        'courseName': val.courseName.substring(0, 16),
        'courseType': val.courseType,
        'courseGroup': val.courseGroup,
        'courseVenue': val.courseVenue,
        'courseHrs': val.courseHrs
      });

      if (!content.containsKey('"$courseDate"')) {
        content['"$courseDate"'] = [];
        row['"$courseDate"'] = 1;
        content['"$courseDate"'].add({'"$courseHours"': _tempData});
      } else {
        int count = content['"$courseDate"'].length > 0
            ? content['"$courseDate"'].length - 1
            : 0;

        for (int i = 0; i <= count; i++) {
          if (content['"$courseDate"'][i].containsKey('"$courseHours"') &&
              i == (content['"$courseDate"'].length - 1)) {
            content['"$courseDate"'].add({'"$courseHours"': _tempData});
            row['"$courseDate"']++;
          } else if (!content['"$courseDate"'][i]
              .containsKey('"$courseHours"')) {
            content['"$courseDate"'][i]['"$courseHours"'] = _tempData;
          }
        }
      }
    }
    if (timetable.length > 0) await requestImage(row, content);
  };

  static Function requestImage = (row, content) async {
    try {
      var response = await http.post(
          'https://potaru-api.herokuapp.com/api/timetableImage/',
          headers: {"Accept": "application/json"},
          body: {'row': row.toString(), 'content': content.toString()});
      if (response.contentLength == 0) {
        return;
      } else if ([200, 201].contains(response.statusCode)) {
        Directory tempDir = await getApplicationDocumentsDirectory();
        String tempPath = tempDir.path;
        File file = File('$tempPath/timetable.png');
        await file.writeAsBytes(response.bodyBytes);
        await WallpaperManager.setWallpaperFromFile(
            file.path, WallpaperManager.LOCK_SCREEN);
      } else {
        ToastMsg.toToast("Server Error");
      }
    } catch (error) {
      ToastMsg.toToast("Service Unavailable");
      //print(error);
    }
  };
}
