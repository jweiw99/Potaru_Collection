import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volume_watcher/volume_watcher.dart';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_core/core.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:potaru/UI/utils/config.dart';

import 'package:potaru/UI/utils/notificationManager.dart';
import 'package:potaru/UI/navigator_screen.dart';
import 'package:potaru/UI/splash_screen.dart';
import 'package:potaru/UI/Modules/Timetable/utils/config.dart';
import 'package:potaru/UI/intro_screen.dart';
import 'package:potaru/UI/Modules/Timetable/utils/timetableToImage.dart';

import 'package:potaru/Model/timetable.model.dart';
import 'package:potaru/Model/faculty.model.dart';
import 'package:potaru/Model/staff.model.dart';
import 'package:potaru/Model/version.model.dart';
import 'package:potaru/Model/todo.model.dart';
import 'package:potaru/Model/task.model.dart';

import 'package:potaru/Controller/timetable.controller.dart';
import 'package:potaru/Controller/faculty.controller.dart';
import 'package:potaru/Controller/staff.controller.dart';
import 'package:potaru/Controller/version.controller.dart';
import 'package:potaru/Controller/todo.controller.dart';
import 'package:potaru/Controller/task.controller.dart';

VersionController versionController = VersionController();
FacultyController facultyController = FacultyController();
StaffController staffController = StaffController();
TimetableController timetableController = TimetableController();
TodoController todoController = TodoController();
TaskController taskController = TaskController();

Future<http.Response> getVersion() async {
  return await http.get(
      'https://potaru-api.herokuapp.com/api/version/staff_directory',
      headers: {"Accept": "application/json"});
}

Future<http.Response> getFacultyData() async {
  return await http.get('https://potaru-api.herokuapp.com/api/faculty',
      headers: {"Accept": "application/json"});
}

Future<http.Response> getStaffData() async {
  return await http.get('https://potaru-api.herokuapp.com/api/staff',
      headers: {"Accept": "application/json"});
}

Future<bool> syncDB() async {
  var response = await getVersion();

  if (response.statusCode == 200) {
    // Version
    List versionData = json.decode(response.body)['data'];
    final res = await versionController.getVersion('staff_directory');
    if (res.isEmpty) {
      final items = versionData.map((i) => Version.fromMapObject(i));
      for (final item in items) {
        await versionController.insertVersion(item);
      }
    } else if (versionData[0]['lastUpdateDate'] > res[0]['lastUpdateDate']) {
      final items = versionData.map((i) => Version.fromMapObject(i));
      for (final item in items) {
        await versionController.updateVersion(item);
      }
    } else {
      return true;
    }

    // Faculty
    response = await getFacultyData();
    if (response.statusCode == 200) {
      List facultyData = json.decode(response.body)['data'];
      final items = facultyData.map((i) => Faculty.fromMapObject(i));
      facultyController.removeFaculty();
      for (final item in items) {
        await facultyController.insertFaculty(item);
      }

      // Staff
      response = await getStaffData();
      if (response.statusCode == 200) {
        List staffData = json.decode(response.body)['data'];
        final items = staffData.map((i) => Staff.fromMapObject(i));
        staffController.removeStaff();
        for (final item in items) {
          await staffController.insertStaff(item);
        }
        return true;
      }
    }
  }
  return false;
}

runbackgroundTask() {
  switchSilentMode().then((val) {
    // silent mode done
    return;
  });
  taskNotify().then((val) {
    // task notify done
    return;
  });
  screenImageUpdate().then((val) {
    // Screen image update done
    return;
  });
}

Future<bool> switchSilentMode() async {
  final prefs = await SharedPreferences.getInstance();
  List<double> _initVolume = [0.0, 0.0, 0.0, 0.0, 0.0];
  List<AudioManager> _audioManager = [
    AudioManager.STREAM_SYSTEM,
    AudioManager.STREAM_RING,
    AudioManager.STREAM_MUSIC,
    AudioManager.STREAM_ALARM,
    AudioManager.STREAM_NOTIFICATION
  ];
  List<String> _spAudioName = [
    "initVolume_SYS",
    "initVolume_RING",
    "initVolume_MUSIC",
    "initVolume_ALARM",
    "initVolume_NOTIFY"
  ];

  if (Platform.isAndroid)
    for (int v = 0; v < _initVolume.length; v++) {
      _initVolume[v] = await VolumeWatcher.getCurrentVolume(_audioManager[v]);
    }
  else if (Platform.isIOS)
    _initVolume[0] = await VolumeWatcher.getIosCurrentVolume;

  if (prefs.getBool('silentMode') == null) {
    for (int v = 0; v < _initVolume.length; v++) {
      prefs.setDouble(_spAudioName[v], _initVolume[v]);
    }
    await prefs.setStringList('pushNotification', []);
    await prefs.setBool('silentMode', false);
    await prefs.setBool('setting_timeReminder', true);
    await prefs.setBool('setting_silentMode', true);
    await prefs.setInt('setting_timeNotifyBefore', 5);
  } else if (prefs.getBool('silentMode')) {
    for (int v = 0; v < _initVolume.length; v++) {
      _initVolume[v] = prefs.getDouble(_spAudioName[v]) ?? 0;
    }
  } else {
    for (int v = 0; v < _initVolume.length; v++) {
      prefs.setDouble(_spAudioName[v], _initVolume[v]);
    }
  }

  DateTime _now = DateTime.now();
  String _datetoday = DateFormat("yyyy-MM-dd").format(_now);
  List<String> _type = ["L", "P", "T", "E"];
  List<String> pushedNotify = prefs.getStringList('pushNotification');

  List<Timetable> result =
      await timetableController.getTimetableList(_datetoday);

  for (int i = 0; i < result.length; i++) {
    _now = DateFormat("HH:mm").parse(DateFormat("HH:mm").format(_now));
    DateTime _startTime = DateFormat("HH:mm").parse(result[i].courseStartTime);
    DateTime _endTime = DateFormat("HH:mm").parse(result[i].courseEndTime);

    if (prefs.getBool('setting_timeReminder')) {
      if (result[i].remind == 1 &&
          _now.isAfter(_startTime.subtract(
              Duration(minutes: prefs.getInt('setting_timeNotifyBefore')))) &&
          _now.isBefore(_startTime) &&
          !pushedNotify.contains(result[i].courseName +
              result[i].courseType +
              result[i].courseDate +
              result[i].courseStartTime)) {
        pushedNotify.add(result[i].courseName +
            result[i].courseType +
            result[i].courseDate +
            result[i].courseStartTime);
        prefs.setStringList('pushNotification', pushedNotify);

        NotificationManager n = NotificationManager();
        await n.initNotificationManager();
        await n.showNotificationWithDefaultSound(
            i,
            TimetableConfig.courseType[result[i].courseType] +
                " - " +
                result[i].courseName,
            "Venue : " +
                result[i].courseVenue +
                " (" +
                DateFormat("h:mm a").format(
                    DateFormat("HH:mm").parse(result[i].courseStartTime)) +
                ")");
      }
    }

    if (!prefs.getBool('silentMode') &&
        _now.isAfter(_startTime) &&
        _now.isBefore(_endTime) &&
        _type.contains(result[i].courseType)) {
      if (prefs.getBool('setting_silentMode')) {
        if (Platform.isAndroid) {
          for (int v = 0; v < _initVolume.length; v++) {
            await VolumeWatcher.setVolume(_audioManager[v], 0.0);
          }
        } else if (Platform.isIOS) {
          await VolumeWatcher.setIosVolume(0.0);
        }
      }
      prefs.setBool('silentMode', true);
    } else if (prefs.getBool('silentMode') &&
        i == 0 &&
        !(_now.isAfter(_startTime) && _now.isBefore(_endTime))) {
      if (prefs.getBool('setting_silentMode')) {
        if (Platform.isAndroid) {
          for (int v = 0; v < _initVolume.length; v++) {
            if (await VolumeWatcher.getCurrentVolume(_audioManager[v]) == 0.0 ||
                v == 3)
              await VolumeWatcher.setVolume(_audioManager[v], _initVolume[v]);
          }
        } else if (Platform.isIOS) {
          await VolumeWatcher.setIosVolume(_initVolume[0]);
        }
      }

      await prefs.setStringList('pushNotification', []);
      await prefs.setBool('silentMode', false);
    }
  }

  return true;
}

Future<bool> taskNotify() async {
  List<Todo> todoList = await todoController.getTodayTodoList();

  if (todoList.length > 0) {
    String _nowTime = DateFormat("HH:mm").format(DateTime.now());
    String _nowDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
    final prefs = await SharedPreferences.getInstance();
    NotificationManager n = NotificationManager();
    await n.initNotificationManager();

    if (prefs.getBool('setting_taskReminder') == null) {
      await prefs.setBool('setting_taskReminder', true);
    }

    int id = 1;
    if (prefs.getInt('taskID') == null || _nowTime == "05:00") {
      prefs.setInt('taskID', id);
    } else {
      id = prefs.getInt('taskID');
    }

    await Future.forEach(todoList, (Todo todo) async {
      String remindTime = DateFormat("HH:mm")
          .format(DateFormat("HH:mm").parse(todo.remindTime));
      if (_nowTime == remindTime) {
        List<Task> taskList =
            await taskController.getRecurringTaskList(todo.tid, _nowDate);

        if (todo.recurring == 1 && taskList.length == 0) {
          String _tempDate = await taskController.getLastTaskDateList(todo.tid);
          if (_tempDate.isNotEmpty) {
            taskList =
                await taskController.getRecurringTaskList(todo.tid, _tempDate);
            for (int i = 0; i < taskList.length; i++) {
              taskList[i].date = _nowDate;
              taskList[i].completed = 0;
              await taskController.insertTask(taskList[i]);
            }
          }
        }

        if (prefs.getBool('setting_taskReminder')) {
          int taskleft =
              taskList.where((task) => task.completed == 0).toList().length;
          if (taskList.length > 0 && taskleft > 0) {
            await n.showNotificationWithDefaultSound(
                id++, todo.title, taskList.length.toString() + " Tasks Left");
            prefs.setInt('taskID', id);
          } else if (taskList.length == 0) {
            await n.showNotificationWithDefaultSound(id++, todo.title,
                todo.desc.isEmpty ? "No Description" : todo.desc);
            prefs.setInt('taskID', id);
          }
        }
      }
    });
  }
  return true;
}

Future<bool> screenImageUpdate() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('setting_lockScreenImage') == null) {
    await prefs.setBool('setting_lockScreenImage', true);
  }
  if (prefs.getBool('setting_lockScreenImage')) {
    DateTime now = DateTime.now();
    String weekDay = DateFormat("EEE").format(now);
    String time = DateFormat("HH:mm").format(now);
    if (weekDay == "Mon" && time == "00:00") {
      await TimetableImage.startConvertImage(now);
    }
  }
  return true;
}

void callbackDispatcher() {
  Workmanager.executeTask(((backgroundTask, inputData) async {
    switch (backgroundTask) {
      case Workmanager.iOSBackgroundTask:
      case "updateTask":
        await syncDB();
        break;
    }
    return true;
  }));
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await Workmanager.initialize(callbackDispatcher);
    await Workmanager.registerOneOffTask("1", "updateTask",
        existingWorkPolicy: ExistingWorkPolicy.replace,
        constraints: Constraints(networkType: NetworkType.connected),
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: Duration(minutes: 3));
    await AndroidAlarmManager.initialize();
    await AndroidAlarmManager.periodic(
        const Duration(minutes: 1), 99999, runbackgroundTask,
        exact: true, wakeup: true, rescheduleOnReboot: true);
  }
  SyncfusionLicense.registerLicense(
      '');
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool('appFirstRun') == null) prefs.setBool('appFirstRun', true);
  runApp(MyApp(
    prefs: prefs,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key key, this.prefs}) : super(key: key);

  final prefs;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        //top bar color
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness:
            Platform.isAndroid ? Brightness.dark : Brightness.light,
        //bottom bar color
        systemNavigationBarColor: Colors.blueGrey[700],
        //systemNavigationBarDividerColor: Colors.grey,
        //systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (ctx, child) {
        ScreenUtil.init(ctx);
        ErrorWidget.builder = _buildError(ctx);
        return MediaQuery(
          data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: false),
          child: child,
        );
      },
      title: 'Potaru',
      theme: ThemeData(
          fontFamily: 'Roboto',
          primaryColor: Colors.blue,
          buttonColor: Colors.blue,
          disabledColor: Colors.blueGrey,
          primarySwatch: Colors.blue,
          textSelectionColor: Colors.blue,
          backgroundColor: Colors.blue,
          canvasColor: Color.fromRGBO(249, 252, 255, 1),
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          })),
      initialRoute:
          prefs.getBool('appFirstRun') ? '/introScreen' : '/splashScreen',
      routes: {
        '/homeUI': (context) => NavigatorScreen(),
        '/introScreen': (context) => IntroScreen(),
        '/splashScreen': (context) => AnimatedSplashScreen()
      },
    );
  }
}

Widget Function(FlutterErrorDetails) _buildError(BuildContext ctx) {
  return (FlutterErrorDetails err) => Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          AutoSizeText(
            'Something went wrong',
            style: TextStyle(fontSize: ScreenUtil().setSp(25)),
            maxLines: 1,
          ),
          Container(
            width: 200,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: TextField(
              controller: TextEditingController(text: err.toString()),
              keyboardType: TextInputType.multiline,
              maxLines: 6,
              enableInteractiveSelection: false,
              focusNode: AlwaysDisabledFocusNode(),
            ),
          ),
          AutoSizeText(
            'Send error description\nto developers',
            style: TextStyle(fontSize: ScreenUtil().setSp(15)),
            maxLines: 2,
          ),
          IconButton(
            icon: Icon(
              Icons.send,
            ),
            onPressed: () => FlutterEmailSender.send(Email(
              body: err.toString(),
              subject: "Potaru Error",
              recipients: ["jweiw99@1utar.edu.my"],
            )),
          ),
        ],
      ));
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}
