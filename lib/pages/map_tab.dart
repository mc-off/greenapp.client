import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greenapp/models/task.dart';
import 'package:greenapp/pages/task_item.dart';
import 'package:greenapp/services/base_task_provider.dart';
import 'package:greenapp/utils/converters.dart';
import 'package:location/location.dart';

final int INITIAL_ID_FOR_TASKS = 0;

class MapTab extends StatefulWidget {
  MapTab({this.baseTaskProvider});

  @required
  final BaseTaskProvider baseTaskProvider;

  @override
  _MapTabState createState() {
    return _MapTabState();
  }
}

class _MapTabState extends State<MapTab> {
  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Circle circle;
  Marker marker;
  GoogleMapController mapController;
  BitmapDescriptor myIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    super.dispose();
  }

  void updateMarkerAndCircle(LocationData newLocalData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    setState(() {
      circle = Circle(
          circleId: CircleId("car"),
          radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
    });
  }

  void getCurrentLocation() async {
    try {
      debugPrint('Im here');
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      _locationSubscription =
          _locationTracker.onLocationChanged().listen((newLocalData) {
        if (mapController != null) {
          mapController.animateCamera(CameraUpdate.newCameraPosition(
              new CameraPosition(
                  bearing: 192.8334901395799,
                  target: LatLng(newLocalData.latitude, newLocalData.longitude),
                  tilt: 1,
                  zoom: 18.00)));
          updateMarkerAndCircle(newLocalData);
        }
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      bottom: true,
      child: GoogleMap(
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        compassEnabled: true,
        onCameraMoveStarted: getCurrentLocation,
        onMapCreated: _onMapCreated,
        zoomControlsEnabled: true,
        circles: Set.of((circle != null) ? [circle] : []),
        initialCameraPosition: CameraPosition(
          target: const LatLng(60, 50),
          zoom: 1,
        ),
        markers: _markers.values.toSet(),
      ),
    );
  }

  Map<String, Marker> _markers = {};

  Future<void> _onMapCreated(GoogleMapController controller) async {
    final taskList =
        await widget.baseTaskProvider.getTasksNum(INITIAL_ID_FOR_TASKS, 300);
    _markers.clear();
    getCurrentLocation();
    for (final task in taskList) {
      //final coordinates = LatLng(Random.secure().nextDouble(), Random.secure().nextDouble());
      var icon = await getMarkerMapIcon(task.type);
      final marker = Marker(
        markerId: MarkerId(task.id.toString()),
        position: LatLng(task.coordinate.latitude, task.coordinate.longitude),
        icon: icon,
        infoWindow: InfoWindow(
          title: task.title,
          snippet: task.reward.toString(),
          onTap: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => TaskItem(
                          baseTaskProvider: widget.baseTaskProvider,
                          task: task,
                        )));
          },
        ),
      );
      debugPrint(task.toString());
      _markers[task.id.toString()] = marker;
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
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
    }
  }
}
