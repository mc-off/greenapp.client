import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:greenapp/models/task.dart';
import 'package:greenapp/pages/task_creation.dart';
import 'package:greenapp/pages/task_item.dart';
import 'package:greenapp/pages/task_list.dart';

import 'package:greenapp/services/task/base_task_provider.dart';
import 'package:greenapp/utils/styles.dart';
import 'package:greenapp/widgets/placeholder_content.dart';

class TasksCompletedPage extends StatefulWidget {
  TasksCompletedPage({this.baseTaskProvider});

  @required
  final BaseTaskProvider baseTaskProvider;

  @override
  _TasksCompletedPageState createState() => _TasksCompletedPageState();
}

class _TasksCompletedPageState extends State<TasksCompletedPage> {
  TaskStatus segmentValue = TaskStatus.COMPLETED;

  @override
  Widget build(BuildContext context) {
    return new CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("Purchased items"),
        ),
        child: SafeArea(
            child: Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: FutureBuilder(
                    future: widget.baseTaskProvider.getTaskList(
                        null,
                        segmentValue,
                        null,
                        widget.baseTaskProvider.getUserId(),
                        100),
                    builder: (context, projectSnapshot) {
                      debugPrint(
                          EnumToString.parse(projectSnapshot.connectionState));
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
                          {
                            return projectSnapshot.data.length == 0
                                ? _noItemOnServer()
                                : TaskList(
                                    baseTaskProvider: widget.baseTaskProvider,
                                    taskList: projectSnapshot.data,
                                    taskStatus: segmentValue,
                                    updateCallback: update,
                                  );
                          }
                        default:
                          return _showCircularProgress();
                      }
                    }))));
  }

  _tryAgainButtonClick(bool _) => setState(() {
        _showCircularProgress();
      });

  Widget _showCircularProgress() {
    return Center(child: CupertinoActivityIndicator());
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

  void closePage() {
    Navigator.pop(context);
  }

  void update() {
    debugPrint("Update page");
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    Navigator.pop(context);
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final Container _tabBar;

  @override
  double get minExtent => _tabBar.constraints.constrainHeight();
  @override
  double get maxExtent => _tabBar.constraints.constrainHeight();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return true;
  }
}
