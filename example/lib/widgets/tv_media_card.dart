import 'package:flutter/material.dart';
import '../models.dart';

class TVMediaCard extends StatelessWidget {
  final MediaItem item;
  final bool focused;
  final bool isWide;
  final VoidCallback? onTap;

  const TVMediaCard({
    super.key,
    required this.item,
    required this.focused,
    this.isWide = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: focused ? 1.07 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // BORDER TO FOCUSED CARD
          border: Border.all(
            color: focused ? Colors.white : Colors.white.withValues(alpha: 0.08),
            width: focused ? 3.5 : 1.5,
          ),
          boxShadow: [
            if (focused) ...[
              BoxShadow(
                color: item.accentColor.withValues(alpha: 0.55),
                blurRadius: 22,
                spreadRadius: 3,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ] else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(focused ? 12.5 : 14.5),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Poster Background Artwork
              _buildPosterBackground(),

              // Gradient Overlay for text contrast
              _buildVignetteOverlay(),

              // Top Badges & Rank
              _buildTopBadges(),

              // Focused Play Overlay
              if (focused) _buildPlayIndicator(),

              // Bottom Details & Progress Bar
              _buildBottomInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPosterBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            item.accentColor.withValues(alpha: 0.85),
            item.secondaryColor.withValues(alpha: 0.95),
            const Color(0xFF0F141E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: focused ? 0.35 : 0.2,
          child: Icon(
            item.icon,
            size: isWide ? 70 : 80,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildVignetteOverlay() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.45, 1.0],
            colors: [
              Colors.black.withValues(alpha: 0.2),
              Colors.transparent,
              Colors.black.withValues(alpha: 0.92),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBadges() {
    return Positioned(
      top: 10,
      left: 10,
      right: 10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (item.rank != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.4),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Text(
                '#${item.rank}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            )
          else if (item.badge.isNotEmpty)
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  item.badge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          const SizedBox(width: 4),
          // IMDb rating pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFC107),
                  size: 13,
                ),
                const SizedBox(width: 3),
                Text(
                  item.rating,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayIndicator() {
    return Center(
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.92),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 10,
            ),
          ],
        ),
        child: const Icon(
          Icons.play_arrow_rounded,
          color: Color(0xFF0F172A),
          size: 30,
        ),
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 10,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontWeight: focused ? FontWeight.w800 : FontWeight.w600,
              fontSize: isWide ? 14 : 13,
              shadows: const [
                Shadow(
                  color: Colors.black,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            isWide ? item.duration : item.category,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: focused ? Colors.white70 : Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (item.progress != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: item.progress,
                minHeight: 4,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFE11D48),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
