import 'package:ayer/consts/colors.dart';
import 'package:flutter/material.dart';

class SubHeading extends StatelessWidget {
  final String title;

  SubHeading(this.title);

  @override
  Widget build(BuildContext context) {
    
    return Text(
      this.title,
      style: TextStyle(
          color: BColors.bDarkBlue,
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2),
    );
  }
}