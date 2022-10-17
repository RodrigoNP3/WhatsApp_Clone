import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerItem({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _VideoPlayerItemState createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late CachedVideoPlayerController videoPlayerController;
  bool isPlay = false;

  @override
  void initState() {
    super.initState();
    videoPlayerController = CachedVideoPlayerController.network(widget.videoUrl)
      ..initialize().then((value) {
        videoPlayerController.setVolume(1);
        videoPlayerController.setLooping(false);
      });
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          CachedVideoPlayer(videoPlayerController),
          Align(
            alignment: Alignment.center,
            child: IconButton(
                onPressed: () {
                  if (isPlay) {
                    videoPlayerController.pause();
                  } else {
                    videoPlayerController.play();
                  }
                  setState(() {
                    isPlay = !isPlay;
                  });
                },
                icon: Icon(isPlay ? Icons.pause_circle : Icons.play_circle)),
          ),
        ],
      ),
    );
  }
}
