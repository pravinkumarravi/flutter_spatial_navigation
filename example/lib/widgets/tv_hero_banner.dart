import 'package:flutter/material.dart';
import 'package:flutter_spatial_navigation/flutter_spatial_navigation.dart';
import '../models.dart';

class TVHeroBanner extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onPlay;
  final VoidCallback onToggleWatchlist;
  final bool isInWatchlist;

  const TVHeroBanner({
    super.key,
    required this.item,
    required this.onPlay,
    required this.onToggleWatchlist,
    this.isInWatchlist = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 310,
      margin: const EdgeInsets.fromLTRB(28, 20, 28, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            item.accentColor.withValues(alpha: 0.35),
            item.secondaryColor.withValues(alpha: 0.25),
            const Color(0xFF0F1420),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: item.accentColor.withValues(alpha: 0.2),
            blurRadius: 36,
            spreadRadius: 2,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Ambient Background Glow & Watermark
          Positioned(
            right: 40,
            top: 20,
            bottom: 20,
            child: Opacity(
              opacity: 0.12,
              child: Icon(
                item.icon,
                size: 260,
                color: Colors.white,
              ),
            ),
          ),

          // Dark Vignette gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFF0B0F19).withValues(alpha: 0.96),
                    const Color(0xFF0B0F19).withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // Content Details
          Positioned(
            left: 36,
            top: 28,
            bottom: 28,
            right: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top Tag & Badges
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'FEATURED SPOTLIGHT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                      child: Text(
                        item.badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFC107),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.rating,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${item.year}  •  ${item.duration}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Text(
                    item.title,
                    key: ValueKey(item.id),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Synopsis
                Text(
                  item.synopsis,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // TV Action Buttons wrapped in TVFocusable
                Row(
                  children: [
                    // Play Button with autofocus
                    TVFocusable(
                      autofocus: true,
                      onSelect: onPlay,
                      builder: (context, focused) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 140),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: focused ? Colors.white : const Color(0xFFE11D48),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: focused ? const Color(0xFF00E5FF) : Colors.transparent,
                              width: focused ? 3.0 : 0.0,
                            ),
                            boxShadow: [
                              if (focused) ...[
                                BoxShadow(
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.55),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                ),
                              ] else
                                BoxShadow(
                                  color: const Color(0xFFE11D48).withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                color: focused ? const Color(0xFF0F172A) : Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Play Now',
                                style: TextStyle(
                                  color: focused ? const Color(0xFF0F172A) : Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 14),

                    // Add to Watchlist Button
                    TVFocusable(
                      onSelect: onToggleWatchlist,
                      builder: (context, focused) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 140),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: focused ? Colors.white : Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: focused ? Colors.white : Colors.white24,
                              width: focused ? 2.5 : 1.0,
                            ),
                            boxShadow: [
                              if (focused)
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isInWatchlist
                                    ? Icons.check_circle_rounded
                                    : Icons.bookmark_add_outlined,
                                color: focused ? const Color(0xFF0F172A) : Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isInWatchlist ? 'In Watchlist' : 'Watchlist',
                                style: TextStyle(
                                  color: focused ? const Color(0xFF0F172A) : Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
