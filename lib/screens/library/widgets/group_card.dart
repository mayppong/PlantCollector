import 'package:flutter/material.dart';
import 'package:plant_collector/models/data_types/collection_data.dart';
import 'package:plant_collector/models/data_storage/firebase_folders.dart';
import 'package:plant_collector/models/data_types/group_data.dart';
import 'package:plant_collector/models/data_types/plant_data.dart';
import 'package:plant_collector/models/data_types/user_data.dart';
import 'package:plant_collector/screens/dialog/dialog_screen_input.dart';
import 'package:plant_collector/widgets/container_wrapper.dart';
import 'package:plant_collector/widgets/dialogs/color_picker/dialog_color_picker.dart';
import 'package:provider/provider.dart';
import 'package:plant_collector/models/cloud_db.dart';
import 'package:plant_collector/models/builders_general.dart';
import 'package:expandable/expandable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plant_collector/widgets/tile_white.dart';
import 'package:plant_collector/models/app_data.dart';
import 'package:plant_collector/formats/text.dart';
import 'package:plant_collector/formats/colors.dart';

class GroupCard extends StatelessWidget {
  final bool connectionLibrary;
  final GroupData group;
  final List<dynamic> groups;
//  final List<Map> setCollectionsList;
  GroupCard({
    @required this.connectionLibrary,
    @required this.group,
    @required this.groups,
//    @required this.setCollectionsList
  });

  @override
  Widget build(BuildContext context) {
    Stream plantsStream;
    if (connectionLibrary == false) {
      plantsStream = Provider.of<CloudDB>(context).userPlantsStream;
    } else {
      plantsStream = Provider.of<CloudDB>(context).streamPlants(
          userID: Provider.of<CloudDB>(context).connectionUserFolder);
    }
    return ContainerWrapper(
      color: convertColor(storedColor: group.color),
      child: ExpandableNotifier(
        initialExpanded: true,
        child: Expandable(
          collapsed: GroupHeader(
            connectionLibrary: connectionLibrary,
            group: group,
            button: ExpandableButton(
              child: CircleAvatar(
                radius: 20.0,
                backgroundColor: convertColor(storedColor: group.color),
                child: Icon(
                  Icons.keyboard_arrow_down,
                  size: 30.0 * MediaQuery.of(context).size.width * kScaleFactor,
                  color: AppTextColor.white,
                ),
              ),
            ),
          ),
          expanded: Column(
            children: <Widget>[
              GroupHeader(
                connectionLibrary: connectionLibrary,
                group: group,
                button: ExpandableButton(
                  child: CircleAvatar(
                    radius:
                        20.0 * MediaQuery.of(context).size.width * kScaleFactor,
                    backgroundColor: convertColor(storedColor: group.color),
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      size: 30.0 *
                          MediaQuery.of(context).size.width *
                          kScaleFactor,
                      color: AppTextColor.white,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                children: <Widget>[
                  Consumer<QuerySnapshot>(
                    builder: (context, QuerySnapshot collectionsSnap, _) {
                      if (collectionsSnap == null) return Column();
                      if (connectionLibrary == false) {
                        Provider.of<AppData>(context).currentUserCollections =
                            collectionsSnap.documents
                                .map((doc) =>
                                    CollectionData.fromMap(map: doc.data))
                                .toList();
                        //update tally in user document
                        if (collectionsSnap.documents != null &&
                            Provider.of<AppData>(context).currentUserInfo !=
                                null
                            //don't bother updating if the values are the same
                            &&
                            collectionsSnap.documents.length !=
                                Provider.of<AppData>(context)
                                    .currentUserInfo
                                    .collections) {
                          Map countData = CloudDB.updatePairFull(
                              key: UserKeys.collections,
                              value: collectionsSnap.documents.length);
                          Provider.of<CloudDB>(context).updateUserDocument(
                            data: countData,
                          );
                        }
                      } else {
                        Provider.of<AppData>(context).connectionCollections =
                            collectionsSnap.documents
                                .map((doc) =>
                                    CollectionData.fromMap(map: doc.data))
                                .toList();
                      }
                      List<CollectionData> groupCollections =
                          CloudDB.getMapsFromList(
                        groupCollectionIDs: group.collections,
                        collections: connectionLibrary == false
                            ? Provider.of<AppData>(context)
                                .currentUserCollections
                            : Provider.of<AppData>(context)
                                .connectionCollections,
                      );
                      Color groupColor = convertColor(storedColor: group.color);
                      return StreamProvider<QuerySnapshot>.value(
                        value: plantsStream,
                        child: Consumer<QuerySnapshot>(
                          builder: (context, QuerySnapshot plantsSnap, _) {
                            if (plantsSnap != null) {
                              if (connectionLibrary == false) {
                                //list to add plants
                                List<PlantData> plants = [];
                                //create a plant from each document
                                for (DocumentSnapshot snap
                                    in plantsSnap.documents) {
                                  plants.add(PlantData.fromMap(plantMap: snap));
                                }
                                //save plants for use elsewhere
                                Provider.of<AppData>(context)
                                    .currentUserPlants = plants;
                                //update tally in user document
                                if (plantsSnap.documents != null &&
                                    Provider.of<AppData>(context)
                                            .currentUserInfo !=
                                        null
                                    //don't bother updating if the values are the same
                                    &&
                                    plantsSnap.documents.length !=
                                        Provider.of<AppData>(context)
                                            .currentUserInfo
                                            .plants) {
                                  Map countData = CloudDB.updatePairFull(
                                      key: UserKeys.plants,
                                      value: plantsSnap.documents.length);
                                  Provider.of<CloudDB>(context)
                                      .updateUserDocument(
                                    data: countData,
                                  );
                                }
                              } else {
                                //list to add plants
                                List<PlantData> plants = [];
                                //create a plant from each document
                                for (DocumentSnapshot snap
                                    in plantsSnap.documents) {
                                  plants.add(PlantData.fromMap(plantMap: snap));
                                }
                                //save plants for use elsewhere
                                Provider.of<AppData>(context).connectionPlants =
                                    plants;
                              }
                              return UIBuilders.displayCollections(
                                  connectionLibrary: connectionLibrary,
                                  userCollections: groupCollections,
                                  groupID: group.id,
                                  groupColor: groupColor);
                            } else {
                              return SizedBox();
                            }
                          },
                        ),
                      );
                    },
                  ),
                  connectionLibrary == false
                      ? TileWhite(
                          child: FlatButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return DialogScreenInput(
                                        title: 'Create new Collection',
                                        acceptText: 'Create',
                                        acceptOnPress: () {
                                          //create a map from the data
                                          CollectionData collection =
                                              Provider.of<AppData>(context)
                                                  .newCollection();
                                          //upload new collection data
                                          Provider.of<CloudDB>(context)
                                              .insertDocumentToCollection(
                                                  data: collection.toMap(),
                                                  collection:
                                                      DBFolder.collections,
                                                  documentName: collection.id);
                                          //add collection reference to group
                                          Provider.of<CloudDB>(context)
                                              .updateArrayInDocumentInCollection(
                                                  arrayKey:
                                                      GroupKeys.collections,
                                                  entries: [collection.id],
                                                  folder: DBFolder.groups,
                                                  documentName: group.id,
                                                  action: true);
                                          //pop context
                                          Navigator.pop(context);
                                        },
                                        onChange: (input) {
                                          Provider.of<AppData>(context)
                                              .newDataInput = input;
                                        },
                                        cancelText: 'Cancel',
                                        hintText: null);
                                  });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.add,
                                  color: AppTextColor.dark,
                                  size: 25.0 *
                                      MediaQuery.of(context).size.width *
                                      kScaleFactor,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text(
                                  'Add New Collection',
                                  style: TextStyle(
                                      fontSize: AppTextSize.medium *
                                          MediaQuery.of(context).size.width,
                                      fontWeight: AppTextWeight.medium,
                                      color: AppTextColor.black),
                                ),
                              ],
                            ),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GroupHeader extends StatelessWidget {
  final bool connectionLibrary;
  final GroupData group;
  final ExpandableButton button;
  GroupHeader({
    @required this.connectionLibrary,
    @required this.group,
    @required this.button,
  });

  @override
  Widget build(BuildContext context) {
    return TileWhite(
      bottomPadding: 5.0,
      child: Padding(
        padding: EdgeInsets.all(14.0),
        child: GestureDetector(
          onLongPress: () {
            if (connectionLibrary == false)
              showDialog(
                  context: context,
                  builder: (context) {
                    return DialogScreenInput(
                        title: 'Rename Group',
                        acceptText: 'Accept',
                        acceptOnPress: () {
                          //create map to upload
                          Map data = CloudDB.updatePairFull(
                              key: GroupKeys.name,
                              value:
                                  Provider.of<AppData>(context).newDataInput);
                          //upload data to db
                          Provider.of<CloudDB>(context)
                              .updateDocumentInCollection(
                                  data: data,
                                  collection: DBFolder.groups,
                                  documentName: group.id);
                          //pop context
                          Navigator.pop(context);
                        },
                        onChange: (input) {
                          Provider.of<AppData>(context).newDataInput = input;
                        },
                        cancelText: 'Cancel',
                        hintText: null);
                  });
          },
          child: Column(
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  if (connectionLibrary == false)
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return DialogColorPicker(
                          title: 'Pick a Colour',
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          groupID: group.id,
                        );
                      },
                    );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    SizedBox(
                      width: 10.0 *
                          MediaQuery.of(context).size.width *
                          kScaleFactor,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                        group.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.fade,
                        style: TextStyle(
                          fontSize: AppTextSize.huge *
                              MediaQuery.of(context).size.width,
                          fontWeight: AppTextWeight.medium,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.0 *
                          MediaQuery.of(context).size.width *
                          kScaleFactor,
                    ),
                    Container(
                        width: 30.0 *
                            MediaQuery.of(context).size.width *
                            kScaleFactor,
                        child: button),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
