import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../models/live_event.dart';

/// Wrapper around [Chewie] / [VideoPlayerController] for a live or replay
/// stream. For the mock, we just use a sample video URL if none is provided.
class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({super.key, required this.event});

  final LiveEvent event;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitializing = true;
  String? _error;

  /// Returns a reliable web-compatible video URL for demo purposes
  String _getFallbackVideoUrl() {
    // Use a known working video URL that supports CORS and is web-compatible
    return 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4';
  }

  /// Checks if a URL is valid and not a placeholder
  bool _isValidVideoUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    // Check if it's not an example/placeholder URL
    if (url.contains('example.com')) return false;
    // Check if it's a valid HTTP/HTTPS URL
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      // Get the video URL, prioritizing streamUrl, then replayUrl, then fallback
      String? url = widget.event.streamUrl;
      if (!_isValidVideoUrl(url)) {
        url = widget.event.replayUrl;
      }
      if (!_isValidVideoUrl(url)) {
        url = _getFallbackVideoUrl();
      }

      if (url == null || url.isEmpty) {
        throw Exception('Aucune URL vidéo disponible');
      }

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: {
          // Add headers for better compatibility
          'User-Agent': 'Mozilla/5.0',
        },
      );

      // Set a timeout for initialization
      await controller.initialize().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          controller.dispose();
          throw Exception('Timeout: La vidéo met trop de temps à charger');
        },
      );

      // Check if widget is still mounted before proceeding
      if (!mounted) {
        controller.dispose();
        return;
      }

      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: !kIsWeb, // Don't autoplay on web due to browser restrictions
        looping: true,
        allowFullScreen: true,
        allowMuting: true,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Erreur de lecture vidéo',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );

      // Check again before setState
      if (mounted) {
        setState(() {
          _videoController = controller;
          _chewieController = chewie;
          _isInitializing = false;
        });
      } else {
        // Widget was disposed, clean up
        chewie.dispose();
        controller.dispose();
      }
    } catch (e) {
      // Check if widget is still mounted before setState
      if (mounted) {
        // Clean up any partial controller
        _videoController?.dispose();
        _videoController = null;

        setState(() {
          _error = _getErrorMessage(e);
          _isInitializing = false;
        });
      }
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('src not supported') ||
        errorString.contains('format not supported') ||
        errorString.contains('media_err_src_not_supported')) {
      return 'Format vidéo non supporté par le navigateur.\nEssayez un autre navigateur ou une autre vidéo.';
    }
    
    if (errorString.contains('network') || errorString.contains('timeout')) {
      return 'Erreur réseau: Impossible de charger la vidéo.\nVérifiez votre connexion internet.';
    }
    
    if (errorString.contains('cors')) {
      return 'Erreur CORS: La vidéo ne peut pas être chargée depuis cette source.';
    }
    
    return 'Erreur vidéo: ${error.toString()}';
  }

  @override
  void dispose() {
    // Dispose controllers in the correct order
    _chewieController?.dispose();
    _chewieController = null;
    _videoController?.dispose();
    _videoController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Stack(
        fit: StackFit.expand,
        children: [
          // Show thumbnail while loading
          _buildThumbnailPlaceholder(context),
          const Center(child: CircularProgressIndicator()),
        ],
      );
    }

    if (_error != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _buildThumbnailPlaceholder(context),
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de lecture vidéo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _error = null;
                        _isInitializing = true;
                        _chewieController?.dispose();
                        _videoController?.dispose();
                        _chewieController = null;
                        _videoController = null;
                      });
                      _initPlayer();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Réessayer'),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_chewieController == null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _buildThumbnailPlaceholder(context),
          const Center(
            child: Text(
              'Aucune vidéo disponible',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Chewie(controller: _chewieController!),
        Align(
          alignment: Alignment.topLeft,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.event.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a placeholder showing the event thumbnail
  Widget _buildThumbnailPlaceholder(BuildContext context) {
    return Container(
      color: Colors.black,
      child: widget.event.thumbnailUrl.isNotEmpty
          ? Image.network(
              widget.event.thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildDefaultPlaceholder(context);
              },
            )
          : _buildDefaultPlaceholder(context),
    );
  }

  Widget _buildDefaultPlaceholder(BuildContext context) {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              widget.event.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}


