import 'package:flutter/material.dart';
import 'package:plant_collector/formats/text.dart';
import 'package:plant_collector/formats/colors.dart';

class ScreenTemplate extends StatelessWidget {
  final String screenTitle;
  final Widget child;
  final Widget bottomBar;
  final bool implyLeading;
  final backgroundColor;
  ScreenTemplate({
    @required this.screenTitle,
    @required this.child,
    this.bottomBar,
    this.implyLeading,
    this.backgroundColor = kGreenLight,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: (implyLeading == null) ? true : false,
        backgroundColor: kGreenDark,
        centerTitle: true,
        elevation: 20.0,
        title: Text(
          screenTitle,
          style: kAppBarTitle,
        ),
      ),
      body: child != null ? child : SizedBox(),
      bottomNavigationBar: bottomBar ?? SizedBox(),
    );
  }
}
