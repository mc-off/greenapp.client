import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:greenapp/models/task.dart';
import 'package:greenapp/pages/task_creation.dart';
import 'package:greenapp/pages/task_item.dart';
import 'package:greenapp/pages/task_list.dart';

import 'package:greenapp/services/task/base_task_provider.dart';
import 'package:greenapp/utils/styles.dart';
import 'package:greenapp/widgets/placeholder_content.dart';

class TasksVotePage extends StatefulWidget {
  TasksVotePage({this.baseTaskProvider});

  @required
  final BaseTaskProvider baseTaskProvider;

  @override
  _TasksVotePageState createState() => _TasksVotePageState();
}

class _TasksVotePageState extends State<TasksVotePage> {
  int theriGroupVakue = 0;

  TaskStatus segmentValue = TaskStatus.WAITING_FOR_APPROVE;

  final Map<int, Widget> logoWidgets = const <int, Widget>{
    0: Text("Creation"),
    1: Text("Validation"),
  };

  @override
  Widget build(BuildContext context) {
    return new CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text("Vote list"),
        ),
        child: SafeArea(
            child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate(Container(
                          height: 50,
                          color: CupertinoColors.systemBackground,
                          child: Center(
                              child: Row(
                            children: <Widget>[
                              SizedBox(
                                width: 15.0,
                              ),
                              Expanded(
                                child: CupertinoSegmentedControl(
                                  groupValue: theriGroupVakue,
                                  onValueChanged: (int changeFromGroupValue) {
                                    setState(() {
                                      theriGroupVakue = changeFromGroupValue;
                                      switch (changeFromGroupValue) {
                                        case 0:
                                          segmentValue =
                                              TaskStatus.WAITING_FOR_APPROVE;
                                          break;
                                        case 1:
                                          segmentValue = TaskStatus.RESOLVED;
                                          break;
                                        default:
                                          segmentValue =
                                              TaskStatus.WAITING_FOR_APPROVE;
                                          break;
                                      }
                                    });
                                  },
                                  children: logoWidgets,
                                ),
                              ),
                              SizedBox(
                                width: 15.0,
                              ),
                            ],
                          )))),
                      pinned: true,
                      floating: false,
                    ),
                  ];
                },
                body: Padding(
                    padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
                    child: FutureBuilder(
                        future: widget.baseTaskProvider
                            .getTaskList(null, segmentValue, null, null, 10),
                        builder: (context, projectSnapshot) {
                          debugPrint(EnumToString.parse(
                              projectSnapshot.connectionState));
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
                                        baseTaskProvider:
                                            widget.baseTaskProvider,
                                        taskList: projectSnapshot.data,
                                        taskStatus: segmentValue,
                                        updateCallback: update,
                                      );
                              }
                            default:
                              return _showCircularProgress();
                          }
                        })))));
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
