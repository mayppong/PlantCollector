import 'package:flutter/material.dart';
import 'package:plant_collector/formats/text.dart';
import 'package:plant_collector/models/app_data.dart';
import 'package:plant_collector/models/cloud_db.dart';
import 'package:plant_collector/models/data_types/user_data.dart';
import 'package:plant_collector/models/user.dart';
import 'package:plant_collector/screens/dialog/dialog_screen_input.dart';
import 'package:plant_collector/widgets/button_add.dart';
import 'package:plant_collector/widgets/dialogs/dialog_confirm.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class ButtonAddFriend extends StatelessWidget {
  final List friends;
  ButtonAddFriend({
    @required this.friends,
  });

  @override
  Widget build(BuildContext context) {
    return ButtonAdd(
      textColor: AppTextColor.white,
      icon: Icons.person_add,
      buttonText: 'By Email',
      onPress: () {
        //determine if user data saved
        bool userData = (Provider.of<AppData>(context).currentUserInfo != null);
        //determine if user name set
        bool userNameSet =
            (Provider.of<AppData>(context).currentUserInfo.name != null &&
                Provider.of<AppData>(context).currentUserInfo.name != '');
        //first, direct user to create a user name
        if (userData && !userNameSet) {
          showDialog(
              context: context,
              builder: (context) {
                return DialogScreenInput(
                    title:
                        'Before adding a friend, first create your user name.',
                    acceptText: 'Add',
                    acceptOnPress: () {
                      //update user document to add user name
                      Provider.of<CloudDB>(context).updateUserDocument(
                        data: CloudDB.updatePairFull(
                            key: UserKeys.name,
                            value: Provider.of<AppData>(context).newDataInput),
                      );
                      //pop the context
                      Navigator.pop(context);
                    },
                    onChange: (input) {
                      Provider.of<AppData>(context).newDataInput = input;
                    },
                    cancelText: 'Cancel',
                    hintText: null);
              });
        }
        //then direct the user to add friend
        if (userData && userNameSet) {
          showDialog(
              context: context,
              builder: (context) {
                return DialogScreenInput(
                    title: 'Type your friend\'s email.',
                    acceptText: 'Add',
                    acceptOnPress: () async {
                      //try to find if user is registered from email
                      String friendID = await CloudDB.getUserFromEmail(
                          userEmail:
                              Provider.of<AppData>(context).newDataInput);
                      //look for ID in friend list
                      bool check = false;
                      for (UserData friend in friends) {
                        if (friend.id == friendID) {
                          check = true;
                        }
                      }
                      //check if user is inputted their own email
                      bool sameEmail = (Provider.of<AppData>(context)
                              .newDataInput ==
                          Provider.of<UserAuth>(context).signedInUser.email);
                      Navigator.pop(context);
                      //determine dialog text
                      String title;
                      String dialogText;
                      String buttonText = 'OK';
                      Function onPressed = () {};
                      if (sameEmail == true) {
                        //so use can't send request to self
                        title = 'Cannot Send';
                        dialogText =
                            'It\'s great that you want to be friends with yourself!'
                            '\n\nUnfortunately you can\'t send yourself a request.';
                      } else if (check == true) {
                        //so user can't send another request to same friend
                        title = 'Cannot Send';
                        dialogText = 'That must be one great friend!'
                            '\n\nYou\'re already connected so we won\'t send another request.';
                      } else if (friendID != null) {
                        //if all good send the request to friend
                        Provider.of<CloudDB>(context)
                            .sendConnectionRequest(connectionID: friendID);
                        title = 'Request Sent';
                        dialogText =
                            'A request has been sent.  You will be able to share collections once it is accepted.';
                      } else {
                        //if all else fails, send an invite via share
                        title = 'Send Invite?';
                        dialogText =
                            'No user was found with this email address.  Would you like to invite them?';
                        buttonText = 'Invite';
                        onPressed = () {
                          Share.share(
                              //TODO when ready link to download app
                              'I\'m using Plant Collector to keep a record of my plants and share my collection with friends.'
                              '\n\n Check it out here: <future download link>');
                        };
                      }
                      //show a dialog to provide feedback
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return DialogConfirm(
                            hideCancel: true,
                            title: title,
                            text: dialogText,
                            buttonText: buttonText,
                            onPressed: () {
                              onPressed();
                              Navigator.pop(context);
                            },
                          );
                        },
                      );
                    },
                    onChange: (input) {
                      Provider.of<AppData>(context).newDataInput = input;
                    },
                    cancelText: 'Cancel',
                    hintText: null);
              });
        }
      },
    );
  }
}