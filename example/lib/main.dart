import 'package:flutter/material.dart';
import 'package:flutter_spatial_navigation/flutter_spatial_navigation.dart';

import 'models.dart';
import 'widgets/tv_hero_banner.dart';
import 'widgets/tv_media_card.dart';
import 'widgets/tv_playback_modal.dart';
import 'widgets/tv_sidebar.dart';

void main() {
  runApp(const TVApp());
}

class TVApp extends StatelessWidget {
  const TVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter TV Spatial Navigation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07090E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFE11D48),
          secondary: Color(0xFF00E5FF),
          surface: Color(0xFF0E131F),
        ),
        fontFamily: 'Roboto',
      ),
      home: const TVNavigation(
        child: TVHomeScreen(),
      ),
    );
  }
}

class TVHomeScreen extends StatefulWidget {
  const TVHomeScreen({super.key});

  @override
  State<TVHomeScreen> createState() => _TVHomeScreenState();
}

class _TVHomeScreenState extends State<TVHomeScreen> {
  int _selectedNavIndex = 1; // Default to 'Home'
  late MediaItem _activeMovie;
  final Set<String> _watchlist = <String>{};
  final List<MediaSection> _sections = SampleTvData.getAllSections();

  @override
  void initState() {
    super.initState();
    _activeMovie = SampleTvData.heroFeatured.first;
  }

  void _onCardFocused(MediaItem item) {
    if (_activeMovie.id != item.id) {
      setState(() {
        _activeMovie = item;
      });
    }
  }

  void _openPlaybackModal(MediaItem item) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => TVPlaybackModal(
        item: item,
        onClose: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void _toggleWatchlist(String id) {
    setState(() {
      if (_watchlist.contains(id)) {
        _watchlist.remove(id);
      } else {
        _watchlist.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FocusTraversalGroup(
        policy: const TVSpatialTraversalPolicy(
          edgeBehavior: TVEdgeBehavior.trap,
        ),
        child: Row(
          children: [
            // ── 1. Collapsible Sidebar Drawer (Icons & Expandable Text) ──
            TVSidebarDrawer(
              selectedIndex: _selectedNavIndex,
              onItemSelected: (index) {
                setState(() => _selectedNavIndex = index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    duration: const Duration(milliseconds: 1200),
                    backgroundColor: const Color(0xFF1E293B),
                    content: Text(
                      'Navigated to: ${TVSidebarDrawerStateHelper.getName(index)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),

            // ── 2. Main Content Canvas (Hero Banner + TV Carousels) ──
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // TV App Bar & Status HUD
                  SliverToBoxAdapter(
                    child: _buildTopStatusHeader(),
                  ),

                  // TV Hero Spotlight Banner
                  SliverToBoxAdapter(
                    child: TVFocusGroup(
                      child: TVHeroBanner(
                        item: _activeMovie,
                        isInWatchlist: _watchlist.contains(_activeMovie.id),
                        onPlay: () => _openPlaybackModal(_activeMovie),
                        onToggleWatchlist: () =>
                            _toggleWatchlist(_activeMovie.id),
                      ),
                    ),
                  ),

                  // Carousel Media Rows
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, sectionIndex) {
                        final section = _sections[sectionIndex];
                        return _buildMediaSectionRow(section);
                      },
                      childCount: _sections.length,
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 48),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopStatusHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                TVSidebarDrawerStateHelper.getName(_selectedNavIndex).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.white38,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Spatial Navigation Demo',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          // Remote D-Pad indicator pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF10B981),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'D-Pad Traversal Active',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSectionRow(MediaSection section) {
    final double rowHeight = section.isWide ? 200 : 280;
    final double itemExtent = section.isWide ? 300 : 195;

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row Header Title & Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              children: [
                Text(
                  section.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '•  ${section.subtitle}',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Enclosing TVFocusGroup remembers last focused card when leaving & returning
          TVFocusGroup(
            child: SizedBox(
              height: rowHeight,
              child: TVLazyList(
                itemCount: section.items.length,
                itemExtent: itemExtent,
                focusAlignment: 0.0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                onSelect: (index) {
                  _openPlaybackModal(section.items[index]);
                },
                itemBuilder: (context, index, focused) {
                  final item = section.items[index];

                  // When focused, dynamically update the Hero Spotlight
                  if (focused && _activeMovie.id != item.id) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _onCardFocused(item);
                    });
                  }

                  return TVMediaCard(
                    item: item,
                    focused: focused,
                    isWide: section.isWide,
                    onTap: () => _openPlaybackModal(item),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TVSidebarDrawerStateHelper {
  static String getName(int index) {
    switch (index) {
      case 0:
        return 'Search';
      case 1:
        return 'Home';
      case 2:
        return 'Movies';
      case 3:
        return 'TV Shows';
      case 4:
        return 'Categories';
      case 5:
        return 'My List';
      case 6:
        return 'Settings';
      default:
        return 'Explore';
    }
  }
}