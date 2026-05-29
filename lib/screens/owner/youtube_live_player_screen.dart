import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../theme/app_theme.dart';

class YouTubeLivePlayerScreen extends StatefulWidget {
  final String url;
  final String title;

  const YouTubeLivePlayerScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<YouTubeLivePlayerScreen> createState() =>
      _YouTubeLivePlayerScreenState();
}

class _YouTubeLivePlayerScreenState extends State<YouTubeLivePlayerScreen> {
  static const String _embedOrigin =
      'https://ai-turf11-laravel.rmsiry.easypanel.host';
  static const String _demoVideoId = 'iLnmTe5Q2Qw';
  static const List<String> _fallbackVideoIds = [
    _demoVideoId,
    'M7lc1UVf-VE',
    'nPt8bK2gbaU',
  ];

  late final WebViewController _controller;
  final Set<String> _triedVideoIds = {};
  late String _activeVideoId;
  int _progress = 0;
  String? _message;

  @override
  void initState() {
    super.initState();
    _activeVideoId = _videoIdFromUrl(widget.url) ?? _demoVideoId;
    _triedVideoIds.add(_activeVideoId);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) return;
            setState(() => _progress = progress);
          },
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _progress = 0;
              _message = null;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _progress = 100);
          },
          onWebResourceError: _onWebResourceError,
          onNavigationRequest: _onNavigationRequest,
        ),
      )
      ..loadRequest(
        _embedUri(_activeVideoId),
        headers: _embedHeaders,
      );
  }

  void _onWebResourceError(WebResourceError error) {
    if (error.isForMainFrame == false || !mounted) return;

    if (_loadNextFallback()) return;

    setState(() {
      _progress = 100;
      _message =
          'YouTube player load nahi ho pa raha. Network, VPN, Private DNS, device date/time, Chrome/System WebView check karein.';
    });
  }

  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri == null) return NavigationDecision.prevent;

    final host = uri.host.toLowerCase();
    final isAllowed = host == 'youtube.com' ||
        host == 'www.youtube.com' ||
        host == 'm.youtube.com' ||
        host == 'youtube-nocookie.com' ||
        host.endsWith('.youtube-nocookie.com') ||
        host == 'googleads.g.doubleclick.net' ||
        host.endsWith('.googlevideo.com') ||
        host.endsWith('.ytimg.com') ||
        host.endsWith('.google.com') ||
        host.endsWith('.gstatic.com');

    return isAllowed ? NavigationDecision.navigate : NavigationDecision.prevent;
  }

  bool _loadNextFallback() {
    for (final videoId in _fallbackVideoIds) {
      if (_triedVideoIds.contains(videoId)) continue;
      _triedVideoIds.add(videoId);
      _activeVideoId = videoId;
      _controller.loadRequest(
        _embedUri(videoId),
        headers: _embedHeaders,
      );
      return true;
    }
    return false;
  }

  void _retry() {
    setState(() {
      _progress = 0;
      _message = null;
    });
    _controller.loadRequest(
      _embedUri(_activeVideoId),
      headers: _embedHeaders,
    );
  }

  Future<void> _openExternally() async {
    final uri = Uri.parse(_watchUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Open in YouTube',
            onPressed: _openExternally,
            icon: const Icon(Icons.open_in_new),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: WebViewWidget(controller: _controller),
                    ),
                  ),
                  if (_progress < 100 && _message == null)
                    const CircularProgressIndicator(
                      color: AppColors.greenBright,
                    ),
                  if (_message != null)
                    Positioned.fill(
                      child: ColoredBox(
                        color: Colors.black,
                        child: _YouTubeMessage(
                          message: _message!,
                          onRetry: _retry,
                          onOpenExternal: _openExternally,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _footer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
      color: AppColors.dark,
      child: Row(
        children: [
          const Icon(Icons.live_tv, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _watchUrl,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _watchUrl => 'https://www.youtube.com/watch?v=$_activeVideoId';
}

Uri _embedUri(String videoId) {
  return Uri.https('www.youtube.com', '/embed/$videoId', const {
    'playsinline': '1',
    'rel': '0',
    'modestbranding': '1',
    'enablejsapi': '1',
    'origin': _YouTubeLivePlayerScreenState._embedOrigin,
  });
}

const Map<String, String> _embedHeaders = {
  'Referer': '${_YouTubeLivePlayerScreenState._embedOrigin}/',
  'Origin': _YouTubeLivePlayerScreenState._embedOrigin,
};

String? _videoIdFromUrl(String value) {
  final text = value.trim();
  if (text.isEmpty) return null;
  if (RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(text)) return text;

  final uri = Uri.tryParse(text);
  if (uri == null) return null;

  final host = uri.host.toLowerCase();
  final segments = uri.pathSegments;

  if (host == 'youtu.be' || host == 'www.youtu.be') {
    return _validVideoId(segments.isEmpty ? null : segments.first);
  }

  final watchId = _validVideoId(uri.queryParameters['v']);
  if (watchId != null) return watchId;

  for (final key in ['embed', 'shorts', 'live']) {
    final index = segments.indexOf(key);
    if (index != -1 && segments.length > index + 1) {
      final id = _validVideoId(segments[index + 1]);
      if (id != null) return id;
    }
  }

  return null;
}

String? _validVideoId(String? value) {
  if (value == null) return null;
  return RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(value) ? value : null;
}

class _YouTubeMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final VoidCallback onOpenExternal;

  const _YouTubeMessage({
    required this.message,
    required this.onRetry,
    required this.onOpenExternal,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white70, size: 38),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onOpenExternal,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open in YouTube'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
