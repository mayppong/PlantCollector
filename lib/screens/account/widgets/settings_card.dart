import 'package:flutter/material.dart';
import 'package:plant_collector/formats/colors.dart';
import 'package:plant_collector/formats/text.dart';
import 'package:plant_collector/models/app_data.dart';
import 'package:plant_collector/screens/dialog/dialog_screen_input.dart';
import 'package:plant_collector/widgets/container_card.dart';
import 'package:provider/provider.dart';

class SettingsCard extends StatelessWidget {
  final Function onSubmit;
  final Function onPress;
  final String cardLabel;
  final String cardText;
  final bool allowDialog;
  final String dialogText;
  SettingsCard(
      {@required this.onSubmit,
      @required this.onPress,
      @required this.cardLabel,
      @required this.cardText,
      this.allowDialog,
      this.dialogText});
  @override
  Widget build(BuildContext context) {
    return ContainerCard(
      child: FlatButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            CircleAvatar(
              backgroundColor: kGreenMedium,
              foregroundColor: kGreenDark,
              radius: AppTextSize.tiny * MediaQuery.of(context).size.width,
              child: Icon(
                Icons.edit,
                size: AppTextSize.tiny * MediaQuery.of(context).size.width,
              ),
            ),
            SizedBox(
              width: 5.0 * MediaQuery.of(context).size.width * kScaleFactor,
            ),
            Text(
              '$cardLabel:  ',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: AppTextSize.small * MediaQuery.of(context).size.width,
                color: kGreenMedium,
              ),
            ),
            Text(
              '$cardText',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppTextSize.small * MediaQuery.of(context).size.width,
                color: Colors.white,
                shadows: kShadowText,
              ),
            ),
          ],
        ),
        onPressed: () {
          if (allowDialog == false) {
            onPress();
          } else {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return DialogScreenInput(
                    title: cardLabel,
                    acceptText: 'Update',
                    acceptOnPress: onSubmit,
                    onChange: (input) {
                      Provider.of<AppData>(context).newDataInput = input;
                    },
                    cancelText: 'Cancel',
                    hintText: null);
              },
            );
          }
        },
      ),
    );
  }
}
