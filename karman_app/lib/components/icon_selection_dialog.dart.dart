// contains icons to select from for folders
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IconSelectionDialog extends StatelessWidget {
  final Function(IconData) onIconSelected;

  const IconSelectionDialog({Key? key, required this.onIconSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<IconData> icons = [
      CupertinoIcons.folder,
      CupertinoIcons.star,
      CupertinoIcons.heart,
      CupertinoIcons.flag,
      CupertinoIcons.bell,
      CupertinoIcons.calendar,
      CupertinoIcons.clock,
      CupertinoIcons.tag,
      CupertinoIcons.person,
      CupertinoIcons.speedometer,
      CupertinoIcons.bolt,
      CupertinoIcons.briefcase,
      CupertinoIcons.cart,
      CupertinoIcons.book,
      CupertinoIcons.macwindow,
      CupertinoIcons.phone,
      CupertinoIcons.home,
      CupertinoIcons.mail,
      CupertinoIcons.photo,
      CupertinoIcons.camera,
      CupertinoIcons.music_note,
      CupertinoIcons.game_controller,
      CupertinoIcons.bookmark,
      CupertinoIcons.cloud,
      CupertinoIcons.sun_max,
      CupertinoIcons.device_laptop,
      CupertinoIcons.device_phone_portrait,
      CupertinoIcons.device_desktop,
      CupertinoIcons.building_2_fill,
    ];

    return CupertinoAlertDialog(
      title: Text('Select Folder Icon'),
      content: Container(
        height: 200,
        width: 300,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: icons.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                onIconSelected(icons[index]);
                Navigator.of(context).pop();
              },
              child: Icon(
                icons[index],
                color: Colors.white,
                size: 30,
              ),
            );
          },
        ),
      ),
    );
  }
}
