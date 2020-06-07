import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:greenapp/models/task.dart';
import 'package:greenapp/services/base_task_provider.dart';
import 'package:greenapp/utils/converters.dart';

class MapTab extends StatefulWidget {
  MapTab({this.baseTaskProvider});

  final BaseTaskProvider baseTaskProvider;

  @override
  _MapTabState createState() {
    return _MapTabState();
  }
}

class _MapTabState extends State<MapTab> {
  GoogleMapController mapController;
  BitmapDescriptor myIcon =
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan);

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
    final taskList = await widget.baseTaskProvider.getTasks();
    _markers.clear();
    for (final task in taskList) {
      //final coordinates = LatLng(Random.secure().nextDouble(), Random.secure().nextDouble());
      var icon = await getMarkerMapIcon(task.type);
      final marker = Marker(
        markerId: MarkerId(task.id.toString()),
        position: LatLng(task.coordinate.latitude, task.coordinate.longitude),
        icon: icon,
        infoWindow: InfoWindow(
          title: task.title,
          snippet: task.description,
          onTap: _onMarkerTapped,
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
        return Converters.getMarkerIcon();
    }
  }
}
