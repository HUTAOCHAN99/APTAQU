import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SignLanguageVideo extends StatefulWidget {
  final String videoUrl;
  
  const SignLanguageVideo({super.key, required this.videoUrl});

  @override
  State<SignLanguageVideo> createState() => _SignLanguageVideoState();
}

class _SignLanguageVideoState extends State<SignLanguageVideo> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.network(widget.videoUrl);
    await _controller.initialize();
    
    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: _controller,
        autoPlay: true,
        looping: false,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _chewieController != null
        ? Chewie(controller: _chewieController!)
        : const Center(child: CircularProgressIndicator());
  }
}