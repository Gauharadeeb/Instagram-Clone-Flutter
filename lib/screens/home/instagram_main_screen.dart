import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'create_post_screen.dart';
import 'explore_search_screen.dart';
import 'instagram_feed_screen.dart';
import 'instagram_home_screen.dart';
import 'reels_screen.dart';

class InstagramMainScreen extends StatefulWidget {
  const InstagramMainScreen({
    super.key,
    required this.username,
  });

  final String username;

  @override
  State<InstagramMainScreen> createState() => _InstagramMainScreenState();
}

class _InstagramMainScreenState extends State<InstagramMainScreen> {
  int _currentIndex = 0;
  int _feedRefreshToken = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      InstagramFeedScreen(
        username: widget.username,
        refreshToken: _feedRefreshToken,
        onCreatePost: _openCreatePost,
      ),
      const ReelsScreen(),
      CreatePostScreen(
        onClose: _returnToFeed,
        onPostCreated: (_) => _handlePostCreated(),
      ),
      ExploreSearchScreen(username: widget.username, showBottomNav: false),
      InstagramHomeScreen(username: widget.username),
    ];

    final background = InstagramColors.background(context);
    final divider = InstagramColors.border(context);

    return Scaffold(
      backgroundColor: background,
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: _currentIndex == 2
          ? null
          : SafeArea(
        top: false,
        child: Container(
          height: 49,
          decoration: BoxDecoration(
            color: background,
            border: Border(top: BorderSide(color: divider)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _NavIcon(
                  icon: _currentIndex == 0 ? Icons.home : Icons.home_outlined,
                  isActive: _currentIndex == 0,
                  tooltip: 'Home',
                  onTap: () => _selectTab(0),
                ),
              ),
              Expanded(
                child: _NavIcon(
                  icon: Icons.video_collection_outlined,
                  isActive: _currentIndex == 1,
                  tooltip: 'Reels',
                  onTap: () => _selectTab(1),
                ),
              ),
              Expanded(
                child: _NavIcon(
                  icon: Icons.add_box_outlined,
                  isActive: _currentIndex == 2,
                  tooltip: 'Create post',
                  onTap: () => _selectTab(2),
                ),
              ),
              Expanded(
                child: _NavIcon(
                  icon: Icons.search_rounded,
                  isActive: _currentIndex == 3,
                  tooltip: 'Search',
                  onTap: () => _selectTab(3),
                ),
              ),
              Expanded(
                child: _ProfileNavIcon(
                  isActive: _currentIndex == 4,
                  onTap: () => _selectTab(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _openCreatePost() {
    setState(() => _currentIndex = 2);
  }

  void _returnToFeed() {
    setState(() => _currentIndex = 0);
  }

  void _handlePostCreated() {
    setState(() {
      _feedRefreshToken++;
      _currentIndex = 0;
    });
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.isActive,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 48, height: 48),
        icon: Icon(
          icon,
          color: InstagramColors.icon(context),
          size: isActive ? 27 : 26,
        ),
      ),
    );
  }
}

class _ProfileNavIcon extends StatelessWidget {
  const _ProfileNavIcon({
    required this.isActive,
    required this.onTap,
  });

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        tooltip: 'Profile',
        onPressed: onTap,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints.tightFor(width: 48, height: 48),
        icon: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: InstagramColors.elevatedSurface(context),
            shape: BoxShape.circle,
            border: isActive ? Border.all(color: InstagramColors.icon(context), width: 2) : null,
          ),
          child: const Icon(
            Icons.person,
            color: Color(0xFF7B838F),
            size: 18,
          ),
        ),
      ),
    );
  }
}
