import 'package:flutter/material.dart';
import 'package:flutter_spatial_navigation/flutter_spatial_navigation.dart';

class TVSidebarItemData {
  final IconData icon;
  final String label;
  final String? badge;

  const TVSidebarItemData({
    required this.icon,
    required this.label,
    this.badge,
  });
}

class TVSidebarDrawer extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;
  final ValueChanged<bool>? onExpansionChanged;

  const TVSidebarDrawer({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    this.onExpansionChanged,
  });

  @override
  State<TVSidebarDrawer> createState() => _TVSidebarDrawerState();
}

class _TVSidebarDrawerState extends State<TVSidebarDrawer> {
  bool _hasFocus = false;
  bool _forceExpanded = false;

  bool get _isExpanded => _hasFocus || _forceExpanded;

  static const List<TVSidebarItemData> items = [
    TVSidebarItemData(icon: Icons.search_rounded, label: 'Search'),
    TVSidebarItemData(icon: Icons.home_rounded, label: 'Home'),
    TVSidebarItemData(icon: Icons.local_movies_rounded, label: 'Movies'),
    TVSidebarItemData(icon: Icons.tv_rounded, label: 'Series', badge: 'NEW'),
    TVSidebarItemData(icon: Icons.category_rounded, label: 'Categories'),
    TVSidebarItemData(icon: Icons.bookmark_added_rounded, label: 'My List'),
    TVSidebarItemData(icon: Icons.settings_rounded, label: 'Settings'),
  ];

  void _updateFocusState(bool hasFocus) {
    if (_hasFocus != hasFocus) {
      setState(() => _hasFocus = hasFocus);
      widget.onExpansionChanged?.call(_isExpanded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = _isExpanded;

    return TVFocusGroup(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: isExpanded ? 230 : 76,
        decoration: BoxDecoration(
          color: const Color(0xFF0D111A).withValues(alpha: 0.96),
          border: Border(
            right: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
              width: 1,
            ),
          ),
          boxShadow: [
            if (isExpanded)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.65),
                blurRadius: 32,
                spreadRadius: 4,
                offset: const Offset(4, 0),
              ),
          ],
        ),
        child: ClipRect(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // App Brand / Logo Header
              _buildBrandHeader(isExpanded),
              const SizedBox(height: 22),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 16),
              // Navigation Items
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = widget.selectedIndex == index;

                    return TVFocusable(
                      onFocusChange: (focused) {
                        _updateFocusState(focused);
                      },
                      onSelect: () {
                        widget.onItemSelected(index);
                      },
                      builder: (ctx, focused) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 140),
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: focused
                                ? Colors.white
                                : isSelected
                                    ? Colors.white.withValues(alpha: 0.12)
                                    : Colors.transparent,
                            border: Border.all(
                              color: focused
                                  ? const Color(0xFF00E5FF)
                                  : isSelected
                                      ? Colors.white.withValues(alpha: 0.3)
                                      : Colors.transparent,
                              width: focused ? 2.5 : 1.0,
                            ),
                            boxShadow: [
                              if (focused) ...[
                                BoxShadow(
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                                  blurRadius: 14,
                                  spreadRadius: 1,
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                ),
                              ],
                            ],
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            child: SizedBox(
                              height: 48,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    item.icon,
                                    size: 24,
                                    color: focused
                                        ? const Color(0xFF0A0E17)
                                        : isSelected
                                            ? const Color(0xFF00E5FF)
                                            : Colors.white70,
                                  ),
                                  if (isExpanded) ...[
                                    const SizedBox(width: 14),
                                    Text(
                                      item.label,
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.fade,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: focused || isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: focused
                                            ? const Color(0xFF0A0E17)
                                            : isSelected
                                                ? Colors.white
                                                : Colors.white70,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    if (item.badge != null) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE11D48),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item.badge!,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 12),
              // User Profile Footer
              _buildProfileFooter(isExpanded),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader(bool isExpanded) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE11D48), Color(0xFF7C3AED)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE11D48).withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.tv_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SPATIAL TV',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'D-Pad Navigation',
                    style: TextStyle(
                      color: Color(0xFF00E5FF),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileFooter(bool isExpanded) {
    return TVFocusable(
      onFocusChange: (focused) => _updateFocusState(focused),
      onSelect: () {
        setState(() => _forceExpanded = !_forceExpanded);
      },
      builder: (context, focused) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: focused ? Colors.white12 : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: focused ? const Color(0xFF00E5FF) : Colors.transparent,
              width: focused ? 2.0 : 1.0,
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                if (isExpanded) ...[
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Alex Rivera',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'VIP Member',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _forceExpanded
                        ? Icons.keyboard_double_arrow_left_rounded
                        : Icons.keyboard_double_arrow_right_rounded,
                    color: Colors.white54,
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
