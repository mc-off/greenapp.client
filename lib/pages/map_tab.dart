import 'dart:convert';
import 'dart:math';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greenapp/models/task.dart';
import 'package:greenapp/utils/converters.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:greenapp/models/app_state_model.dart';

class MapTab extends StatefulWidget {
  @override
  _MapTabState createState() {
    return _MapTabState();
  }
}

class _MapTabState extends State<MapTab> {
  GoogleMapController mapController;
  BitmapDescriptor myIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);

  final LatLng _center = const LatLng(45.521563, -122.677433);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GoogleMap(
        onMapCreated: _onMapCreated,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: true,
        initialCameraPosition: CameraPosition(
          target: const LatLng(60, 50),
          zoom: 2,
        ),
        markers: _markers.values.toSet(),
      ),
    );
  }

  Future<List<Task>> _getTasks() async {
    var uri = Uri.https(
        'greenapp-task-provider.herokuapp.com', '/task-provider/tasks');
    http.Response response = await http.post(
      "https://greenapp-task-provider.herokuapp.com/task-provider/tasks",
      headers: <String, String>{
        'Content-type': 'application/json',
        'X-GREEN-APP-ID': 'GREEN',
      },
      body: json.encode({
        'status': EnumToString.parse(TaskStatus.CREATED),
      }),
    );
    if (response.statusCode == 200) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      final t = json.decode(response.body);
      List<Task> taskList = [];
      for (Map i in t) {
        taskList.add(Task.fromJson(i));
      }
      return taskList;
    } else {
      // If the server did no
      //t return a 201 CREATED response,
      // then throw an exception
      debugPrint(response.statusCode.toString());
      debugPrint(response.body.toString());
      throw Exception('Failed to parse tasks');
    }
  }

  void _onMarkerTapped() {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(
                    middle: Text("Task page"),
                  ),
                  child: Center(
                    child: Text("test"),
                  ),
                )));
  }

  Map<String, Marker> _markers = {};

  Future<void> _onMapCreated(GoogleMapController controller) async {
    final googleOffices = await _getTasks();
    _markers.clear();
    for (final office in googleOffices) {
      //final coordinates = LatLng(Random.secure().nextDouble(), Random.secure().nextDouble());
      var icon = await getMarkerMapIcon(office.type);
      final marker = Marker(
        markerId: MarkerId(office.id.toString()),
        position:
            LatLng(office.coordinate.latitude, office.coordinate.longitude),
        icon: icon,
        infoWindow: InfoWindow(
          title: office.title,
          snippet: office.description,
          onTap: _onMarkerTapped,
        ),
      );
      debugPrint(office.toString());
      _markers[office.id.toString()] = marker;
    }
    setState(() {
      this._markers = _markers;
    });
  }

  Future<BitmapDescriptor> getMarkerMapIcon(TaskType taskType) async {
    switch (taskType) {
      case TaskType.PLANT:
//        return BitmapDescriptor.fromAssetImage(
//            ImageConfiguration(size: Size(48, 48)),
//            'packages/shrine_images/0-0.jpg');
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      case TaskType.URBAN:
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueMagenta);
      case TaskType.ANIMAL:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      case TaskType.PEOPLE:
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet);
      case TaskType.ENVIRONMENT:
        return BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueYellow);
      default:
        return Converters.getMarkerIcon();
    }
  }
}
