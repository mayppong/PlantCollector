import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plant_collector/formats/colors.dart';
import 'package:plant_collector/models/app_data.dart';
import 'package:plant_collector/models/cloud_db.dart';
import 'package:plant_collector/models/data_types/message_data.dart';
import 'package:plant_collector/models/data_types/user_data.dart';
import 'package:plant_collector/screens/chat/chat.dart';
import 'package:plant_collector/widgets/chat_avatar.dart';
import 'package:plant_collector/widgets/container_wrapper.dart';
import 'package:plant_collector/widgets/info_tip.dart';
import 'package:plant_collector/widgets/notification_bubble.dart';
import 'package:plant_collector/widgets/section_header.dart';
import 'package:plant_collector/widgets/tile_white.dart';
import 'package:provider/provider.dart';

class SocialUpdates extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ContainerWrapper(
      child: Column(
        children: <Widget>[
          SectionHeader(
            title: 'Current Chats',
          ),
          SizedBox(
            height: 5.0,
          ),
          Consumer<UserData>(
            builder: (context, UserData user, _) {
              if (user == null || user.chats.length <= 0) {
                //show infotip otherwise show
                return Row(
                  children: <Widget>[
                    Expanded(
                      child: InfoTip(
                          onPress: () {},
                          showAlways: true,
                          text:
                              'What\'s better than a plant person?  A community of plant people!  \n\n'
                              'After you add a friend, and they accept, you\'ll be able to start a chat from the "Connections" section below.  \n\n'),
                    ),
                  ],
                );
              } else {
                List<Widget> connectionList = [];
                for (String friend in user.chats) {
                  //check for message history
                  //generate a widget
                  if (Provider.of<AppData>(context)
                      .currentUserInfo
                      .chats
                      .contains(friend)) {
                    Widget conversationWidget = FutureProvider<Map>.value(
                      value: CloudDB.getConnectionProfile(connectionID: friend),
                      child: Consumer<Map>(builder: (context, Map friend, _) {
                        if (friend == null) {
                          return SizedBox();
                        } else {
                          UserData profile = UserData.fromMap(map: friend);
                          return ChatBubble(user: profile);
                        }
                      }),
                    );
                    connectionList.add(conversationWidget);
                  }
                }
                //if shorter than five, bail on gridview to allow center
                if (connectionList.length < 5) {
                  //new widget list
                  List<Widget> connectionListRepack = [];
                  //wrap in a sized box
                  for (Widget item in connectionList) {
                    Widget repack = SizedBox(
                      height: 0.18 * MediaQuery.of(context).size.width,
                      width: 0.18 * MediaQuery.of(context).size.width,
                      child: item,
                    );
                    connectionListRepack.add(repack);
                  }
                  return TileWhite(
                    bottomPadding: 5.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: connectionListRepack,
                    ),
                  );
                } else {
                  return TileWhite(
                    bottomPadding: 5.0,
                    child: GridView.count(
                      primary: false,
                      shrinkWrap: true,
                      crossAxisCount: 5,
                      children: connectionList,
                      childAspectRatio: 1,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  ChatBubble({@required this.user});
  final UserData user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(5.0),
      child: StreamProvider<QuerySnapshot>.value(
        value: Provider.of<CloudDB>(context).streamConvoMessages(
          connectionID: user.id,
        ),
        child: Consumer<QuerySnapshot>(
          builder: (context, QuerySnapshot messages, _) {
//                                      List<String> unreadList = [];
            if (messages != null &&
                messages.documents != null &&
                messages.documents.length > 0) {
              List<String> unreadList = [];
              for (DocumentSnapshot message in messages.documents) {
                //make sure message isn't empty, is from friend, and hasn't been read
                if (message != null &&
                    message.data[MessageKeys.sender] !=
                        Provider.of<CloudDB>(context).currentUserFolder &&
                    message.data[MessageKeys.read] == false) {
                  unreadList.add(message.reference.path);
                }
              }
              int unread = unreadList.length;
//                                        if (unread >= 1 &&
//                                            messages.documentChanges.length >=
//                                                1) {
//                                          String messagePlural = (unread == 1)
//                                              ? 'message'
//                                              : 'messages';
//                                          Notifications
//                                              .showOngoingNotificationSilent(
//                                                  notification:
//                                                      Provider.of<AppData>(
//                                                              context)
//                                                          .notifications,
//                                                  title: 'New Messages',
//                                                  body:
//                                                      '${user.name} sent you $unread new $messagePlural.');
//                                        }
              return GestureDetector(
                onTap: () {
                  //on tap set unread messages as read
                  if (unreadList.length >= 1) {
                    for (String reference in unreadList) {
                      CloudDB.readMessage(reference: reference);
                    }
                  }
                  //navigate to the chat page with the connection map
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => ChatScreen(
                        friend: user,
                      ),
                    ),
                  );
                },
                child: Stack(
                  fit: StackFit.loose,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, boxShadow: kShadowBox),
                      child: ChatAvatar(
                        avatarLink: user.avatar,
                      ),
                    ),
                    unread >= 1
                        ? NotificationBubble(count: unread)
                        : SizedBox(),
                  ],
                ),
              );
            } else {
              return SizedBox();
            }
          },
        ),
      ),
    );
  }
}

//include an extra button to facilitate adding a new connection
//style to match chat_avatar
//                  connectionList.add(
//                    StreamProvider<List<RequestData>>.value(
//                      value: Provider.of<CloudDB>(context).streamRequestsData(),
//                      child: GestureDetector(
//                        onTap: () {
//                          //navigate to connections
//                          Navigator.pushNamed(context, 'connections');
//                        },
//                        child: Padding(
//                          padding: EdgeInsets.all(
//                            5.0 *
//                                MediaQuery.of(context).size.width *
//                                kScaleFactor,
//                          ),
//                          child: Stack(
//                            fit: StackFit.loose,
//                            children: <Widget>[
//                              //background image
//                              CircleAvatar(
//                                radius: 50.0 *
//                                    MediaQuery.of(context).size.width *
//                                    kScaleFactor,
//                                foregroundColor: Colors.white,
//                                backgroundColor: kGreenMedium,
//                                child: Icon(
//                                  Icons.person_add,
//                                  size: 30.0 *
//                                      MediaQuery.of(context).size.width *
//                                      kScaleFactor,
//                                ),
//                              ),
//                              //bubble for count
//                              Consumer<List<RequestData>>(builder:
//                                  (context, List<RequestData> requests, _) {
//                                if (requests != null && requests.length >= 1) {
//                                  return NotificationBubble(
//                                      count: requests.length);
//                                } else {
//                                  return SizedBox();
//                                }
//                              }),
//                            ],
//                          ),
//                        ),
//                      ),
//                    ),
//                  );
