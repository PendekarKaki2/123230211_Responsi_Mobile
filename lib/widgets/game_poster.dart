import 'package:flutter/material.dart';

class ShowPoster extends StatelessWidget {
  const ShowPoster({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
  });

  final String? imageUrl;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: imageUrl == null || imageUrl!.isEmpty
            ? _PosterPlaceholder(width: width, height: height)
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                width: width,
                height: height,
                errorBuilder: (context, error, stackTrace) {
                  return _PosterPlaceholder(width: width, height: height);
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return _PosterPlaceholder(
                    width: width,
                    height: height,
                    isLoading: true,
                  );
                },
              ),
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder({
    required this.width,
    required this.height,
    this.isLoading = false,
  });

  final double? width;
  final double? height;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: width,
      height: height,
      color: colorScheme.primaryContainer.withValues(alpha: 0.45),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: colorScheme.primary,
                ),
              )
            : Icon(
                Icons.movie_creation_outlined,
                color: colorScheme.primary,
                size: 34,
              ),
      ),
    );
  }
}
