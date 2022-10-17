import 'package:flutter/material.dart';

import 'package:story_view/story_view.dart';
import 'package:whatsapp_flutter_ui/common/widgets/loader.dart';
import 'package:whatsapp_flutter_ui/models/status_model.dart';

class StatusScreen extends StatefulWidget {
  // ignore: constant_identifier_names
  static const String RouteName = '/status-screen';
  final StatusModel status;
  const StatusScreen({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  _StatusScreenState createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  StoryController controller = StoryController();
  List<StoryItem> storyItems = [];

  @override
  void initState() {
    super.initState();

    initStoryPageItems();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void initStoryPageItems() {
    for (var i = 0; i < widget.status.photoUrl.length; i++) {
      storyItems.add(
        StoryItem.pageImage(
          url: widget.status.photoUrl[i],
          controller: controller,
        ),
      );
    }
    print(storyItems.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Title'),
      ),
      body: storyItems.isEmpty
          ? const Loader()
          : StoryView(
              storyItems: storyItems,
              controller: controller,
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Navigator.pop(context);
                }
              },
            ),
    );
  }
}
