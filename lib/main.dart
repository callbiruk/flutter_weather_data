import 'package:ayer/consts/models.dart';
import 'package:ayer/weather.dart';
import 'package:ayer/widget/SubHeading.dart';
import 'package:ayer/widget/TopContainer.dart';
import 'package:ayer/widget/ValueTile.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'consts/colors.dart';
import 'widget/WeekWeather.dart';
import 'package:expansion_card/expansion_card.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share/share.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alaska Ayer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: Theme.of(context).textTheme.apply(
            bodyColor: BColors.bDarkBlue,
            displayColor: BColors.bDarkBlue,
            fontFamily: 'Poppins'),
      ),
      home: MyHomePage(title: 'Alaska Ayer'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String zipCode = "";
  final String url = "https://api.openweathermap.org/data/2.5/";
  String result = '-';
  final String key = '36a234b17b68e6e08b52cde6c494a80d';
  WeatherStation ws;
  String _weather = "";
  WeatherData weather;
  List<Weather> weatherList = [];
  Map<dynamic, List<Weather>> weatherDateMap = new Map();
  bool _btnEnabled = false;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  TextEditingController _zipController; // = TextEditingController();

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool _ErrorFetchingData = false;

  // groupBy(data, (obj) => obj['date']).map( (k, v) => MapEntry(k, v.map((item) { item.remove('date'); return item;}).toList()));
  @override
  void initState() {
    super.initState();
    this.zipCode = _prefs.then((SharedPreferences prefs) {
      var zipValue = (prefs.getInt('zipCode'));
      // if (zipValue != null) {
      //   setupWeatherFetch();
      //   return null;
      // }
      _zipController = TextEditingController(
          text: zipValue != null ? zipValue.toString() : "");
      return zipValue;
    }).toString();
    //_showParamDialog(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showParamDialog(context);
    });
    this.weather = new WeatherData();

    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) async {
    debugPrint("payload : $payload");
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text('Notification'),
        content: new Text('${this.weather.areaName} : ${this.weather.temprature}°F'),
      ),
    );
  }

  Future _updateZipCode() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      this.zipCode =
          prefs.setInt("zipCode", int.parse(this.zipCode)).then((bool success) {
        return zipCode;
      }).toString();
    });
  }

  void setupWeatherFetch() {
    queryWeather();
    // _updateZipCode();
    getForcast(this.zipCode);
  }

  showNotification() async {
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.High,importance: Importance.Max
    );
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(
        0, 'Weather Alert', '${this.weather.areaName} : ${this.weather.temprature}°F', platform,
        payload: '${this.weather.areaName} : ${this.weather.temprature}°F');
  }

  Future<String> _showParamDialog(BuildContext context, {String msg}) async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Enter Your Location",
                      style: TextStyle(fontSize: 20),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        height: 0.5,
                        // width: 200.0,
                        color: Colors.grey.withAlpha(50),
                      ),
                    ),
                    SizedBox(
                      width: 200.0,
                      child: TextField(
                        controller: _zipController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: 'ZIP Code'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        height: 0.5,
                        // width: 200.0,
                        color: Colors.grey.withAlpha(50),
                      ),
                    ),
                    SizedBox(
                      width: 100.0,
                      child: RaisedButton(
                        onPressed: () {
                          //Navigator.pop(context, _zipController.text);
                          setState(() {
                            this.zipCode = _zipController.text;
                            _updateZipCode();
                            setupWeatherFetch();
                          });
                          Navigator.pop(context, _zipController.text);
                        },
                        child: Text(
                          "Fetch",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: BColors.bDarkBlue,
                      ),
                    ),
                    this._ErrorFetchingData
                        ? Text(
                            msg,
                            style: TextStyle(
                                color: Colors.red, fontStyle: FontStyle.italic),
                          )
                        : Text("")
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              // FlatButton(
              //   child: Text("Fetch"),
              //   onPressed: () {
              //     Navigator.pop(context, _zipController.text);
              //   },
              // )
            ],
          );
        });
  }

  Future getForcast(String zipCode) async {
    ws = new WeatherStation(key, zipCode);
    // List<Weather> f = await ws.fiveDayForecast();
    this.weatherList = await ws.fiveDayForecast();
    setState(() {
      this.result = this.weatherList.toString();
      var weatherMap = groupBy(this.weatherList, (obj) => obj.weekday);
      this.weatherDateMap = weatherMap;
    });
  }

  void queryWeather() async {
    ws = new WeatherStation(key, zipCode);
    Weather w = await ws.currentWeather();
    setState(() {
      if (w != null) {
        this._ErrorFetchingData = false;
        this.weather = new WeatherData.fromWeather(w);
      } else {
        this._ErrorFetchingData = true;
        _showParamDialog(context,
            msg:
                "Unable to fetch weather data, Check Your Internet Connection or Zip Code");
      }

      _weather = w.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text(widget.title),
    //   ),
    //   body: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.start,
    //       children: <Widget>[
    //         Text(this.zipCode)
    //       ],
    //     ),
    //   ),
    // );
    return Scaffold(
      backgroundColor: BColors.bLightYellow,
      resizeToAvoidBottomPadding: false,
      body: Padding(
        child: Column(
          children: <Widget>[
            Container(
              child: TopContainer(
                height: 400,
                width: width,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.edit_location,
                                color: BColors.bBlue, size: 25.0),
                            onPressed: () {
                              _showParamDialog(context);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.share,
                                color: BColors.bBlue, size: 25.0),
                            onPressed: () {
                              final RenderBox box = context.findRenderObject();
                              Share.share(
                                  '${this.weather.areaName} : ${this.weather.temprature}°F',
                                  subject: "weather Data",
                                  sharePositionOrigin:
                                      box.localToGlobal(Offset.zero) &
                                          box.size);
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 0.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    '${this.weather.temprature}°',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 80.0,
                                      color: BColors.bLavender,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Container(
                                  child: Text(
                                    '${this.weather.areaName}',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 22.0,
                                      color: BColors.bGreen,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 5,
                                ),
                                Container(
                                  child: Text(
                                    '${this.weather.weatherMain}',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: BColors.bLightGreen,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                                Padding(
                                  child: Divider(
                                    color: Colors.black.withAlpha(50),
                                  ),
                                  padding: EdgeInsets.all(10),
                                ),
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      ValueTile("wind speed",
                                          '${this.weather.windSpeed} m/s'),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 15),
                                        child: Center(
                                            child: Container(
                                          width: 1,
                                          height: 30,
                                          color: Theme.of(context)
                                              .accentColor
                                              .withAlpha(50),
                                        )),
                                      ),
                                      ValueTile(
                                          "sunrise", '${this.weather.sunrise}'),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 15),
                                        child: Center(
                                            child: Container(
                                          width: 1,
                                          height: 30,
                                          color: Theme.of(context)
                                              .accentColor
                                              .withAlpha(50),
                                        )),
                                      ),
                                      ValueTile(
                                          "sunset", '${this.weather.sunset}'),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 15, right: 15),
                                        child: Center(
                                            child: Container(
                                          width: 1,
                                          height: 30,
                                          color: Theme.of(context)
                                              .accentColor
                                              .withAlpha(50),
                                        )),
                                      ),
                                      ValueTile("humidity",
                                          '${this.weather.humidity} %'),
                                    ]),
                              ],
                            )
                          ],
                        ),
                      )
                    ]),
              ),
            ),
            Expanded(
              flex: 4,
              child: Container(
                  color: BColors.bDarkBlue, child: WeekWeather(weatherDateMap)),
            ),
            Container(
              child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    color: BColors.bDarkBlue,
                    height: 40,
                    child: Column(
                      children: <Widget>[
                        Text(
                          "* Tempratures are in °F",
                          style: TextStyle(
                              color: BColors.bLightYellow2,
                              fontStyle: FontStyle.italic),
                        ),
                        Divider()
                      ],
                    ),
                  )),
            )
          ],
        ),
        padding: EdgeInsets.all(0),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showNotification();
        },
        child: Icon(Icons.notification_important),
        backgroundColor: BColors.bDarkYellow,
      ),
    );
  }
}
