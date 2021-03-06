import 'package:flutter/material.dart';
import 'package:plant_collector/formats/colors.dart';
import 'package:plant_collector/formats/text.dart';
import 'package:plant_collector/models/app_data.dart';
import 'package:plant_collector/screens/dialog/dialog_screen_input.dart';
import 'package:plant_collector/widgets/container_card.dart';
import 'package:plant_collector/widgets/dialogs/dialog_confirm.dart';
import 'package:provider/provider.dart';

class SettingsCard extends StatelessWidget {
  final Function onSubmit;
  final Function onPress;
  final String cardLabel;
  final String cardText;
  final bool allowDialog;
  final bool confirmDialog;
  final String dialogText;
  final bool disableEdit;
  final String acceptButtonText;
  final String authPromptText;
  final bool obscureInput;
  SettingsCard(
      {@required this.onSubmit,
      @required this.onPress,
      @required this.cardLabel,
      @required this.cardText,
      this.allowDialog,
      this.confirmDialog,
      this.dialogText,
      this.disableEdit = false,
      this.acceptButtonText = 'UPDATE',
      this.authPromptText,
      this.obscureInput = false});
  @override
  Widget build(BuildContext context) {
    Color avatarBackground =
        (disableEdit == true) ? kGreenMedium : kGreenMedium;

    Color avatarForeground =
        (disableEdit == true) ? Color(0x00FFFFFF) : kGreenDark;

    return ContainerCard(
      child: FlatButton(
        child: Container(
          width: 0.95 * MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              CircleAvatar(
                backgroundColor: avatarBackground,
                foregroundColor: avatarForeground,
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
                  fontSize:
                      AppTextSize.small * MediaQuery.of(context).size.width,
                  color: kGreenMedium,
                ),
              ),
              Expanded(
                child: Text(
                  '$cardText',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize:
                        AppTextSize.small * MediaQuery.of(context).size.width,
                    color: Colors.white,
                    shadows: kShadowText,
                  ),
                ),
              ),
            ],
          ),
        ),
        onPressed: () {
          if (confirmDialog == true) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return DialogConfirm(
                  title: 'Update Settings',
                  text: dialogText,
                  onPressed: onSubmit,
                  hideCancel: false,
                );
              },
            );
          } else if (allowDialog == false) {
            onPress();
          } else {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return DialogScreenInput(
                    title: authPromptText != null ? authPromptText : cardLabel,
                    acceptText: acceptButtonText,
                    obscure: obscureInput,
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
