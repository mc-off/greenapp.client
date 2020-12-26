import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cupertino_settings/flutter_cupertino_settings.dart';
import 'package:greenapp/models/profile.dart';
import 'package:greenapp/services/base_auth.dart';
import 'package:greenapp/services/base_task_provider.dart';
import 'package:greenapp/utils/styles.dart';
import 'package:greenapp/widgets/placeholder_content.dart';

const String address =
    "https://greenapp-client-provider.herokuapp.com/client-provider/client/";
const String addressAttach =
    "https://greenapp-client-provider.herokuapp.com/client-provider/attachment/";

class ProfileTab extends StatefulWidget {
  ProfileTab(
      {this.userId, this.auth, this.logoutCallback, this.baseTaskProvider});

  final String userId;
  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final BaseTaskProvider baseTaskProvider;

  @override
  _ProfileTabState createState() {
    return _ProfileTabState();
  }
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isEditEnabled = false;
  TextEditingController _name = TextEditingController();
  TextEditingController _surname = TextEditingController();
  TextEditingController _description = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(semanticChildCount: 1, slivers: <Widget>[
      const CupertinoSliverNavigationBar(
        largeTitle: Text('Profile'),
      ),
      SliverList(
        delegate: SliverChildListDelegate(
          [
            Container(
              height: 90,
              child: FutureBuilder(
                  future: getProfile(),
                  builder: (BuildContext context,
                      AsyncSnapshot<Profile> projectSnapshot) {
                    if (projectSnapshot.hasError)
                      return PlaceHolderContent(
                        title: "Problem Occurred",
                        message: "Internet not connect try again",
                        tryAgainButton: _tryAgainButtonClick,
                      );
                    debugPrint(
                        EnumToString.parse(projectSnapshot.connectionState));
                    switch (projectSnapshot.connectionState) {
                      case ConnectionState.waiting:
                        return _showCircularProgress();
                      case ConnectionState.done:
                        _name.text = projectSnapshot.data.name !=null ? projectSnapshot.data.name : '';
                        _description.text = projectSnapshot.data.description !=null ? projectSnapshot.data.description : '';
                        return Row(
                          children: <Widget>[
                            Padding(
                        padding: const EdgeInsets.fromLTRB(
                            16, 12, 0 , 12),
                            child: ClipOval(
                              child: (projectSnapshot.data.attachmentId != null)
                                  ? Image(
                                      image: NetworkImage(
                                        addressAttach +
                                            projectSnapshot.data.attachmentId
                                                .toString(),
                                        headers: <String, String>{
                                          'Authorization':
                                              widget.baseTaskProvider.getAuth(),
                                          'X-GREEN-APP-ID': "GREEN"
                                        },
                                      ),
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.cover,
                                    )
                                  : Image(
                                      image: AssetImage("assets/no_image_available.png"),
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                            )),
                            Expanded(
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Column(
                                      children: <Widget>[
                                        // _showSubTitle("Name"),
                                        _showNameInput(),
                                        // _showSubTitle("Surname"),
                                        // _showSurnameInput(),
                                        //_showSubTitle("Description"),
                                        _showDescriptionInput(),
                                      ],
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                    )))
                          ],
                        );
                      default:
                        return _showCircularProgress();
                    }
                  }),
            ),
            Row(children: <Widget>[ClipOval()]),
            const CSHeader('Session'),
            CSButton(CSButtonType.DESTRUCTIVE, "Sign out", () {
              signOut();
            })
          ],
        ),
      ),
    ]);
  }

  _tryAgainButtonClick(bool _) => setState(() {
        _showCircularProgress();
      });

  Widget _showCircularProgress() {
    return Center(child: CupertinoActivityIndicator());
  }

  Future<Profile> getProfile() async {
    debugPrint("Get PROFILE");
    Dio dio = new Dio();
    dio.options.headers["Authorization"] = widget.baseTaskProvider.getAuth();
    dio.options.headers["x-green-app-id"] = "GREEN";
    Response response =
        await dio.get("$address${widget.baseTaskProvider.getUserId()}");
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      debugPrint("PROFILE GETTER OK");
      debugPrint(response.statusCode.toString());

      Profile profile = Profile.fromJson(response.data);
      debugPrint(profile.toJson().toString());
      return profile;
    } else {
      // If the server did no
      //t return a 201 CREATED response,
      // then throw an exception
      debugPrint("PROFILE GETTER ERROR");
      debugPrint(response.statusCode.toString());
      debugPrint(response.data.toString());
      if (response.statusCode == 401) widget.logoutCallback();
      throw Exception('Failed to parse tasks');
    }
  }

  Widget _showSubTitle(String text) {
    return Container(
      alignment: Alignment.centerLeft,
        child: Padding(
      padding: EdgeInsets.only(top: 10),
      child: Text(
        '$text',
        style: Styles.body13RegularGray(),
      ),
        ));
  }

  Widget _showNameInput() {
    return new Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
      child: new CupertinoTextField(
        maxLines: 1,
        obscureText: false,
        autofocus: false,
        decoration: null,
        enabled: _isEditEnabled,
        controller: _name,
        style: Styles.body17Medium(),
        placeholder: 'No value for name',
      ),
    );
  }

  Widget _showSurnameInput() {
    return new Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
      child: new CupertinoTextField(
        maxLines: 1,
        obscureText: false,
        autofocus: false,
        enabled: _isEditEnabled,
        controller: _surname,
      ),
    );
  }

  Widget _showDescriptionInput() {
    return new Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
      child: new CupertinoTextField(
        maxLines: 1,
        obscureText: false,
        autofocus: false,
        decoration: null,
        style: Styles.body13RegularGray(),
        enabled: _isEditEnabled,
        controller: _description,
        placeholder: 'No value for description',
      ),
    );
  }

  signOut() async {
    try {
      widget.logoutCallback();
    } catch (e) {
      print(e);
    }
  }
}

CSWidgetStyle brightnessStyle = const CSWidgetStyle(
    icon: const Icon(CupertinoIcons.brightness_solid,
        color: CupertinoColors.black));
