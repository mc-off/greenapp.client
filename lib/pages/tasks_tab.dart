import 'dart:convert';

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greenapp/models/task.dart';
import 'package:greenapp/pages/task_creation.dart';
import 'package:greenapp/pages/task_item.dart';
import 'package:greenapp/pages/task_list.dart';
import 'package:greenapp/pages/tasks_vote_page.dart';

import 'package:greenapp/services/task/base_task_provider.dart';
import 'package:greenapp/utils/styles.dart';
import 'package:greenapp/widgets/placeholder_content.dart';
import 'package:http/http.dart' as http;

final int INITIAL_ID_FOR_TASKS = 990;

class TasksTab extends StatefulWidget {
  TasksTab({this.baseTaskProvider});

  @required
  final BaseTaskProvider baseTaskProvider;

  @override
  _TasksTabState createState() {
    return _TasksTabState();
  }
}

class _TasksTabState extends State<TasksTab> {
  int theriGroupVakue = 0;
  TaskStatus segmentValue = TaskStatus.TO_DO;

  final Map<int, Widget> logoWidgets = const <int, Widget>{
    0: Text("Available"),
    1: Text("Assigned"),
  };

//  final buttonWidget = <Widget>[
//    CupertinoButton(
//      padding: EdgeInsets.zero,
//      onPressed: () {
//        showCupertinoModalPopup(
//          context: context,
//          builder: (BuildContext context) => CupertinoActionSheet(
//              title: const Text('Choose Options'),
//              message: const Text('Your options are '),
//              actions: <Widget>[
//                CupertinoActionSheetAction(
//                  child: const Text('One'),
//                  onPressed: () {
//                    Navigator.pop(context, 'One');
//                  },
//                ),
//                CupertinoActionSheetAction(
//                  child: const Text('Two'),
//                  onPressed: () {
//                    Navigator.pop(context, 'Two');
//                  },
//                )
//              ],
//              cancelButton: CupertinoActionSheetAction(
//                child: const Text('Cancel'),
//                isDefaultAction: true,
//                onPressed: () {
//                  Navigator.pop(context, 'Cancel');
//                },
//              )),
//        );
//      },
//      child: const Icon(
//        CupertinoIcons.check_mark_circled,
//        semanticLabel: 'VoteToDo',
//      ),
//    ),
//    CupertinoButton(
//      padding: EdgeInsets.zero,
//      onPressed: () {
//        debugPrint("Check resolve clicked");
//      },
//      child: const Icon(
//        CupertinoIcons.check_mark_circled,
//        semanticLabel: 'VoteResolve',
//      ),
//    ),
//  ];

  @override
  Widget build(BuildContext context) {
    return new NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            CupertinoSliverNavigationBar(
              largeTitle: Text('Tasks'),
              leading: GestureDetector(
                child: Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Add",
                    style: TextStyle(
                      color: CupertinoColors.activeBlue,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => TaskCreationPage(
                                baseTaskProvider: widget.baseTaskProvider,
                                createCallback: openCreatedTask,
                              )));
                },
              ),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext context) => CupertinoActionSheet(
                        title: const Text('Extra features'),
                        message: const Text('Your options are'),
                        actions: <Widget>[
                          CupertinoActionSheetAction(
                            child: const Text('Get task by id DEMO'),
                            onPressed: () {
                              Navigator.pop(context, 'Get task by id DEMO');
                            },
                          ),
                          CupertinoActionSheetAction(
                            child: const Text('Vote for tasks'),
                            onPressed: () {
                              Navigator.pop(context, 'Vote for tasks');
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => TasksVotePage(
                                            baseTaskProvider:
                                                widget.baseTaskProvider,
                                          )));
                            },
                          )
                        ],
                        cancelButton: CupertinoActionSheetAction(
                          child: const Text('Cancel'),
                          isDefaultAction: true,
                          onPressed: () {
                            Navigator.pop(context, 'Cancel');
                          },
                        )),
                  );
                },
                child: const Icon(
                  CupertinoIcons.ellipsis,
                  semanticLabel: 'VoteToDo',
                ),
              ),
            ),
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
                                  segmentValue = TaskStatus.TO_DO;
                                  break;
                                case 1:
                                  segmentValue = TaskStatus.IN_PROGRESS;
                                  break;
                                default:
                                  segmentValue = TaskStatus.TO_DO;
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
            ),
          ];
        },
        body: FutureBuilder(
            future: widget.baseTaskProvider
                .getTaskList(null, segmentValue, null, null, 10),
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
            }));
  }

  void update() {
    debugPrint("Update page");
    setState(() {});
  }

  void openCreatedTask(Task task) {
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => TaskItem(
                  baseTaskProvider: widget.baseTaskProvider,
                  task: task,
                )));
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
