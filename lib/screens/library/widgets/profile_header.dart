import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:plant_collector/formats/colors.dart';
import 'package:plant_collector/formats/text.dart';
import 'package:plant_collector/models/app_data.dart';
import 'package:plant_collector/models/builders_general.dart';
import 'package:plant_collector/models/cloud_db.dart';
import 'package:plant_collector/models/cloud_store.dart';
import 'package:plant_collector/models/data_types/user_data.dart';
import 'package:plant_collector/models/global.dart';
import 'package:plant_collector/models/message.dart';
import 'package:plant_collector/models/user.dart';
import 'package:plant_collector/screens/dialog/dialog_screen_input.dart';
import 'package:plant_collector/screens/library/widgets/stat_card.dart';
import 'package:plant_collector/widgets/container_card.dart';
import 'package:plant_collector/widgets/container_wrapper.dart';
import 'package:plant_collector/widgets/tile_white.dart';
import 'package:plant_collector/widgets/updates_row.dart';
import 'package:provider/provider.dart';

class ProfileHeader extends StatelessWidget {
  final bool connectionLibrary;
  final UserData user;
  ProfileHeader({@required this.connectionLibrary, @required this.user});
  @override
  Widget build(BuildContext context) {
    //*****SET WIDGET VISIBILITY START*****//

    //enable dialogs only if library belongs to the current user
    bool enableDialogs = (connectionLibrary == false);

    //user name to display
    String displayName = user.name;
    if (user.name == '' && connectionLibrary == false) {
      displayName = 'Hold to Set Name';
    } else if (user.name == '') {
      displayName = '';
    }

    //enable unique public id only if it exists
    bool showUniquePublicID = (user != null &&
        user.uniquePublicID != '' &&
        user.uniquePublicID != 'not set');

    //show about only for friend library if they have written something
    bool displayAbout = (user != null && user.about.length > 0
//            && connectionLibrary == true
        );

    //show about only for friend library if they have written something
    bool displayLink = (user != null && user.link.length > 0
//            && connectionLibrary == true
        );

    //check for recent updates to display icon
//    bool recentUpdate =
//        (AppData.isRecentUpdate(lastUpdate: user.lastPlantUpdate) ||
//            AppData.isRecentUpdate(lastUpdate: user.lastPlantAdd));
    String recentPlantAddText =
        AppData.lastPlantAdd(lastAdd: user.lastPlantAdd);
    bool recentPlantAdd = (recentPlantAddText.length != 0);

//    String recentPlantUpdateText =
//        AppData.lastPlantUpdate(lastUpdate: user.lastPlantUpdate);
//    bool recentPlantUpdate = (recentPlantUpdateText.length != 0);

    //*****SET WIDGET VISIBILITY END*****//

    return ContainerWrapper(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onLongPress: () {
              if (enableDialogs == true)
                showDialog(
                    context: context,
                    builder: (context) {
                      return DialogScreenInput(
                          title: 'Update Name',
                          acceptText: 'Update',
                          acceptOnPress: () {
                            //update user document with map
                            Provider.of<CloudDB>(context).updateUserDocument(
                              data: AppData.updatePairFull(
                                  key: UserKeys.name,
                                  value: Provider.of<AppData>(context)
                                      .newDataInput),
                            );
                            //pop context
                            Navigator.pop(context);
                          },
                          onChange: (input) {
                            Provider.of<AppData>(context).newDataInput = input;
                          },
                          cancelText: 'Cancel',
                          hintText: user.name);
                    });
            },
            child: TileWhite(
              bottomPadding: 0.0,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            displayName,
                            textAlign: TextAlign.center,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 1.3 *
                                  AppTextSize.huge *
                                  MediaQuery.of(context).size.width,
                              fontWeight: AppTextWeight.medium,
                            ),
                          ),
                        ),
//                        (recentUpdate == true)
//                            ? Padding(
//                                padding: EdgeInsets.only(left: 5.0),
//                                child: Icon(
//                                  Icons.bubble_chart,
//                                  size: AppTextSize.large *
//                                      MediaQuery.of(context).size.width,
//                                  color: kGreenMedium,
//                                ),
//                              )
//                            : SizedBox(),
                      ],
                    ),
                    (showUniquePublicID == true)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                '( ',
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                  color: AppTextColor.medium,
                                  fontWeight: AppTextWeight.heavy,
                                  fontSize: AppTextSize.small *
                                      MediaQuery.of(context).size.width,
                                ),
                              ),
                              Text(
                                user.uniquePublicID,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                  color: kGreenMedium,
                                  fontWeight: AppTextWeight.heavy,
                                  fontSize: AppTextSize.small *
                                      MediaQuery.of(context).size.width,
                                ),
                              ),
                              Text(
                                ' )',
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                style: TextStyle(
                                  color: AppTextColor.medium,
                                  fontWeight: AppTextWeight.heavy,
                                  fontSize: AppTextSize.small *
                                      MediaQuery.of(context).size.width,
                                ),
                              ),
                            ],
                          )
                        : SizedBox(),
                    Container(
                      margin: EdgeInsets.only(
                        right: 5.0,
                      ),
                      width: 0.08 * MediaQuery.of(context).size.width,
                      child: UIBuilders.getBadge(userTotalPlants: user.plants),
                    ),
                    //spacer
                    SizedBox(
                      height: 5.0,
                    ),
                    //show recent new plants
                    (recentPlantAdd == true)
                        ? UpdatesRow(
                            text: recentPlantAddText,
                            textSize: AppTextSize.medium,
                            icon: Icons.add_circle_outline,
                            mainAxisAlignment: MainAxisAlignment.center,
                          )
                        : SizedBox(),
                    //show recent plant updates
//                    (recentPlantUpdate == true || recentPlantAdd == true)
//                        ? UpdatesRow(
//                            text: recentPlantUpdateText,
//                            textSize: AppTextSize.medium,
//                            icon: Icons.bubble_chart,
//                            mainAxisAlignment: MainAxisAlignment.center,
//                          )
//                        : SizedBox(),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5.0,
          ),
          GestureDetector(
            onLongPress: () async {
              if (enableDialogs == true) {
                //set userID for use in path generation
                Provider.of<CloudStore>(context).setUserFolder(
                    userID:
                        (await Provider.of<UserAuth>(context).getCurrentUser())
                            .uid);
                //get image from camera
                File image = await Provider.of<CloudStore>(context)
                    .getImageFile(fromCamera: false);
                //check to make sure the user didn't back out
                if (image != null) {
                  //upload image
                  StorageUploadTask upload = Provider.of<CloudStore>(context)
                      .uploadToUserSettingsTask(
                          imageFile: image, imageName: UserKeys.background);
                  //make sure upload completes
                  StorageTaskSnapshot completion = await upload.onComplete;
                  //get the url string
                  String url = await Provider.of<CloudStore>(context)
                      .getDownloadURL(snapshot: completion);
                  //add image reference to plant document
                  Provider.of<CloudDB>(context).updateUserDocument(
                    data: AppData.updatePairFull(
                      key: UserKeys.background,
                      value: url,
                    ),
                  );
                }
              }
            },
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.only(
                left: 5.0,
                right: 5.0,
                top: 5.0,
                bottom: 5.0,
              ),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: kShadowBox,
                  color: kGreenDark),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5.0,
                  vertical: 10.0,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: user.background != ''
                        ? CachedNetworkImageProvider(
                            user.background,
                          )
                        : AssetImage(
                            'assets/images/default.png',
                          ),
                  ),
                ),
                child: GestureDetector(
                  onLongPress: () async {
                    if (enableDialogs == true) {
                      //set userID for use in path generation
                      Provider.of<CloudStore>(context).setUserFolder(
                          userID: (await Provider.of<UserAuth>(context)
                                  .getCurrentUser())
                              .uid);
                      //get image from camera
                      File image = await Provider.of<CloudStore>(context)
                          .getImageFile(fromCamera: false);
                      //check to make sure the user didn't back out
                      if (image != null) {
                        //upload image
                        StorageUploadTask upload =
                            Provider.of<CloudStore>(context)
                                .uploadToUserSettingsTask(
                                    imageFile: image,
                                    imageName: UserKeys.avatar);
                        //make sure upload completes
                        StorageTaskSnapshot completion =
                            await upload.onComplete;
                        //get the url string
                        String url = await Provider.of<CloudStore>(context)
                            .getDownloadURL(snapshot: completion);
                        //add image reference to plant document
                        Provider.of<CloudDB>(context).updateUserDocument(
                          data: AppData.updatePairFull(
                            key: UserKeys.avatar,
                            value: url,
                          ),
                        );
                      } else {}
                    } else {
                      //do nothing
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(),
                      CircleAvatar(
                        radius: 80.0 *
                            MediaQuery.of(context).size.width *
                            kScaleFactor,
                        backgroundColor:
                            user.avatar != '' ? kGreenDark : Color(0x00000000),
                        backgroundImage: user.avatar != ''
                            ? CachedNetworkImageProvider(
                                user.avatar,
                              )
                            : AssetImage(
                                'assets/images/app_icon_white_512.png'),
                      ),
                      SizedBox(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          //Display an about section but not for your own profile
          (displayAbout == true || displayLink == true)
              ? ContainerCard(
                  color: AppTextColor.white,
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        (displayAbout == true)
                            ? Text(
                                user.about,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: AppTextSize.small *
                                      MediaQuery.of(context).size.width,
                                  fontWeight: AppTextWeight.medium,
                                  color: AppTextColor.black,
                                ),
                              )
                            : SizedBox(),
                        (displayLink == true)
                            ? GestureDetector(
                                onTap: () {
                                  Message.launchURL(url: user.link);
                                },
                                child: Text(
                                  user.link,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: AppTextSize.small *
                                        MediaQuery.of(context).size.width,
                                    fontWeight: AppTextWeight.medium,
                                    color: kGreenDark,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                  ),
                )
              : SizedBox(),
          SizedBox(
            height: 0.33 * MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: StatCard(
                    cardLabel: user.plants == 1
                        ? GlobalStrings.plant
                        : GlobalStrings.plants,
                    cardValue: user.plants != 0 ? user.plants.toString() : '0',
                  ),
                ),
                Expanded(
                  child: StatCard(
                    cardLabel: user.collections == 1
                        ? GlobalStrings.collection
                        : GlobalStrings.collections,
                    cardValue: user.collections != 0
                        ? user.collections.toString()
                        : '0',
                  ),
                ),
                Expanded(
                  child: StatCard(
                    cardLabel: user.photos == 1
                        ? GlobalStrings.photo
                        : GlobalStrings.photos,
                    cardValue: user.photos != 0 ? user.photos.toString() : '0',
                  ),
                ),
//              Expanded(
//                child: StatCard(
//                  cardLabel: 'Photo',
//                  cardValue: data.getImageCount(
//                    plants: data.plants,
//                  ),
//                ),
//              ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
