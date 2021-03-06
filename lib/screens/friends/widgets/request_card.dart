import 'package:flutter/material.dart';
import 'package:plant_collector/formats/colors.dart';
import 'package:plant_collector/formats/text.dart';
import 'package:plant_collector/models/cloud_db.dart';
import 'package:plant_collector/models/data_storage/firebase_folders.dart';
import 'package:plant_collector/models/data_types/user_data.dart';
import 'package:plant_collector/widgets/dialogs/dialog_confirm.dart';
import 'package:plant_collector/widgets/tile_user.dart';
import 'package:provider/provider.dart';

class RequestCard extends StatelessWidget {
  final UserData user;
  RequestCard({@required this.user});
  @override
  Widget build(BuildContext context) {
    return UserTile(
      user: user,
      buttonRow: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return DialogConfirm(
                    title: 'Remove Request',
                    text: 'Are you sure you would like to remove this request?',
                    buttonText: 'Remove',
                    onPressed: () {
                      Provider.of<CloudDB>(context)
                          .removeConnectionRequest(connectionID: user.id);
                      //delete the document generated when the initial request was sent
                      CloudDB.deleteDocumentL1(
                          collection: DBDocument.conversations,
                          document: Provider.of<CloudDB>(context)
                              .conversationDocumentName(connectionId: user.id));
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
            child: Icon(
              Icons.delete,
              size: AppTextSize.large * MediaQuery.of(context).size.width,
              color: kGreenMedium,
            ),
          ),
          SizedBox(width: AppTextSize.huge * MediaQuery.of(context).size.width),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return DialogConfirm(
                    title: 'Add Connection',
                    text:
                        'Are you sure you would like to accept this request?  \n\n'
                        'After accepting, you will be able to view each other\'s plant libraries and chat.',
                    buttonText: 'ADD',
                    onPressed: () {
                      Provider.of<CloudDB>(context)
                          .acceptConnectionRequest(connectionID: user.id);
                      Navigator.pop(context);
                    },
                  );
                },
              );
            },
            child: Icon(
              Icons.check_box,
              size: AppTextSize.large * MediaQuery.of(context).size.width,
              color: kGreenDark,
            ),
          ),
        ],
      ),
    );
  }
}
