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
  bool _isInitialized = false;
  VoidCallback? _errorListener;

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
      // Clean up any existing controllers first
      _chewieController?.dispose();
      _videoController?.dispose();
      
      setState(() {
        _isInitializing = true;
        _error = null;
        _isInitialized = false;
        _chewieController = null;
        _videoController = null;
      });

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

      debugPrint('Initializing video player with URL: $url');

      final controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: {
          // Add headers for better compatibility
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': '*/*',
          'Accept-Language': 'en-US,en;q=0.9',
        },
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      // Add error listener
      _errorListener = () {
        if (controller.value.hasError) {
          debugPrint('Video player error: ${controller.value.errorDescription}');
          if (mounted) {
            setState(() {
              _error = _getErrorMessage(controller.value.errorDescription ?? 'Erreur inconnue');
              _isInitializing = false;
            });
          }
        }
      };
      controller.addListener(_errorListener!);

      // Set a timeout for initialization
      await controller.initialize().timeout(
        const Duration(seconds: 20),
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

      // Verify controller is initialized
      if (!controller.value.isInitialized) {
        controller.dispose();
        throw Exception('Échec de l\'initialisation du lecteur vidéo');
      }

      debugPrint('Video controller initialized. Duration: ${controller.value.duration}');

      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: false, // Always require user interaction for better compatibility
        looping: true,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        showControlsOnInitialize: true,
        aspectRatio: controller.value.aspectRatio,
        placeholder: _buildThumbnailPlaceholder(context),
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF4A9FCC),
          handleColor: const Color(0xFF4A9FCC),
          backgroundColor: Colors.grey[800]!,
          bufferedColor: Colors.grey[600]!,
        ),
        cupertinoProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF4A9FCC),
          handleColor: const Color(0xFF4A9FCC),
          backgroundColor: Colors.grey[800]!,
          bufferedColor: Colors.grey[600]!,
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
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
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
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
                    errorMessage,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
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
          _isInitialized = true;
        });
        
        // For web, try to play after a short delay to ensure proper initialization
        if (kIsWeb) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && _videoController != null && _videoController!.value.isInitialized) {
              // Don't auto-play, but ensure the controller is ready
              debugPrint('Video player ready for playback');
            }
          });
        }
      } else {
        // Widget was disposed, clean up
        chewie.dispose();
        controller.dispose();
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing video player: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Check if widget is still mounted before setState
      if (mounted) {
        // Clean up any partial controller
        _videoController?.dispose();
        _videoController = null;
        _chewieController?.dispose();
        _chewieController = null;

        setState(() {
          _error = _getErrorMessage(e);
          _isInitializing = false;
          _isInitialized = false;
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
    if (_errorListener != null && _videoController != null) {
      _videoController!.removeListener(_errorListener!);
    }
    _videoController?.dispose();
    _videoController = null;
    _errorListener = null;
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

    if (_chewieController == null || !_isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _buildThumbnailPlaceholder(context),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.play_circle_outline,
                  size: 64,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Aucune vidéo disponible',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Verify the video controller is still initialized
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          _buildThumbnailPlaceholder(context),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 16),
                const Text(
                  'Initialisation du lecteur...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Chewie widget - it handles all gestures internally
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
                  fontSize: 12,
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


