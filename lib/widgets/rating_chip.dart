import 'package:flutter/material.dart';

class RatingChip extends StatelessWidget {
  const RatingChip({
    super.key,
    required this.ratingLabel,
    this.compact = false,
  });

  final String ratingLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: compact ? 15 : 17,
            color: colorScheme.secondary,
          ),
          const SizedBox(width: 3),
          Text(
            ratingLabel,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
