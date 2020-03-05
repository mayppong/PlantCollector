import 'package:flutter/material.dart';
import 'package:plant_collector/formats/colors.dart';
import 'package:plant_collector/formats/text.dart';
import 'package:plant_collector/models/app_data.dart';
import 'package:plant_collector/models/cloud_db.dart';
import 'package:plant_collector/models/data_types/friend_data.dart';
import 'package:plant_collector/models/data_types/message_data.dart';
import 'package:provider/provider.dart';

class ComposeMessage extends StatefulWidget {
  final bool convoStarted;
  ComposeMessage({@required this.convoStarted});
  @override
  _ComposeMessageState createState() => _ComposeMessageState();
}

class _ComposeMessageState extends State<ComposeMessage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        //TODO complete action, maybe provide stickers
        SizedBox(
          width: 40.0 * MediaQuery.of(context).size.width * kScaleFactor,
//          child: FlatButton(
//            child: Icon(
//              Icons.library_add,
//              color: kGreenDark,
//            ),
//            onPressed: () {
//
//            },
//          ),
        ),
        SizedBox(
          width: 0.70 * MediaQuery.of(context).size.width,
          child: TextField(
            style: TextStyle(decoration: TextDecoration.none),
            controller: _controller,
            minLines: 1,
            maxLines: 50,
            onChanged: (value) {
              Provider.of<AppData>(context).newDataInput = value;
            },
          ),
        ),
        SizedBox(
          width: 50.0 * MediaQuery.of(context).size.width * kScaleFactor,
          child: FlatButton(
            child: Icon(
              Icons.send,
              color: kGreenDark,
            ),
            onPressed: () {
              String text = Provider.of<AppData>(context).newDataInput;
              String connectionID =
                  Provider.of<AppData>(context).getCurrentChatId();
              String currentID =
                  Provider.of<CloudDB>(context).currentUserFolder;
              //get document name
              String document =
                  Provider.of<CloudDB>(context).conversationDocumentName(
                connectionId: connectionID,
              );
              //create message
              MessageData message = Provider.of<CloudDB>(context).createMessage(
                text: text,
                type: (text.startsWith('http') && !text.contains(' '))
                    ? MessageKeys.typeUrl
                    : MessageKeys.typeText,
                media: (text.startsWith('http') && !text.contains(' '))
                    ? text
                    : '',
              );
              CloudDB.sendMessage(message: message, document: document);
              //check if chat started
              if (!widget.convoStarted) {
                //set chat as started for current user
                Provider.of<CloudDB>(context).updateConnectionDocument(
                    pathID: currentID,
                    documentID: connectionID,
                    key: FriendKeys.chatStarted,
                    value: true);
                //set chat as started for other user
                Provider.of<CloudDB>(context).updateConnectionDocument(
                    pathID: connectionID,
                    documentID: currentID,
                    key: FriendKeys.chatStarted,
                    value: true);
              }
              //clear data input and field text
              Provider.of<AppData>(context).newDataInput = null;
              _controller.clear();
            },
          ),
        ),
      ],
    );
  }
}
