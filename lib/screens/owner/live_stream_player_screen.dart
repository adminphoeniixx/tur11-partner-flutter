import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../theme/app_theme.dart';

class LiveStreamPlayerScreen extends StatefulWidget {
  final String streamUrl;
  final String title;

  const LiveStreamPlayerScreen({
    super.key,
    required this.streamUrl,
    this.title = 'Live Stream',
  });

  static String normalizeStreamUrl(String value) {
    final text = value.trim();
    if (text.isEmpty) return '';

    final uri = Uri.tryParse(text);
    if (uri != null && uri.hasScheme) return text;

    final isMuxPlaybackId = RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(text);
    if (isMuxPlaybackId) return 'https://stream.mux.com/$text.m3u8';

    return text;
  }

  @override
  State<LiveStreamPlayerScreen> createState() => _LiveStreamPlayerScreenState();
}

class _LiveStreamPlayerScreenState extends State<LiveStreamPlayerScreen> {
  VideoPlayerController? _controller;
  Future<void>? _initializeFuture;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeFuture = _connect();
  }

  @override
  void dispose() {
    _controller?.removeListener(_onPlayerChanged);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final oldController = _controller;
    oldController?.removeListener(_onPlayerChanged);
    final streamUrl = LiveStreamPlayerScreen.normalizeStreamUrl(widget.streamUrl);
    final streamUri = Uri.tryParse(streamUrl);

    if (streamUri == null || !streamUri.hasScheme) {
      setState(() {
        _errorMessage = 'Invalid live stream URL.';
        _controller = null;
      });
      await oldController?.dispose();
      return;
    }

    final controller = VideoPlayerController.networkUrl(
      streamUri,
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    setState(() {
      _errorMessage = null;
      _controller = controller;
    });

    await oldController?.dispose();
    controller.addListener(_onPlayerChanged);

    try {
      await controller.initialize();
      await controller.play();
      if (mounted) setState(() {});
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Live stream abhi available nahi hai.';
      });
    }
  }

  void _onPlayerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<void>(
                future: _initializeFuture,
                builder: (context, snapshot) {
                  if (_errorMessage != null) {
                    return _PlayerMessage(
                      icon: Icons.wifi_tethering_error_rounded,
                      message: _errorMessage!,
                    );
                  }

                  if (controller == null ||
                      snapshot.connectionState != ConnectionState.done ||
                      !controller.value.isInitialized) {
                    return const _PlayerMessage(
                      icon: Icons.live_tv_outlined,
                      message: 'Connecting live stream...',
                      loading: true,
                    );
                  }

                  return _liveVideo(controller);
                },
              ),
            ),
            _liveControls(),
          ],
        ),
      ),
    );
  }

  Widget _liveVideo(VideoPlayerController controller) {
    final aspectRatio = controller.value.aspectRatio <= 0
        ? 16 / 9
        : controller.value.aspectRatio;

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: aspectRatio,
            child: VideoPlayer(controller),
          ),
          Positioned(
            left: 12,
            top: 12,
            child: _LiveBadge(isBuffering: controller.value.isBuffering),
          ),
          if (controller.value.isBuffering)
            const CircularProgressIndicator(color: AppColors.greenBright),
        ],
      ),
    );
  }

  Widget _liveControls() {
    final controller = _controller;
    final isReady = controller?.value.isInitialized ?? false;
    final isPlaying = controller?.value.isPlaying ?? false;
    final isBuffering = controller?.value.isBuffering ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
      color: AppColors.dark,
      child: Row(
        children: [
          IconButton.filled(
            onPressed: isReady ? _togglePlayback : null,
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isBuffering
                      ? 'Buffering live stream'
                      : isPlaying
                          ? 'Live stream playing'
                          : 'Live stream paused',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  LiveStreamPlayerScreen.normalizeStreamUrl(widget.streamUrl),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white60, fontSize: 10),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Reconnect',
            onPressed: _reconnect,
            color: Colors.white,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null) return;

    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
    if (mounted) setState(() {});
  }

  Future<void> _reconnect() async {
    final initializeFuture = _connect();
    setState(() => _initializeFuture = initializeFuture);
  }
}

class _LiveBadge extends StatelessWidget {
  final bool isBuffering;

  const _LiveBadge({required this.isBuffering});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: isBuffering ? AppColors.amber : AppColors.red,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, color: Colors.white, size: 7),
          const SizedBox(width: 5),
          Text(
            isBuffering ? 'BUFFERING' : 'LIVE',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final bool loading;

  const _PlayerMessage({
    required this.icon,
    required this.message,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const CircularProgressIndicator(color: AppColors.greenBright)
            else
              Icon(icon, color: Colors.white70, size: 38),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
