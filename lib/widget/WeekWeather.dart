import 'dart:convert';

import 'package:ayer/consts/colors.dart';
import 'package:ayer/weather.dart';
import 'package:ayer/widget/DayForcast.dart';
import 'package:flutter/material.dart';
import 'package:expansion_card/expansion_card.dart';
import 'dart:math';
import 'package:intl/intl.dart';


class WeekWeather extends StatelessWidget {
  final Map<dynamic, List<Weather>> weatherMap;
  WeekWeather(this.weatherMap);

  final List<String> WEEKDAYS = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0.0),
      margin: EdgeInsets.only(top: 0),
      child: ListView.builder(
          // shrinkWrap: true,
          // physics: NeverScrollableScrollPhysics(),
          // shrinkWrap: true,

          itemCount: this.weatherMap.length,
          itemBuilder: (context, index) {
            // final item = this.weatherMap[index];
            int key = this.weatherMap.keys.elementAt(index);
            var tempMax = ((this
                        .weatherMap[key]
                        .map((m) => m.tempMax.fahrenheit.round())
                        .reduce((a, b) => (a > b)? a:b)))
                .round()
                .toString();
            var myDate = DateFormat('MMM dd').format(this.weatherMap[key][0].date);
            var tempMin = ((this
                        .weatherMap[key]
                        .map((m) => m.tempMax.fahrenheit.round())
                        .reduce((a, b) => (a < b)? a:b)))
                .round()
                .toString();
            return ExpansionCard(
              margin: EdgeInsets.all(0.0),
              borderRadius: 5,
              backgroundColor: BColors.bDarkBlue,
              // background: Image.asset(
              //   "images/planets.gif",
              //   fit: BoxFit.cover,
              // ),
              title: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      WEEKDAYS[key - 1],
                      style: TextStyle(
                        fontSize: 30,
                        color: BColors.bGreen,
                      ),
                    ),
                    Text(
                      myDate, //this.weatherMap[key].where().weatherMain,
                      style:
                          TextStyle(fontSize: 14, color: BColors.bLightGreen),
                    ),
                  ],
                ),
              ),
              trailing: Container(
                width: 100,
                child: Row(
                  children: <Widget>[
                    Text(
                      '$tempMax°',
                      style:
                          TextStyle(fontSize: 20, color: BColors.bDarkYellow),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Center(
                          child: Container(
                        width: 1,
                        height: 30,
                        color: Theme.of(context).accentColor.withAlpha(70),
                      )),
                    ),
                    Text(
                      '$tempMin°',
                      style:
                          TextStyle(fontSize: 15, color: BColors.bDarkYellow.withAlpha(99)),
                    ),
                  ],
                ),
              ),
              children: <Widget>[
                Container(
                  child: Divider(
                    color: BColors.bLightYellow.withAlpha(30),
                    height: 0.50,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: //Text("Content goes over here !", style: TextStyle(fontSize: 20, color: Colors.black)),
                        DayForcast(
                      weathers: this.weatherMap[key],
                    )),
                Container(
                  child: Divider(
                    color: BColors.bLightYellow.withAlpha(30),
                    height: 0.50,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              ],
            );
          }),
    );
  }
}
