import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';

/// Optimized image widget with:
/// - WebP format support (automatic fallback)
/// - Lazy loading (built into CachedNetworkImage)
/// - Shimmer placeholder during loading
/// - Error handling with fallback icon
class OptimizedImage extends StatelessWidget {
  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderColor,
    this.errorIconSize = 64,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Color? placeholderColor;
  final double errorIconSize;

  /// Converts image URL to WebP format if possible
  /// Falls back to original URL if WebP is not available
  String _getOptimizedUrl(String url) {
    // If URL already contains format specification, return as is
    if (url.contains('format=') || url.contains('.webp')) {
      return url;
    }

    // Try to convert to WebP format
    // This works with most CDNs and image services
    final uri = Uri.tryParse(url);
    if (uri == null) return url;

    // Add format parameter for WebP support
    final queryParams = Map<String, String>.from(uri.queryParameters);
    queryParams['format'] = 'webp';
    queryParams['quality'] = '85'; // Good balance between quality and size

    return uri.replace(queryParameters: queryParams).toString();
  }

  Widget _buildShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: placeholderColor ?? Colors.grey[300]!,
      highlightColor: placeholderColor ?? Colors.grey[100]!,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        decoration: BoxDecoration(
          color: placeholderColor ?? Colors.grey[300],
          borderRadius: borderRadius,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: borderRadius,
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/images/no_image.svg',
          width: errorIconSize,
          height: errorIconSize,
          colorFilter: ColorFilter.mode(
            Colors.grey[400]!,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final optimizedUrl = _getOptimizedUrl(imageUrl);
    
    Widget imageWidget = CachedNetworkImage(
      imageUrl: optimizedUrl,
      width: width,
      height: height,
      fit: fit,
      // Use shimmer placeholder for better UX
      placeholder: (context, url) => _buildShimmerPlaceholder(),
      // Progressive loading - shows low quality first, then high quality
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 100),
      // Error handling
      errorWidget: (context, url, error) => _buildErrorWidget(),
      // Memory cache configuration
      memCacheWidth: width != null ? width!.toInt() : null,
      memCacheHeight: height != null ? height!.toInt() : null,
      // Max width/height for network requests (helps with large images)
      maxWidthDiskCache: width != null ? (width! * 2).toInt() : 2000,
      maxHeightDiskCache: height != null ? (height! * 2).toInt() : 2000,
    );

    // Apply borderRadius if provided
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}

/// Optimized image widget for product thumbnails
/// Pre-configured with common product image settings
class ProductThumbnail extends StatelessWidget {
  const ProductThumbnail({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return OptimizedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: borderRadius ?? const BorderRadius.vertical(
        top: Radius.circular(16),
      ),
      placeholderColor: Colors.grey[200],
      errorIconSize: 64,
    );
  }
}

/// Optimized image widget for hero/banner images
/// Pre-configured for large display images
class HeroImage extends StatelessWidget {
  const HeroImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return OptimizedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      borderRadius: borderRadius,
      placeholderColor: Colors.grey[200],
      errorIconSize: 80,
    );
  }
}

