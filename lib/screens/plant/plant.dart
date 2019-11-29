import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:plant_collector/models/constants.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:plant_collector/screens/plant/widgets/action_button.dart';
import 'package:plant_collector/widgets/container_wrapper.dart';
import 'package:plant_collector/widgets/dialogs/dialog_confirm.dart';
import 'package:provider/provider.dart';
import 'package:plant_collector/models/cloud_db.dart';
import 'package:plant_collector/models/builders_general.dart';
import 'package:plant_collector/formats/text.dart';
import 'package:plant_collector/formats/colors.dart';
import 'package:share/share.dart';

class PlantScreen extends StatelessWidget {
  final bool connectionLibrary;
  final String forwardingCollectionID;
  final String plantID;
  PlantScreen(
      {@required this.connectionLibrary,
      @required this.plantID,
      @required this.forwardingCollectionID});
  @override
  Widget build(BuildContext context) {
    return StreamProvider<DocumentSnapshot>.value(
      value: Provider.of<CloudDB>(context).streamPlant(
          userID: connectionLibrary == false
              ? Provider.of<CloudDB>(context).currentUserFolder
              : Provider.of<CloudDB>(context).connectionUserFolder,
          plantID: plantID),
      child: Scaffold(
        backgroundColor: kGreenLight,
        appBar: AppBar(
          backgroundColor: kGreenDark,
          centerTitle: true,
          elevation: 20.0,
          title: Text(
            '',
            style: kAppBarTitle,
          ),
        ),
        body: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Consumer<DocumentSnapshot>(
                builder: (context, DocumentSnapshot plantData, _) {
                  //after the first image has been taken, this will be rebuilt
                  if (plantData != null) {
                    Map plantMap = plantData.data;
                    List<Widget> items = Provider.of<UIBuilders>(context)
                        .generateImageTileWidgets(
                      connectionLibrary: connectionLibrary,
                      plantID: plantID,
                      thumbnail:
                          plantMap != null ? plantMap[kPlantThumbnail] : null,
                      //the below check is necessary for deleting a plant via the button on plant screen
                      listURL:
                          plantMap != null ? plantMap[kPlantImageList] : null,
                    );
                    return items.length >= 1
                        ? CarouselSlider(
                            items: items,
                            initialPage: 0,
                            height: MediaQuery.of(context).size.width * 0.96,
                            viewportFraction: 0.94,
                            enableInfiniteScroll: false,
                          )
                        : SizedBox();
                  } else {
                    return SizedBox();
                  }
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.03),
              child: Consumer<DocumentSnapshot>(
                builder: (context, DocumentSnapshot plantSnap, _) {
                  if (plantSnap != null) {
                    Map plantMap = plantSnap.data;
                    return ContainerWrapper(
                      child: Provider.of<UIBuilders>(context).displayInfoCards(
                        connectionLibrary: connectionLibrary,
                        plantID: plantID,
                        plant: plantMap,
                      ),
                    );
                  } else {
                    return SizedBox();
                  }
                },
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                connectionLibrary == false
                    ? ActionButton(
                        icon: Icons.delete_forever,
                        action: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return DialogConfirm(
                                  title: 'Confirm Plant Removal',
                                  text:
                                      'Are you sure you would like to delete this plant, it\'s photos, and all related information?  '
                                      '\n\nThis cannot be undone!',
                                  buttonText: 'Delete Forever',
                                  onPressed: () {
                                    //pop dialog
                                    Navigator.pop(context);
                                    //remove plant reference from collection
                                    Provider.of<CloudDB>(context)
                                        .updateArrayInDocumentInCollection(
                                            arrayKey: kCollectionPlantList,
                                            entries: [plantID],
                                            folder: kUserCollections,
                                            documentName:
                                                forwardingCollectionID,
                                            action: false);
                                    //delete plant
                                    Provider.of<CloudDB>(context)
                                        .deleteDocumentFromCollection(
                                            documentID: plantID,
                                            collection: kUserPlants);
                                    //pop old plant profile
                                    Navigator.pop(context);
                                    //NOTE: deletion of images is handled by a DB function
                                  });
                            },
                          );
                        },
                      )
                    : SizedBox(),
                SizedBox(height: 10),
                connectionLibrary == false
                    ? Consumer<DocumentSnapshot>(
                        builder: (context, DocumentSnapshot plantSnap, _) {
                          return ActionButton(
                            icon: Icons.share,
                            action: () {
                              Share.share(
                                Provider.of<UIBuilders>(context)
                                    .sharePlant(plantMap: plantSnap.data),
                                subject:
                                    'Check out this plant via Plant Collector!',
                              );
                            },
                          );
                        },
                      )
                    : SizedBox(),
              ],
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
