import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greenapp/pages/gallery/gallery_example_item.dart';
import 'package:greenapp/services/task/base_task_provider.dart';
import 'package:greenapp/utils/styles.dart';
import 'package:greenapp/widgets/placeholder_content.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class GalleryExample extends StatefulWidget {
  final BaseTaskProvider baseTaskProvider;
  final List<int> attachArray;

  const GalleryExample({this.baseTaskProvider, this.attachArray});

  @override
  State<StatefulWidget> createState() => _GalleryExampleState();
}

class _GalleryExampleState extends State<GalleryExample> {
  bool verticalGallery = false;
  List<GalleryExampleItem> galleryItems = [];

  @override
  void initState() {
    initList();
    super.initState();
  }

  initList() {
    debugPrint(widget.attachArray.length.toString());
    debugPrint(widget.baseTaskProvider.getToken());
    for (int i in widget.attachArray) {
      galleryItems.add(GalleryExampleItem(
          id: i,
          resource: <String, String>{
            'Authorization': widget.baseTaskProvider.getToken(),
            'X-GREEN-APP-ID': "GREEN"
          },
          isSvg: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0),
      height: 300.0,
      child: ListView(
          scrollDirection: Axis.horizontal,
          children: List<Widget>.generate(galleryItems.length, (int index) {
            return new Center(
              child: new GalleryExampleItemThumbnail(
                galleryExampleItem: galleryItems[index],
                onTap: () {
                  open(context, index);
                },
              ),
            );
          })),
    );
  }

  Widget _noItemOnServer() {
    debugPrint("No items displayed");
    return Center(
      child: Text(
        'Where is not any items on server',
        style: Styles.body15Regular(),
        textAlign: TextAlign.center,
      ),
    );
  }

  _tryAgainButtonClick(bool _) => setState(() {
        _showCircularProgress();
      });

  Widget _showCircularProgress() {
    return Center(child: CupertinoActivityIndicator());
  }

  void open(BuildContext context, final int index) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => GalleryPhotoViewWrapper(
          galleryItems: galleryItems,
          backgroundDecoration: const BoxDecoration(
            color: CupertinoColors.black,
          ),
          initialIndex: index,
          scrollDirection: verticalGallery ? Axis.vertical : Axis.horizontal,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}

class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper({
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialIndex,
    @required this.galleryItems,
    this.scrollDirection = Axis.horizontal,
  }) : pageController = PageController(initialPage: initialIndex);

  final LoadingBuilder loadingBuilder;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;
  final List<GalleryExampleItem> galleryItems;
  final Axis scrollDirection;

  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  int currentIndex;

  @override
  void initState() {
    currentIndex = widget.initialIndex;
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    Navigator.pop(context);
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    dispose();
    return true;
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.black,
        leading: GestureDetector(
          child: Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: Text(
              "Close",
              style: TextStyle(
                color: CupertinoColors.white,
                fontSize: 18.0,
              ),
            ),
          ),
          onTap: () {
            dispose();
          },
        ),
        middle: Text(
          "Image ${currentIndex + 1}",
          style: const TextStyle(
            color: CupertinoColors.white,
            fontSize: 17.0,
            decoration: null,
          ),
        ),
      ),
      child: Container(
        decoration: widget.backgroundDecoration,
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          children: <Widget>[
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: _buildItem,
              itemCount: widget.galleryItems.length,
              loadingBuilder: widget.loadingBuilder,
              backgroundDecoration: widget.backgroundDecoration,
              pageController: widget.pageController,
              onPageChanged: onPageChanged,
              scrollDirection: widget.scrollDirection,
            ),
          ],
        ),
      ),
    );
  }

  PhotoViewGalleryPageOptions _buildItem(BuildContext context, int index) {
    final GalleryExampleItem item = widget.galleryItems[index];
    return PhotoViewGalleryPageOptions(
        imageProvider:
            NetworkImage(address + item.id.toString(), headers: item.resource),
        initialScale: PhotoViewComputedScale.contained,
        minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
        maxScale: PhotoViewComputedScale.covered * 1.1,
        heroAttributes: PhotoViewHeroAttributes(tag: item.id),
        gestureDetectorBehavior: HitTestBehavior.translucent);
  }
}
