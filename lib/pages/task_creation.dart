import 'dart:convert';
import 'dart:io';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' as material;
import 'package:greenapp/models/task.dart';
import 'package:greenapp/models/text-styles.dart';
import 'package:greenapp/pages/task_item.dart';
import 'package:greenapp/services/base_task_provider.dart';
import 'package:greenapp/utils/styles.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

enum _DoubleConstants {
  textFieldContainerHeight,
  textFieldContainerWidth,
  textFieldBorderWidth
}

extension _DoubleConstantsExtension on _DoubleConstants {
  double get value {
    switch (this) {
      case _DoubleConstants.textFieldContainerHeight:
        return 50.0;
      case _DoubleConstants.textFieldContainerWidth:
        return 80.0;
      case _DoubleConstants.textFieldBorderWidth:
        return 0.6;
      default:
        return null;
    }
  }
}

typedef void Task2VoidFunc(Task arg);

class TaskCreationPage extends StatefulWidget {
  TaskCreationPage({this.createCallback, this.baseTaskProvider});

  final Task2VoidFunc createCallback;
  final BaseTaskProvider baseTaskProvider;

  @override
  State<StatefulWidget> createState() => _TaskCreationPageState();
}

class _TaskCreationPageState extends State<TaskCreationPage> {
  Task task;
  List<Object> images = List<Object>();
  Future<File> _imageFile;
  final _formKey = new GlobalKey<FormState>();
  TextEditingController _reward = TextEditingController();
  TextEditingController _title = TextEditingController();
  TextEditingController _description = TextEditingController();
  TaskStatus _taskStatus;
  LocationResult _pickedLocation;

  TextEditingController _coordinateLong = TextEditingController();
  TextEditingController _coordinateLat = TextEditingController();
  TaskType _taskType = TaskType.PLANT;
  TextEditingController _updated = TextEditingController();
  TextEditingController _dueDate = TextEditingController();

  String _errorMessage;
  String _infoMessage;
  bool _isLoading;

  // Check if form is valid before perform login or signup

  String key() {
    return Platform.isIOS
        ? "AIzaSyB25b5sC-Et2B5rApo6wE3yZlPqhWVwVWQ"
        : "AIzaSyDx65oYo1gRAEH-BLwArqSQAVzrVCdp804";
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  void initState() {
    _errorMessage = "";
    _infoMessage = "";
    _isLoading = false;
    super.initState();
    images.add("Add image");
  }

  void resetForm() {
    _formKey.currentState.reset();
    _errorMessage = "";
    _infoMessage = "";
  }

  void createTask() async {
    setState(() {
      _errorMessage = "";
      _infoMessage = "";
      _isLoading = true;
    });
    try {
      final task = Task(
        title: _title.value.text,
        description: _description.value.text,
        coordinate: Coordinate(
            latitude: _pickedLocation.latLng.latitude,
            longitude: _pickedLocation.latLng.longitude),
        dueDate: "2020-12-03 10:15:30",
        type: _taskType,
        reward: int.parse(_reward.value.text),
      );
      debugPrint(json.encode(task).toString());
      final response = await widget.baseTaskProvider
          .createTask(images, task);
      if (response != null) {
        task.id = response;
        this.task = task;
        displayDialogSuccess(response);
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Create task"),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: createTask,
          child: const Icon(
            CupertinoIcons.check_mark,
            semanticLabel: 'VoteToCreate',
          ),
        ),
      ),
      child: Stack(
        children: <Widget>[
          SafeArea(
              child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: false,
            child: Container(
                padding: EdgeInsets.all(20),
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    _showSubTitle("Title:"),
                    _showTitleInput(),
                    _showSubTitle("Description:"),
                    _showDescriptionInput(),
                    _showSubTitle("Reward:"),
                    _showRewardInput(),
                    _showSubTitle("Location:"),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                        child: Row(
                          children: <Widget>[
                            Container(
                                width: 200,
                                child: Text((_pickedLocation != null)
                                    ? _pickedLocation.address.toString()
                                    : 'Location is empty')),
                            CupertinoButton(
                              onPressed: () async {
                                LocationResult result =
                                    await showLocationPicker(context, key(),
                                        initialCenter:
                                            LatLng(31.1975844, 29.9598339),
                                        automaticallyAnimateToCurrentLocation:
                                            false,
//                      mapStylePath: 'assets/mapStyle.json',
                                        myLocationButtonEnabled: true,
                                        layersButtonEnabled: true,
                                        resultCardPadding:
                                            EdgeInsets.only(bottom: 100.0)
//                      resultCardAlignment: Alignment.bottomCenter,
                                        );
                                print("result = $result");
                                setState(() => _pickedLocation = result);
                              },
                              child: Text('Pick location'),
                            ),
                          ],
                        )),
                    _showSubTitle("Type: (scroll it)"),
                    _dropDownList(),
                    _showSubTitle("Attachments:"),
                    _buildGridView()
                  ],
                )),
          )),
          _showCircularProgress()
        ],
      ),
    );
  }

  void closePage() {
    Navigator.pop(context);
  }

  void closePageAndOpenNewTask() {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => TaskItem(
                  baseTaskProvider: widget.baseTaskProvider,
                  task: task,
                ))).then((value) {
      Navigator.pop(context);
    });
  }

  @override
  void dispose() {
    super.dispose();
    Navigator.pop(context);
  }

  void displayDialogSuccess(int taskId) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: new Text("Info"),
        content: new Text("Task with num $taskId is created"),
        actions: [
          CupertinoDialogAction(
              isDefaultAction: true,
              child: new Text("Open created task"),
              onPressed: () {
                Navigator.pop(context, "Open created task");
                closePageAndOpenNewTask();
              }),
          CupertinoDialogAction(
              isDefaultAction: false,
              child: new Text("Close"),
              onPressed: () {
                Navigator.pop(context, "Close");
                closePage();
              })
        ],
      ),
    );
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CupertinoActivityIndicator());
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget _showSubTitle(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Text(
        '$text',
        style: Styles.body13RegularGray(),
      ),
    );
  }

  Widget _showTitleInput() {
    return new Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
      child: new CupertinoTextField(
        maxLines: 1,
        obscureText: false,
        autofocus: true,
        controller: _title,
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(
            width: _DoubleConstants.textFieldBorderWidth.value,
            color: CupertinoColors.separator,
          ),
          top: BorderSide(
            width: _DoubleConstants.textFieldBorderWidth.value,
            color: CupertinoColors.separator,
          ),
        )),
      ),
    );
  }

  Widget _showDescriptionInput() {
    return new Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
      child: new CupertinoTextField(
        maxLines: 10,
        obscureText: false,
        autofocus: true,
        controller: _description,
        style: Styles.body15Regular(),
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(
            width: _DoubleConstants.textFieldBorderWidth.value,
            color: CupertinoColors.separator,
          ),
          top: BorderSide(
            width: _DoubleConstants.textFieldBorderWidth.value,
            color: CupertinoColors.separator,
          ),
        )),
      ),
    );
  }

  Widget _showRewardInput() {
    return new Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
      child: new CupertinoTextField(
        maxLines: 1,
        obscureText: false,
        autofocus: true,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        controller: _reward,
        style: Styles.body17Medium(),
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(
            width: _DoubleConstants.textFieldBorderWidth.value,
            color: CupertinoColors.separator,
          ),
          top: BorderSide(
            width: _DoubleConstants.textFieldBorderWidth.value,
            color: CupertinoColors.separator,
          ),
        )),
      ),
    );
  }

  Widget showMainHint() {
    return new Container(
      height: 240,
      width: 200,
      child: Center(
        child: Text(
          "Enter code below:",
          style: TextStyles.largeTitleRegular(),
          //textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget showInfoMessage() {
    if (_infoMessage.length > 0 && _infoMessage != null) {
      return new CupertinoAlertDialog(
          content: Text(
        _infoMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: CupertinoColors.activeBlue,
            height: 1.0,
            fontWeight: FontWeight.bold),
      ));
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new CupertinoAlertDialog(
          content: Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: CupertinoColors.systemRed,
            height: 1.0,
            fontWeight: FontWeight.bold),
      ));
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _buildGridView() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1,
      children: List.generate(images.length, (index) {
        if (images[index] is File) {
          File imageFile = images[index];
          return material.Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: <Widget>[
                Image.file(
                  imageFile,
                  width: 300,
                  height: 300,
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: material.InkWell(
                    child: Icon(
                      material.Icons.remove_circle,
                      size: 20,
                      color: material.Colors.red,
                    ),
                    onTap: () {
                      setState(() {
                        images.replaceRange(index, index + 1, ['Add Image']);
                        images.removeLast();
                      });
                    },
                  ),
                ),
              ],
            ),
          );
        } else {
          return material.Card(
            child: material.IconButton(
              icon: Icon(material.Icons.add),
              onPressed: () {
                _onAddImageClick(index);
              },
            ),
          );
        }
      }),
    );
  }

  Future _onAddImageClick(int index) async {
    setState(() {
      _imageFile = ImagePicker.pickImage(source: ImageSource.gallery);
      getFileImage(index);
    });
  }

  void getFileImage(int index) async {
//    var dir = await path_provider.getTemporaryDirectory();

    _imageFile.then((file) async {
      setState(() {
        images.replaceRange(index, index + 1, [file]);
        images.add("Add Image");
      });
    });
  }

  Widget _dropDownList() {
    return Platform.isIOS
        ? CupertinoPicker(
            itemExtent: 50,
            onSelectedItemChanged: (int index) {
              setState(() {
                debugPrint(
                    "New type is ${EnumToString.parse(TaskType.values[index])}");
                _taskType = TaskType.values[index];
              });
            },
            children:
                new List<Widget>.generate(TaskType.values.length, (int index) {
              return new Center(
                child: new Text(EnumToString.parse(TaskType.values[index])),
              );
            }))
        : material.Card(
            child: material.DropdownButton<String>(
                value: EnumToString.parse(_taskType),
                items: List<String>.generate(TaskType.values.length,
                        (index) => EnumToString.parse(TaskType.values[index]))
                    .map((String value) {
                  return new material.DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
                onChanged: (String value) {
                  debugPrint("New type is");
                  debugPrint(value);
                  //debugPrint("New type is ${EnumToString.parse(value)}");
                  setState(() {
                    this._taskType =
                        EnumToString.fromString(TaskType.values, value);
                  });
                }));
  }
}
