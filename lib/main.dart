import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dhmigov/urldbhelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'notifications.dart';
import 'url.dart';

var url = 'https://www.dhmi.gov.tr';
List urls = [];
List isActiveList = [];
var lastStatusCode;
final dbHelper = DatabaseHelper.instance;
TextEditingController urlController = new TextEditingController();
var lasturl;
var lastCode;

// myclass() async {
//   final response = await http.get(Uri.parse(url));
//   print(response.statusCode);
//   if (response.statusCode == 200) {
//     await createNotifications('gg');
//   }
// }

myclass() async {
  if (urls.length == 0) {
    print('liste boş');
  }
  try {
    isActiveList = [];
    for (int j = 0; j < urls.length; j++) {
      lasturl = urls[j].url.toString();
      print(lasturl);
      final response = await http.get(Uri.parse(lasturl));
      print(response.statusCode);
      isActiveList.add(response.statusCode);
      print(isActiveList);
      if (response.statusCode == 200) {
        await createNotifications(lasturl);
      }
    }
  } catch (e) {
    print(e.toString());
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AwesomeNotifications().initialize('resource://drawable/small', [
    NotificationChannel(
      channelKey: 'basic_channel',
      channelName: 'Basic Notifications',
      defaultColor: Colors.teal,
      importance: NotificationImportance.High,
      channelShowBadge: true,
      channelDescription: 'notification',
    )
  ]);
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const MyApp());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
  service.startService();
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch
bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print('FLUTTER BACKGROUND FETCH');

  return true;
}

void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    final AllRows = await dbHelper.queryAllRows();
    urls.clear();
    AllRows.forEach((row) {
      urls.add(Url.fromMap(row));
      for (var i = 0; i < urls.length; i++) {
        print("${urls[i].url} ping göndermek için hazırlanıyor");
      }
    });

    final hello = preferences.getString("hello");
    print(hello);

    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "My App Service",
        content: await myclass() ?? "",
      );
    }

    /// you can see this log in logcat
    print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // test using external plugin
    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );
  });
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) => {
          if (!isAllowed)
            {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text('Allow Notifications'),
                        content: const Text(
                            'Our app would like to send you notifications'),
                        actions: [
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Dont\'t Allow',
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 18),
                              )),
                          TextButton(
                              onPressed: () => AwesomeNotifications()
                                  .requestPermissionToSendNotifications()
                                  .then((_) => Navigator.pop(context)),
                              child: const Text(
                                'Allow',
                                style: TextStyle(
                                    color: Colors.teal,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ))
                        ],
                      ))
            }
        });
    // TODO: implement initState
    print('periodic task başlıyor');
    print('fff');
    _queryAll();
  }

  String text = "Stop Service";

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('DHMİ'),
            bottom: const TabBar(
              tabs: [
                Tab(
                  text: 'Insert',
                ),
                Tab(
                  text: 'View',
                )
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Center(
                  child: Column(
                children: [
                  Container(
                      padding: EdgeInsets.all(20),
                      child: TextField(
                        controller: urlController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), labelText: 'Urls'),
                      )),
                  RaisedButton(
                    onPressed: () {
                      String controllerurl = urlController.text;
                      _insert(controllerurl);
                    },
                    child: Text('Insert Url'),
                  ),
                ],
              )),
              Container(
                  child: ListView.builder(
                      itemCount: urls.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == urls.length) {
                          return RaisedButton(
                              child: Text('Refresh'),
                              onPressed: () => setState(() {
                                    _queryAll();
                                    print('güncellendi');
                                  }));
                        } else {
                          return Container(
                            height: 40,
                            child: ListTile(
                              title: Center(
                                child: Text(
                                  '[${urls[index].id}] ${urls[index].url}',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              leading: Icon(Icons.ac_unit),
                              trailing: GestureDetector(child: Icon( Icons.close),onTap:()=>print('deleted'))
                              ),);
                        }
                      })),
            ],
          ),
        ),
      ),
    );
  }

  void _insert(String controllerurl) async {
    Map<String, dynamic> row = {
      DatabaseHelper.columnUrl: controllerurl,
    };
    Url url = Url.fromMap(row);
    final id = await dbHelper.insert(url);
  }

  void _queryAll() async {
    final AllRows = await dbHelper.queryAllRows();
    urls.clear();
    AllRows.forEach((row) {
      urls.add(Url.fromMap(row));
      for (var i = 0; i < urls.length; i++) {
        print("${urls[i].url} ping göndermek için hazırlanıyor");
      }
    });
    setState(() {});
  }
  void delete(int id) async{
    final rowdeleted = await dbHelper.delete(id);
    print("$id silindi");
    setState((){
      _queryAll();
    });
  }
}

// Container(
// height: 40,
// child: Center(
// child: Text(
// '[${urls[index].id}] ${urls[index].url}',
// style: TextStyle(fontSize: 18),
// ),
// ),
// )

//scaffold column main.dart
// Column(
// children: [
// SizedBox(height: 30),
// ElevatedButton(
// child: Text(text),
// onPressed: () async {
// final service = FlutterBackgroundService();
// var isRunning = await service.isRunning();
// if (isRunning) {
// service.invoke("stopService");
// } else {
// service.startService();
// }
//
// if (!isRunning) {
// text = 'Stop Service';
// } else {
// text = 'Start Service';
// }
// setState(() {});
// },
// ),
// ],
// ),
