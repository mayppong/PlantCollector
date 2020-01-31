import 'package:flutter/material.dart';
import 'package:plant_collector/formats/colors.dart';
import 'package:plant_collector/formats/text.dart';
import 'package:plant_collector/screens/dialog/dialog_screen.dart';

class DialogScreenInput extends StatelessWidget {
  final String title;
  final String acceptText;
  final Function acceptOnPress;
  final Function onChange;
  final String cancelText;
  final String hintText;
  DialogScreenInput({
    @required this.title,
    @required this.acceptText,
    @required this.acceptOnPress,
    @required this.onChange,
    @required this.cancelText,
    @required this.hintText,
  });
  @override
  Widget build(BuildContext context) {
    return DialogScreen(
      title: title,
      children: <Widget>[
        TextFormField(
          decoration: InputDecoration(hintText: hintText),
          initialValue: hintText,
          cursorColor: AppTextColor.white,
          autofocus: true,
          textAlign: TextAlign.center,
          minLines: 1,
          maxLines: 10,
          onChanged: onChange,
          style: TextStyle(
            fontSize: AppTextSize.huge * MediaQuery.of(context).size.width,
            fontWeight: AppTextWeight.heavy,
            color: AppTextColor.white,
          ),
        ),
        SizedBox(
          height: AppTextSize.large * MediaQuery.of(context).size.width,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Expanded(
              child: FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  cancelText.toUpperCase(),
                  style: TextStyle(
                    fontSize:
                        AppTextSize.large * MediaQuery.of(context).size.width,
                    fontWeight: AppTextWeight.medium,
                    color: kButtonCancel,
                  ),
                ),
              ),
            ),
            Expanded(
              child: FlatButton(
                onPressed: () {
                  acceptOnPress();
                },
                child: Text(
                  acceptText.toUpperCase(),
                  style: TextStyle(
                    fontSize:
                        AppTextSize.large * MediaQuery.of(context).size.width,
                    fontWeight: AppTextWeight.medium,
                    color: kButtonAccept,
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}