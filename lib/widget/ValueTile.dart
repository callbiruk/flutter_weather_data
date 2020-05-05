import 'package:ayer/consts/colors.dart';
import 'package:flutter/material.dart';

/// General utility widget used to render a cell divided into three rows
/// First row displays [label]
/// second row displays [iconData]
/// third row displays [value]
class ValueTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData   iconData;

  ValueTile(this.label, this.value, {this.iconData});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          this.label,
          style: TextStyle(
              color: BColors.bLightGreen.withAlpha(90)),
        ),
        SizedBox(
          height: 5,
        ),
        this.iconData != null
            ? 
            Icon(
                iconData,
                color: Theme.of(context).accentColor,
                size: 20,
              )
            : Container(width:0, height:0),
        SizedBox(
          height: 10,
        ),
        Text(
          this.value,
          style:
              TextStyle(color: BColors.bGreen),
        ),
      ],
    );
  }
}