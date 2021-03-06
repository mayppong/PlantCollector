import 'package:flutter/material.dart';
import 'package:plant_collector/formats/colors.dart';

class ContainerCard extends StatelessWidget {
  final Widget child;
  final Color color;
  ContainerCard({
    @required this.child,
    this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 5.0,
        right: 5.0,
        top: 5.0,
        bottom: 5.0,
      ),
      margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: kShadowBox,
        color: color == null ? kGreenDark : color,
      ),
      child: child,
    );
  }
}
