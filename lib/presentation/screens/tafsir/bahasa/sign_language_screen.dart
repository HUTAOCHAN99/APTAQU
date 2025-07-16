import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:al_quran/core/api/sign_language_service.dart';

class SignLanguageScreen extends StatefulWidget {
  final int surahNumber;
  final int ayahNumber;
  final TafsirType tafsirType;

  const SignLanguageScreen({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
    this.tafsirType = TafsirType.bahasa,
  });

  @override
  State<SignLanguageScreen> createState() => _SignLanguageScreenState();
}

class _SignLanguageScreenState extends State<SignLanguageScreen> {
  ChewieController? _chewieController;
  VideoPlayerController? _videoController;
  bool _isLoading = true;
  bool _hasError = false;
  DateTime? _lastRetryTime;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Dispose previous controllers
      _videoController?.dispose();
      _chewieController?.dispose();

      // Get video URL
      final url = await SignLanguageService().getTafsirVideoUrl(
        surahNumber: widget.surahNumber,
        ayahNumber: widget.ayahNumber,
        tafsirType: widget.tafsirType,
      );

      if (url == null) {
        throw Exception('Video URL not found');
      }

      // Initialize video controller
      _videoController = VideoPlayerController.network(url)
        ..addListener(_videoStateListener);

      await _videoController!.initialize();

      // Initialize Chewie controller
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        errorBuilder: (context, errorMessage) {
          return _buildErrorPlaceholder(errorMessage);
        },
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.green,
          handleColor: Colors.greenAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey[300]!,
        ),
      );

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Video initialization error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _videoStateListener() {
    if (_videoController?.value.hasError ?? false) {
      if (mounted) {
        setState(() => _hasError = true);
      }
    }
  }

  void _retryLoading() {
    final now = DateTime.now();
    if (_lastRetryTime != null &&
        now.difference(_lastRetryTime!) < const Duration(seconds: 2)) {
      return;
    }
    _lastRetryTime = now;
    _initializeVideo();
  }

  Widget _buildErrorPlaceholder([String? errorMessage]) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam_off, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Video Tidak Tersedia',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Surah ${widget.surahNumber} Ayat ${widget.ayahNumber}',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              'Error: ${errorMessage.replaceAll('Exception: ', '')}',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _retryLoading,
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError || _chewieController == null) {
      return _buildErrorPlaceholder();
    }

    return AspectRatio(
      aspectRatio: _videoController!.value.aspectRatio,
      child: Chewie(controller: _chewieController!),
    );
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoStateListener);
    _videoController?.pause();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tafsir Bahasa Isyarat - Surah ${widget.surahNumber}:${widget.ayahNumber}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _retryLoading,
            tooltip: 'Muat Ulang',
          ),
        ],
      ),
      body: _buildVideoContent(),
    );
  }
}
