import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:greenapp/models/app_state_model.dart';

class TasksTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: const <Widget>[
        CupertinoSliverNavigationBar(
          largeTitle: Text('Tasks'),
        ),
      ],
    );
  }
}
