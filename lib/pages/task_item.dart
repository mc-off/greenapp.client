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

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:greenapp/models/task.dart';
import 'package:greenapp/pages/gallery/gallery_example.dart';
import 'package:greenapp/services/base_task_provider.dart';
import 'package:greenapp/utils/styles.dart';
import 'package:greenapp/widgets/placeholder_content.dart';

class TaskItem extends StatefulWidget {
  const TaskItem({
    this.baseTaskProvider,
    this.task,
  });
  final BaseTaskProvider baseTaskProvider;
  final Task task;

  @override
  _TaskItemState createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    Navigator.pop(context);
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
    dispose();
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        child: new NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                CupertinoSliverNavigationBar(
                  largeTitle: Text('Task'),
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
                      return taskItemPage(
                        task: widget.task,
                        taskItemCallback: testRequest,
                      );
                    default:
                      return _showCircularProgress();
                  }
                })));
  }

  _tryAgainButtonClick(bool _) => setState(() {
        _showCircularProgress();
      });

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
          CupertinoDialogAction(isDefaultAction: true, child: new Text("Close"))
        ],
      ),
    );
  }

  void testRequest() async {
    final bool isSuccess =
        await widget.baseTaskProvider.updateTask(widget.task);
    if (isSuccess) {
      setState(() {});
    }
  }
}

class taskItemPage extends StatefulWidget {
  final Task task;
  final VoidCallback taskItemCallback;

  const taskItemPage({Key key, this.task, this.taskItemCallback})
      : super(key: key);

  @override
  _taskItemPageState createState() => _taskItemPageState();
}

class _taskItemPageState extends State<taskItemPage> {
  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent) {
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
                    _showGaleryHint(),
                    _showGallery(),
                  ],
                ))),
      ),
    );
  }

  Widget _showTitle() {
    return Padding(
      padding: EdgeInsets.only(left: 20, top: 8),
      child: Text(
        '${widget.task.title}',
        style: Styles.body17Medium(),
      ),
    );
  }

  Widget _showSubTitle() {
    return Padding(
      padding: EdgeInsets.only(top: 3, left: 20),
      child: Text(
        '${widget.task.coordinate}',
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
            child: Text('${widget.task.description}',
                style: Styles.body15RegularGray()),
          )
        : Container();
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

  Widget _shoButton() {
    if (widget.task.status == TaskStatus.CREATED ||
        widget.task.status == TaskStatus.IN_PROGRESS) {
      return Padding(
          padding: EdgeInsets.fromLTRB(40.0, 30.0, 40.0, 0.0),
          child: SizedBox(
            height: 50.0,
            child: new CupertinoButton.filled(
              disabledColor: CupertinoColors.quaternarySystemFill,
              pressedOpacity: 0.4,
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              child: new Text(getButtonName(),
                  style: new TextStyle(
                      fontSize: 18.0, color: CupertinoColors.white)),
              onPressed: () {
                widget.taskItemCallback();
              },
            ),
          ));
    } else
      return Container();
  }

  String getButtonName() {
    switch (widget.task.status) {
      case TaskStatus.CREATED:
        return "Get task for ${widget.task.reward} credits";
      case TaskStatus.IN_PROGRESS:
        return "Approve task";
    }
  }
}
