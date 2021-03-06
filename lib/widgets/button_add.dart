import 'package:flutter/material.dart';
import 'package:plant_collector/formats/colors.dart';
import 'package:plant_collector/formats/text.dart';

class ButtonAdd extends StatelessWidget {
  final String buttonText;
  final Function onPress;
  final IconData icon;
  final Color textColor;
  final double scale;
  ButtonAdd(
      {@required this.buttonText,
      @required this.onPress,
      this.icon,
      this.textColor,
      this.scale = 1});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.all(
          5.0 * MediaQuery.of(context).size.width * kScaleFactor,
        ),
        padding: EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
            boxShadow: kShadowBox,
            borderRadius: BorderRadius.all(
              Radius.circular(
                5.0,
              ),
            ),
            gradient: kGradientGreenVerticalDarkMed),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon != null ? icon : Icons.add,
              size:
                  scale * AppTextSize.huge * MediaQuery.of(context).size.width,
              color: textColor != null ? textColor : AppTextColor.white,
            ),
            Text(
              '   $buttonText',
              style: TextStyle(
                color: textColor != null ? textColor : AppTextColor.white,
                fontSize: scale *
                    AppTextSize.huge *
                    MediaQuery.of(context).size.width,
                fontWeight: AppTextWeight.medium,
//                shadows: kShadowText,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        onPress();
      },
    );
  }
}
