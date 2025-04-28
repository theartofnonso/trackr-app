import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
///  MembershipPromoCard
/// ---------------------------------------------------------------------------
///  Screenshot‑style promotional banner:
///    • Background image (full‑bleed) with dark bottom gradient
///    • Headline + body copy in the foreground (bottom‑left)
///    • Chevron‑right icon in the foreground (bottom‑right)
///    • Rounded corners, subtle drop‑shadow, tap callback
/// ---------------------------------------------------------------------------
class InformationContainerWithBackgroundImage extends StatelessWidget {
  const InformationContainerWithBackgroundImage({
    super.key,
    required this.image,
    required this.subtitle,
    required this.onTap,
    required this.color,
    this.height = 160,
    this.borderRadius = 16,
  });

  /// Background image (use AssetImage, NetworkImage, etc.).
  final String image;

  /// Descriptive copy under the headline.
  final String subtitle;

  /// Called when the user taps anywhere on the card.
  final VoidCallback onTap;

  /// Fixed height of the card; width stretches to parent.
  final double height;

  /// Corner radius.
  final double borderRadius;

  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1️⃣ Background image
              Image.asset(
                image,
                fit: BoxFit.cover,
                width: double.infinity,
                alignment: Alignment.center,
              ),
              // 2️⃣ Gradient overlay (transparent → dark)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        color, // semi‑opaque dark
                      ],
                    ),
                  ),
                ),
              ),

              // 3️⃣ Text + arrow
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Text column expands; arrow stays fixed size.
                    Expanded(
                      child: Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Circle icon with chevron
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}