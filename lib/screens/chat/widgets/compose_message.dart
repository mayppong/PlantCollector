import 'package:flutter/material.dart';
import 'package:plant_collector/formats/colors.dart';
import 'package:plant_collector/formats/text.dart';
import 'package:plant_collector/models/app_data.dart';
import 'package:plant_collector/models/cloud_db.dart';
import 'package:plant_collector/models/data_storage/firebase_folders.dart';
import 'package:plant_collector/models/data_types/message_data.dart';
import 'package:plant_collector/models/data_types/user_data.dart';
import 'package:provider/provider.dart';

class ComposeMessage extends StatefulWidget {
  final UserData friendProfile;
  ComposeMessage({@required this.friendProfile});
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
            style: TextStyle(
                decoration: TextDecoration.none,
                fontSize:
                    AppTextSize.small * MediaQuery.of(context).size.width),
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
              size: 30.0 * MediaQuery.of(context).size.width * kScaleFactor,
            ),
            onPressed: () {
              String text = Provider.of<AppData>(context).newDataInput;
//              String connectionID =
//                  Provider.of<AppData>(context).getCurrentChatId();
              String currentID =
                  Provider.of<CloudDB>(context).currentUserFolder;

              //get document name
              String document =
                  Provider.of<CloudDB>(context).conversationDocumentName(
                connectionId: widget.friendProfile.id,
              );

              //create message
              MessageData message = AppData.createMessage(
                senderID: currentID,
                senderName: Provider.of<AppData>(context).currentUserInfo.name,
                targetDevices: widget.friendProfile.devicePushTokens,
                recipient: widget.friendProfile.id,
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
              if (!Provider.of<AppData>(context)
                  .currentUserInfo
                  .chats
                  .contains(widget.friendProfile.id)) {
                //set chat as started for current user
                CloudDB.updateDocumentL1Array(
                    collection: DBFolder.users,
                    document: currentID,
                    key: UserKeys.chats,
                    entries: [widget.friendProfile.id],
                    action: true);
                //set chat as started for other user
                CloudDB.updateDocumentL1Array(
                    collection: DBFolder.users,
                    document: widget.friendProfile.id,
                    key: UserKeys.chats,
                    entries: [currentID],
                    action: true);
                //add both user IDs to the chat document
//                Map<String, dynamic> participants = {
//                  'participants': [currentID, widget.friendProfile.id]
//                };
//                CloudDB.setDocumentL1(
//                    collection: DBDocument.conversations,
//                    document: document,
//                    data: participants);
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
