import 'package:flutter/material.dart';
import 'package:flutter_spatial_navigation/flutter_spatial_navigation.dart';
import '../models.dart';

class TVPlaybackModal extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onClose;

  const TVPlaybackModal({
    super.key,
    required this.item,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
      child: FocusScope(
        child: FocusTraversalGroup(
          policy: const TVSpatialTraversalPolicy(),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 680),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: item.accentColor.withValues(alpha: 0.6),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: item.accentColor.withValues(alpha: 0.35),
                  blurRadius: 36,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.8),
                  blurRadius: 40,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: item.accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item.icon,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.category} • ${item.year} • ${item.duration}',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE11D48),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'NOW PLAYING',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  item.synopsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 24),
                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TVFocusable(
                      autofocus: true,
                      onSelect: onClose,
                      builder: (context, focused) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: focused ? Colors.white : const Color(0xFFE11D48),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: focused ? const Color(0xFF00E5FF) : Colors.transparent,
                              width: focused ? 2.5 : 0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                color: focused ? Colors.black : Colors.white,
                                size: 22,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Resume Playback',
                                style: TextStyle(
                                  color: focused ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 14),
                    TVFocusable(
                      onSelect: onClose,
                      builder: (context, focused) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: focused ? Colors.white : Colors.white12,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: focused ? Colors.white : Colors.white24,
                              width: focused ? 2.0 : 1.0,
                            ),
                          ),
                          child: Text(
                            'Close',
                            style: TextStyle(
                              color: focused ? Colors.black : Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
