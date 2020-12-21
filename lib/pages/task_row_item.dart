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
import 'package:greenapp/models/text-styles.dart';

class TaskRowItem extends StatelessWidget {
  const TaskRowItem({
    this.index,
    this.task,
  });

  final Task task;
  final int index;

  @override
  Widget build(BuildContext context) {
    final row = Container(
      child: Row(
        children: <Widget>[
          ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Text(task.id.toString())),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    task.description,
                    style: TextStyles.productRowItemName,
                  ),
                  const Padding(padding: EdgeInsets.only(top: 8)),
                  Text(
                    '\$${task.reward}',
                    style: TextStyles.productRowItemPrice,
                  )
                ],
              ),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              debugPrint("Button on item ${task.id.toString()} pressed");
            },
            child: const Icon(
              CupertinoIcons.plus_circled,
              semanticLabel: 'Add',
            ),
          ),
        ],
      ),
    );

    return Column(
      children: <Widget>[
        row,
        Padding(
          padding: const EdgeInsets.only(
            left: 100,
            right: 16,
          ),
          child: Container(
            height: 1,
            color: TextStyles.productRowDivider,
          ),
        ),
      ],
    );
  }
}
