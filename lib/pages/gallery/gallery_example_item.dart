import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:greenapp/services/base_task_provider.dart';
import 'package:greenapp/services/task_provider.dart';

const String address =
    "https://greenapp-gateway.herokuapp.com/task-provider/attachment/";

class GalleryExampleItem {
  GalleryExampleItem({this.id, this.resource, this.isSvg = false});

  final int id;
  final Map<String, String> resource;
  final bool isSvg;
}

class GalleryExampleItemThumbnail extends StatelessWidget {
  const GalleryExampleItemThumbnail(
      {Key key, this.galleryExampleItem, this.onTap})
      : super(key: key);

  final GalleryExampleItem galleryExampleItem;

  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: GestureDetector(
        onTap: onTap,
        child: Hero(
          tag: galleryExampleItem.id,
          child: Image(
              image: NetworkImage(address + galleryExampleItem.id.toString(),
                  headers: galleryExampleItem.resource),
              height: 260.0),
        ),
      ),
    );
  }
}
