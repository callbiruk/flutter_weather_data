import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../weather.dart';
import 'ValueTile.dart';

/// Renders a horizontal scrolling list of weather conditions
/// Used to show forecast
/// Shows DateTime, Weather Condition icon and Temperature
class DayForcast extends StatelessWidget {
  const DayForcast({
    Key key,
    @required this.weathers,
  }) : super(key: key);

  final List<Weather> weathers;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemCount: this.weathers.length,
        separatorBuilder: (context, index) => Divider(
          height: 100,
          color: Colors.white,
        ),
        padding: EdgeInsets.only(left: 10, right: 10),
        itemBuilder: (context, index) {
          final item = this.weathers[index];
          return Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Center(
              child: 
              ValueTile(
                DateFormat('ha')
                    .format(item.date),
                '${item.temperature.fahrenheit.round()}°', 
                // iconData: item.getIconData(),
                // iconData: item.weatherIcon,
              ),
            ),
          );
        },
      ),
    );
  }
}
