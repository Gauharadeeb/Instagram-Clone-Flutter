import 'package:flutter/material.dart';

import 'instagram_home_screen.dart';
import 'messages_screen.dart';

class ExploreSearchScreen extends StatelessWidget {
  const ExploreSearchScreen({
    super.key,
    required this.username,
    this.showBottomNav = true,
  });

  final String username;
  final bool showBottomNav;

  static const _background = Color(0xFF05080D);
  static const _divider = Color(0xFF151A22);

  static const _items = [
    _ExploreItem(seed: 'explore-city', views: '1.2M'),
    _ExploreItem(seed: 'explore-home', views: '36.7M'),
    _ExploreItem(seed: 'explore-stadium', views: '881K'),
    _ExploreItem(seed: 'explore-face', views: '1.7M'),
    _ExploreItem(seed: 'explore-wedding', views: '240K'),
    _ExploreItem(seed: 'explore-villa', views: '4.2M'),
    _ExploreItem(seed: 'explore-room', views: '1.4M'),
    _ExploreItem(seed: 'explore-shirt', views: '742K'),
    _ExploreItem(seed: 'explore-spa', views: '4.9M'),
    _ExploreItem(seed: 'explore-style', views: '1M'),
    _ExploreItem(seed: 'explore-ceiling', views: '829K'),
    _ExploreItem(seed: 'explore-travel', views: '638K'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
              child: Container(
                height: 58,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF24272E),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search_rounded, color: Colors.white, size: 30),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Search with Meta AI',
                        style: TextStyle(
                          color: Color(0xFFC7CAD3),
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                  childAspectRatio: 0.62,
                ),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  return _ExploreTile(item: _items[index], index: index);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: showBottomNav ? _ExploreBottomNav(username: username) : null,
    );
  }
}

class _ExploreTile extends StatelessWidget {
  const _ExploreTile({
    required this.item,
    required this.index,
  });

  final _ExploreItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final heightSeed = index % 3 == 1 ? 980 : 860;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          'https://picsum.photos/seed/${item.seed}/500/$heightSeed',
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }

            return Container(
              color: const Color(0xFF151A22),
              alignment: Alignment.center,
              child: const CircularProgressIndicator(strokeWidth: 2),
            );
          },
        ),
        Positioned(
          left: 8,
          bottom: 8,
          child: Row(
            children: [
              const Icon(
                Icons.remove_red_eye_outlined,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                item.views,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExploreBottomNav extends StatelessWidget {
  const _ExploreBottomNav({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: ExploreSearchScreen._background,
          border: Border(top: BorderSide(color: ExploreSearchScreen._divider)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.home_outlined, color: Colors.white, size: 30),
              ),
              const Icon(Icons.video_collection_outlined, size: 30, color: Colors.white),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MessagesScreen(username: username),
                    ),
                  );
                },
                icon: const Icon(Icons.send_outlined, color: Colors.white, size: 30),
              ),
              const Icon(Icons.search_rounded, size: 34, color: Colors.white),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => InstagramHomeScreen(username: username),
                    ),
                  );
                },
                icon: const Icon(Icons.person, color: Colors.white, size: 30),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExploreItem {
  const _ExploreItem({
    required this.seed,
    required this.views,
  });

  final String seed;
  final String views;
}
