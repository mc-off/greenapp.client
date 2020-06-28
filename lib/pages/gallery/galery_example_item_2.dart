import 'package:flutter/widgets.dart';

class GalleryExampleItem2 {
  GalleryExampleItem2({this.id, this.resource, this.isSvg = false});

  final String id;
  final String resource;
  final bool isSvg;
}

class GalleryExampleItemThumbnail2 extends StatelessWidget {
  const GalleryExampleItemThumbnail2(
      {Key key, this.galleryExampleItem, this.onTap})
      : super(key: key);

  final GalleryExampleItem2 galleryExampleItem;

  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: GestureDetector(
        onTap: onTap,
        child: Hero(
          tag: galleryExampleItem.id,
          child: Image.asset(galleryExampleItem.resource, height: 80.0),
        ),
      ),
    );
  }
}

List<GalleryExampleItem2> galleryItems = <GalleryExampleItem2>[
  GalleryExampleItem2(
    id: "tag1",
    resource: "assets/gallery1.jpg",
  ),
  GalleryExampleItem2(
    id: "tag2",
    resource: "assets/gallery2.jpg",
  ),
  GalleryExampleItem2(
    id: "tag3",
    resource: "assets/gallery3.jpg",
  ),
];
