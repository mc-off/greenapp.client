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

import 'package:flutter/cupertino.dart';
import 'package:greenapp/models/task.dart';
import 'package:greenapp/utils/styles.dart';

class TaskRowItem extends StatelessWidget {
  const TaskRowItem({
    this.task,
  });

  final Task task;

  @override
  Widget build(BuildContext context) {
    final row = SafeArea(
        top: false,
        bottom: false,
        minimum: const EdgeInsets.only(
          left: 8,
          top: 8,
          bottom: 0,
          right: 8,
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: CupertinoColors.systemGrey.withOpacity(0.1),
                spreadRadius: 3,
                blurRadius: 3,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          task.title,
                          style: Styles.body17Medium(),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 8)),
                        Text(
                          '${task.description}',
                          style: Styles.body15Regular(),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 8)),
                        RichText(
                          text: TextSpan(
                              text: '${task.reward}',
                              style: Styles.taskPrice(),
                              children: <TextSpan>[
                                TextSpan(
                                    text: ' points',
                                    style: Styles.taskPriceSecond())
                              ]),
                        ),
                      ]),
                ),
              ),
              ClipRRect(
                  child: Image(
                height: 70,
                width: 70,
                image: AssetImage('assets/Pin.png'),
              ))
            ],
          ),
        ));

    return Column(
      children: <Widget>[
        row,
      ],
    );
  }
}
