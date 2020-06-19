import 'package:flutter/material.dart';
import 'package:speech_recognition/speech_recognition.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:device_apps/device_apps.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: VoiceHome(),
    );
  }
}

class VoiceHome extends StatefulWidget {
  @override
  _VoiceHomeState createState() => _VoiceHomeState();
}

class _VoiceHomeState extends State<VoiceHome> {
  SpeechRecognition _speechRecognition;
  bool _isAvailable = false;
  bool _isListening = false;

  Map globalAppInfo = Map();
  String resultText = "welcome";
  PermissionStatus _status;

  @override
  void initState() {
    super.initState();
    allocatePermissions();
    setTotalAppInfo();
    initSpeechRecognizer();
  }

  void allocatePermissions() async {
    if (await Permission.microphone.request().isGranted) {
      print('permission grnated');
    }
  }

  void initSpeechRecognizer() {
    _speechRecognition = SpeechRecognition();

    _speechRecognition.setAvailabilityHandler(
      (bool result) => setState(() => _isAvailable = result),
    );

    _speechRecognition.setRecognitionStartedHandler(
      () => setState(() => _isListening = true),
    );

    _speechRecognition.setRecognitionResultHandler(
      (String speech) => setState(() async {
        resultText = speech;
      }),
    );

    _speechRecognition.setRecognitionCompleteHandler(() async {
        setState(() {
          _isListening = false;
        });
        resultText = resultText.replaceAll(' ', '');
        resultText = resultText.toLowerCase();
        String appPackageName =
        await getInstalledApplications(resultText);
        if (appPackageName != null) {
          print('i am running again and again');
          launchThisApp(appPackageName);
        } else {
          print('this happened');
          resultText = 'opps please refresh and speak again';
        }
      },
    );

    _speechRecognition.activate().then(
          (result) => setState(() => _isAvailable = result),
        );
  }

  Future<void> launchThisApp(String packageName) async {
    if (await DeviceApps.isAppInstalled(packageName)) {
      DeviceApps.openApp(packageName);
    }
  }

  Future<String> getInstalledApplications(String appName) async {
//    List<Application> apps = await DeviceApps.getInstalledApplications(
//        onlyAppsWithLaunchIntent: true, includeSystemApps: true);
//    Map appMap = updateAppListNames(apps);
//    print(globalAppInfo);
    var packageName = globalAppInfo[appName];
    if (packageName != null) {
      return packageName;
    }
    return null;
  }

  Map updateAppListNames(List<Application> apps) {
    var myMap = Map();
    for (int i = 0; i < apps.length; i++) {
      String nameOfApp = apps[i].appName;
      nameOfApp = nameOfApp.replaceAll(' ', '');
      nameOfApp = nameOfApp.toLowerCase();
      myMap[nameOfApp] = apps[i].packageName;
    }
    return myMap;
  }

  Future<void> setTotalAppInfo() async {
    List<Application> apps = await DeviceApps.getInstalledApplications(
        onlyAppsWithLaunchIntent: true, includeSystemApps: true);
    globalAppInfo = updateAppListNames(apps);
    globalAppInfo.forEach((key, value) {
      print('key : $key , value : $value');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  print(_isListening.toString() + 'is the value of is listening');
                  if (_isListening) {
                    _speechRecognition.cancel().then((value) {
                      setState(() {
                        _isListening = value;
                        resultText = "welcome";
                      });
                    });
                  }
                },
                child: Icon(
                  Icons.refresh,
                  color: Colors.red,
                  size: 30.0,
                )
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Text(
          resultText,
          style: TextStyle(fontSize: 30.0),
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_isAvailable && !_isListening) {
            _speechRecognition.listen(locale: 'en_US').then((value) async {

            });
          }
        },
        backgroundColor: Colors.red,
        child: Icon(Icons.mic),
      ),
    );
  }
}

//if (_isListening)
//_speechRecognition.cancel().then(
//(result) => setState(() {
//_isListening = result;
//resultText = "";
//}),
//);

//            if (_isAvailable && !_isListening) {
//              _speechRecognition.listen(locale: 'en_US').then((value) {
//                print(value);
//                resultText = value;
//              });
//            }
