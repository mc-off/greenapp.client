// Copyright 2019 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenapp/models/task.dart';
import 'package:greenapp/pages/gallery/gallery_example.dart';
import 'package:greenapp/pages/gallery/gallery_example_item.dart';
import 'package:greenapp/services/base_task_provider.dart';
import 'package:greenapp/utils/styles.dart';
import 'package:greenapp/widgets/placeholder_content.dart';
import 'package:image_picker/image_picker.dart';

class TaskItem extends StatefulWidget {
  const TaskItem({
    this.baseTaskProvider,
    this.task,
    this.updateCallback,
  });
  final BaseTaskProvider baseTaskProvider;
  final VoidCallback updateCallback;
  final Task task;

  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool isEditable = false;

  @override
  void initState() {
    super.initState();
    if (widget.task.status == TaskStatus.IN_PROGRESS) isEditable = true;
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

  void update() {
    setState(() {});
  }

  final buttonWidget = <Widget>[
    CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        debugPrint("Check TODO clicked");
      },
      child: const Icon(
        CupertinoIcons.pencil,
        semanticLabel: 'VoteToDo',
      ),
    ),
    Container()
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: new NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                CupertinoSliverNavigationBar(
                  leading: CupertinoNavigationBarBackButton(
                    onPressed: () {
                      close();
                    },
                  ),
                  largeTitle: Text('Task'),
                  trailing: (widget.task.status == TaskStatus.IN_PROGRESS)
                      ? buttonWidget[0]
                      : buttonWidget[1],
                )
              ];
            },
            body: FutureBuilder<Task>(
                future: widget.baseTaskProvider.getTask(widget.task.id),
                builder: (context, projectSnapshot) {
                  debugPrint(
                      EnumToString.parse(projectSnapshot.connectionState));
                  switch (projectSnapshot.connectionState) {
                    case ConnectionState.waiting:
                      return _showCircularProgress();
                    case ConnectionState.done:
                      {
                        debugPrint(projectSnapshot.data.assignee.toString());
                        debugPrint(
                            widget.baseTaskProvider.getUserId().toString());

                        isEditable = (projectSnapshot.data.assignee != null &&
                            projectSnapshot.data.assignee ==
                                widget.baseTaskProvider.getUserId());
                        return TaskItemPage(
                          task: projectSnapshot.data,
                          baseTaskProvider: widget.baseTaskProvider,
                          isEditable: isEditable,
                          callback: displayDialog,
                        );
                      }
                    default:
                      return _showCircularProgress();
                  }
                })));
  }

  _tryAgainButtonClick(bool _) => setState(() {
        _showCircularProgress();
      });

  void close() {
    Navigator.pop(context);
    widget.updateCallback();
  }

  Widget _showCircularProgress() {
    return Center(child: CupertinoActivityIndicator());
  }

  void displayDialog() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => new CupertinoAlertDialog(
        title: new Text("Info"),
        content: new Text("Task was updated"),
        actions: [
          CupertinoDialogAction(
              isDefaultAction: true,
              child: new Text("Close"),
              onPressed: () {
                Navigator.pop(context, "Close");
                setState(() {});
              })
        ],
      ),
    );
  }
}

class TaskItemPage extends StatefulWidget {
  final Task task;
  final BaseTaskProvider baseTaskProvider;
  final bool isEditable;
  final VoidCallback callback;

  const TaskItemPage(
      {Key key,
      this.task,
      this.baseTaskProvider,
      this.isEditable,
      this.callback})
      : super(key: key);

  @override
  _TaskItemPageState createState() => _TaskItemPageState();
}

class _TaskItemPageState extends State<TaskItemPage> {
  List<Object> images = List<Object>();
  Future<File> _imageFile;

  @override
  void initState() {
    images.add("Add image");
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    dispose();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: false,
        child: Container(
            child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                removeBottom: false,
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    _showTitle(),
                    _showSubTitle(),
                    _showAssignee(),
                    _showDescription(),
                    _shoButton(),
                    if (_isAttachExists()) _showGaleryHint(),
                    if (_isAttachExists()) _showGallery(),
                    if (widget.isEditable) _showAttachHint(),
                    if (widget.isEditable) _buildGridView()
                  ],
                ))),
      ),
    );
  }

  Widget _showTitle() {
    return Padding(
      padding: EdgeInsets.only(left: 20, top: 8),
      child: Text(
        '${widget.task.title}' + ' ID:' + '${widget.task.id}',
        style: Styles.body17Medium(),
      ),
    );
  }

  Widget _showSubTitle() {
    return Padding(
      padding: EdgeInsets.only(top: 3, left: 20),
      child: Text(
        '${widget.task.address}',
        style: Styles.body15Regular(),
      ),
    );
  }

  Widget _showDescription() {
    return Padding(
      padding: EdgeInsets.only(top: 10, left: 20),
      child: Text(
        widget.task.description != null
            ? '${widget.task.description}'
            : 'Description is empty',
        style: Styles.body15RegularGray(),
      ),
    );
  }

  Widget _showAssignee() {
    return (widget.task.assignee != null)
        ? Padding(
            padding: EdgeInsets.only(top: 3, left: 20),
            child: Text('${widget.task.assignee}',
                style: Styles.body15RegularGray()),
          )
        : Container();
  }

  Widget _showGaleryHint() {
    return Padding(
      padding: EdgeInsets.only(top: 20, left: 20),
      child: Text(
        'Pictures ',
        style: Styles.body17Medium(),
        textAlign: TextAlign.left,
      ),
    );
  }

  Widget _showAttachHint() {
    return Padding(
      padding: EdgeInsets.only(top: 20, left: 20),
      child: Text(
        'Attachments (new)',
        style: Styles.body17Medium(),
        textAlign: TextAlign.left,
      ),
    );
  }

  bool _isAttachExists() {
    return (widget.task.attachmentIds != null &&
        widget.task.attachmentIds.length != 0);
  }

  Widget _showGallery() {
    return Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: GalleryExample(
          baseTaskProvider: widget.baseTaskProvider,
          attachArray: widget.task.attachmentIds,
        ));
  }

  Widget _shoButton() {
    if (widget.task.status == TaskStatus.CREATED) {
      return Padding(
          padding: EdgeInsets.fromLTRB(40.0, 30.0, 40.0, 0.0),
          child: SizedBox(
            height: widget.isEditable ? 50.0 : 70.0,
            child: new CupertinoButton.filled(
              disabledColor: CupertinoColors.quaternarySystemFill,
              pressedOpacity: 0.4,
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              child: new Text(getButtonName(),
                  style: new TextStyle(
                      fontSize: 18.0, color: CupertinoColors.white)),
              onPressed: () {
                testUpdateTaskAttach(images);
              },
            ),
          ));
    } else if (widget.task.status == TaskStatus.WAITING_FOR_APPROVE ||
        widget.task.status == TaskStatus.RESOLVED)
      return Padding(
          padding: EdgeInsets.fromLTRB(40.0, 30.0, 40.0, 0.0),
          child: SizedBox(
              height: 50.0,
              child: Center(
                  child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      final t = await widget.baseTaskProvider
                          .voteForTask(widget.task, VoteChoice.REJECT);
                      if (t) {
                        widget.callback();
                      }
                    },
                    child: const Icon(
                      Icons.favorite_border,
                      semanticLabel: 'VoteNo',
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      final t = await widget.baseTaskProvider
                          .voteForTask(widget.task, VoteChoice.APPROVE);
                      if (t) {
                        widget.callback();
                      }
                    },
                    child: const Icon(
                      Icons.favorite,
                      semanticLabel: 'VoteYes',
                    ),
                  ),
                ],
              ))));
    else
      return Container();
  }

  String getButtonName() {
    switch (widget.isEditable) {
      case false:
        return "Get task for ${widget.task.reward} credits";
      case true:
        return "Approve task";
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
          return Card(
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
                  child: InkWell(
                    child: Icon(
                      Icons.remove_circle,
                      size: 20,
                      color: Colors.red,
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
          return Card(
            child: IconButton(
              icon: Icon(Icons.add),
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

  void testUpdateTaskAttach(List<Object> files) async {
    debugPrint("Perform update");
    final bool isSuccess = await widget.baseTaskProvider
        .updateTaskWithAttachments(files, widget.task);
    if (isSuccess) {
      widget.callback();
    }
  }
}
