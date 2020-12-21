import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenapp/models/text-styles.dart';
import 'package:greenapp/models/unit.dart';
import 'package:greenapp/pages/gallery/gallery_example.dart';
import 'package:greenapp/services/base_auth.dart';
import 'package:greenapp/utils/styles.dart';
import 'package:greenapp/widgets/placeholder_content.dart';
import 'package:http/http.dart' as http;

class MarketTab extends StatefulWidget {
  MarketTab({this.baseAuth, this.logoutCallback});

  @required
  final BaseAuth baseAuth;
  final VoidCallback logoutCallback;

  @override
  _MarketTabState createState() {
    return _MarketTabState();
  }
}

class _MarketTabState extends State<MarketTab> {
  @override
  Widget build(BuildContext context) {
    return new NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            CupertinoSliverNavigationBar(
              largeTitle: Text('Market'),
            )
          ];
        },
        body: FutureBuilder(
            future: getUnitList(),
            builder: (context, projectSnapshot) {
              debugPrint(EnumToString.parse(projectSnapshot.connectionState));
              if (projectSnapshot.hasError)
                return PlaceHolderContent(
                  title: "Problem Occurred",
                  message: "Internet not connect try again",
                  tryAgainButton: _tryAgainButtonClick,
                );
              switch (projectSnapshot.connectionState) {
                case ConnectionState.waiting:
                  return _showCircularProgress();
                case ConnectionState.done:
                  return Container(
                    child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        removeBottom: false,
                        child: projectSnapshot.data.length == 0
                            ? _noItemOnServer()
                            : ListView.builder(
                                itemCount: projectSnapshot.data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return new GestureDetector(
                                      //You need to make my child interactive
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) => UnitItem(
                                                      unit: projectSnapshot
                                                          .data[index],
                                                    )));
                                      },
                                      child: new UnitRowItem(
                                          isLastIndex: index ==
                                              projectSnapshot.data.length,
                                          unit: projectSnapshot.data[index]));
                                },
                              )),
                    color: CupertinoColors.systemBackground,
                  );
                default:
                  return _showCircularProgress();
              }
            }));
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

  Future<List<Unit>> getUnitList() async {
    final token = await widget.baseAuth.getCurrentUser();
    debugPrint(token.toString());
    debugPrint("getTasksList");
    http.Response response = await http.get(
      "https://greenapp-gateway.herokuapp.com/shop/load/all",
      headers: <String, String>{
        'Authorization': "Bearer " + token.toString(),
        'Content-type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      final t = json.decode(response.body);
      List<Unit> unitList = [];
      for (Map i in t) {
        unitList.add(Unit.fromJson(i));
      }

      return unitList;
    } else {
      // If the server did no
      //t return a 201 CREATED response,
      // then throw an exception
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      if (response.statusCode == 401) widget.logoutCallback();
      throw Exception('Failed to parse tasks');
    }
  }
}

class UnitRowItem extends StatelessWidget {
  const UnitRowItem({
    this.isLastIndex,
    this.unit,
  });

  final Unit unit;
  final bool isLastIndex;

  @override
  Widget build(BuildContext context) {
    final row = SafeArea(
        top: false,
        bottom: false,
        minimum: const EdgeInsets.only(
          left: 16,
          top: 8,
          bottom: 8,
          right: 8,
        ),
        child: Container(
          child: Row(
            children: <Widget>[
              ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image(
                    image: NetworkImage("https://picsum.photos/id/1025/100"),
                    height: 70,
                    width: 70,
                  )),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        unit.title,
                        style: Styles.body17Regular(),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 2)),
                      Text(
                        '\$${unit.description}',
                        style: Styles.body13RegularGray(),
                      ),
                      const Padding(padding: EdgeInsets.only(top: 8)),
                      Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.lightBackgroundGray,
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(30, 6, 30, 6),
                            child: Text(
                              unit.price.toString(),
                              style: Styles.taskPrice(),
                            ),
                          ))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));

    return Column(
      children: <Widget>[
        row,
        isLastIndex
            ? Padding(
                padding: const EdgeInsets.only(
                  left: 100,
                  right: 16,
                ),
                child: Container(
                  height: 1,
                  color: TextStyles.productRowDivider,
                ),
              )
            : Container()
      ],
    );
  }
}

class UnitItem extends StatefulWidget {
  const UnitItem({
    this.unit,
  });

  final Unit unit;

  @override
  _UnitItemState createState() => _UnitItemState();
}

class _UnitItemState extends State<UnitItem> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: new NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          CupertinoSliverNavigationBar(
            largeTitle: Text('Unit'),
          )
        ];
      },
      body: Container(
          child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              removeBottom: false,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  _showTitle(),
                  _showSubTitle(),
                  _showDescription(),
                  _showGaleryHint(),
                  _showGallery(),
                  _shoButton()
                ],
              ))),
    ));
  }

  Widget _showTitle() {
    return Padding(
      padding: EdgeInsets.only(left: 20, top: 8),
      child: Text(
        '${widget.unit.title}',
        style: Styles.body17Medium(),
      ),
    );
  }

  Widget _showSubTitle() {
    return Padding(
      padding: EdgeInsets.only(top: 3, left: 20),
      child: Text(
        '${widget.unit.description}',
        style: Styles.body15Regular(),
      ),
    );
  }

  Widget _showDescription() {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 20),
      child: Text(
        '${widget.unit.createdBy}',
        style: Styles.body15RegularGray(),
      ),
    );
  }

  Widget _shoButton() {
    return Padding(
        padding: EdgeInsets.fromLTRB(40.0, 30.0, 40.0, 0.0),
        child: SizedBox(
          height: 50.0,
          child: new CupertinoButton.filled(
            disabledColor: CupertinoColors.quaternarySystemFill,
            pressedOpacity: 0.4,
            borderRadius: const BorderRadius.all(Radius.circular(8.0)),
            child: new Text('Buy for ${widget.unit.price}',
                style: new TextStyle(
                    fontSize: 18.0, color: CupertinoColors.white)),
            onPressed: testRequest,
          ),
        ));
  }

  Widget _showGaleryHint() {
    return Padding(
      padding: EdgeInsets.only(top: 20, left: 20),
      child: Text(
        'Attachments (demo)',
        style: Styles.body17Medium(),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _showGallery() {
    return Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0), child: GalleryExample());
  }

  int getPicNumber() {}

  void testRequest() {}
}
