import 'package:flutter/material.dart';
import 'package:plant_collector/formats/text.dart';
import 'package:plant_collector/widgets/dialogs/dialog_template.dart';
import 'package:plant_collector/formats/colors.dart';

class DialogConfirm extends StatelessWidget {
  final String title;
  final String text;
  final String buttonText;
  final Function onPressed;
  final bool hideCancel;
  DialogConfirm(
      {this.title,
      this.text,
      this.onPressed,
      this.buttonText,
      this.hideCancel});

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      title: title,
      text: text,
      list: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            hideCancel == false
                ? Expanded(
                    child: FlatButton(
                      child: Text(
                        'CANCEL',
                        style: TextStyle(
                          fontSize: AppTextSize.medium *
                              MediaQuery.of(context).size.width,
                          fontWeight: AppTextWeight.medium,
                          color: kButtonCancel,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  )
                : SizedBox(),
            SizedBox(
              width: 20.0,
            ),
            Expanded(
              child: FlatButton(
                child: Text(
                  'CONFIRM',
                  style: TextStyle(
                    fontSize:
                        AppTextSize.medium * MediaQuery.of(context).size.width,
                    fontWeight: AppTextWeight.medium,
                    color: kButtonAccept,
                  ),
                ),
                onPressed: () {
                  onPressed();
                },
              ),
            ),
            hideCancel == true
                ? SizedBox(
                    width: 20.0,
                  )
                : SizedBox(),
          ],
        ),
      ],
    );
  }
}
