import 'package:flutter/material.dart';

import 'explore_search_screen.dart';
import 'instagram_home_screen.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({
    super.key,
    required this.username,
  });

  final String username;

  static const _background = Color(0xFF05080D);
  static const _divider = Color(0xFF151A22);
  static const _mutedText = Color(0xFFAEB3C0);
  static const _linkColor = Color(0xFFA9B5FF);

  static const _messages = [
    _MessageUser(
      name: 'Rayan Malik',
      status: 'Sent a reel by urbanframes · 3h',
      seed: 'chat-rayan',
    ),
    _MessageUser(
      name: 'Kavya Mehra',
      status: 'Seen 19h ago',
      seed: 'chat-kavya',
    ),
    _MessageUser(
      name: 'Zeeshan Khan',
      status: 'Active 1h ago',
      seed: 'chat-zeeshan',
    ),
    _MessageUser(
      name: 'Mira Kapoor',
      status: 'Active 54m ago',
      seed: 'chat-mira',
    ),
    _MessageUser(
      name: 'Ayaan Qureshi',
      status: 'Active today',
      seed: 'chat-ayaan',
    ),
    _MessageUser(
      name: 'Neha Rawat',
      status: 'Seen yesterday',
      seed: 'chat-neha',
    ),
    _MessageUser(
      name: 'Vivaan Arora',
      status: 'Sent Monday',
      seed: 'chat-vivaan',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              child: Row(
                children: [
                  const SizedBox(width: 44),
                  Expanded(
                    child: Text(
                      username,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.edit_square,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
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
                        'Search or ask Meta AI',
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
            SizedBox(
              height: 132,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                scrollDirection: Axis.horizontal,
                children: const [
                  _InboxBubble(
                    title: 'Your note',
                    subtitle: 'Location off',
                    seed: 'note-user',
                    showNote: true,
                  ),
                  _InboxBubble(title: 'Map', seed: 'world-map'),
                  _InboxBubble(
                    title: 'Ankit Verma',
                    seed: 'online-ankit',
                    isOnline: true,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
              child: Row(
                children: const [
                  Text(
                    'Messages',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.notifications_off_outlined, color: Colors.white, size: 22),
                  Spacer(),
                  Text(
                    'Requests',
                    style: TextStyle(
                      color: _linkColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                itemCount: _messages.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _MessageTile(user: _messages[index]);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _MessagesBottomNav(username: username),
    );
  }
}

class _InboxBubble extends StatelessWidget {
  const _InboxBubble({
    required this.title,
    required this.seed,
    this.subtitle,
    this.showNote = false,
    this.isOnline = false,
  });

  final String title;
  final String seed;
  final String? subtitle;
  final bool showNote;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 42,
                backgroundImage: NetworkImage(
                  'https://picsum.photos/seed/$seed/180/180',
                ),
              ),
              if (showNote)
                Positioned(
                  top: -12,
                  left: -8,
                  child: Container(
                    width: 78,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF282D37),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      "Today's\nvibe...",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ),
              if (isOnline)
                Positioned(
                  right: 10,
                  bottom: 2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF33D34A),
                      shape: BoxShape.circle,
                      border: Border.all(color: MessagesScreen._background, width: 3),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
        ],
      ),
    );
  }
}

class _MessageTile extends StatelessWidget {
  const _MessageTile({required this.user});

  final _MessageUser user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundImage: NetworkImage(
            'https://picsum.photos/seed/${user.seed}/140/140',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user.status,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: MessagesScreen._mutedText,
                  fontSize: 17,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.photo_camera_outlined,
          color: MessagesScreen._mutedText,
          size: 30,
        ),
      ],
    );
  }
}

class _MessagesBottomNav extends StatelessWidget {
  const _MessagesBottomNav({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: MessagesScreen._background,
          border: Border(top: BorderSide(color: MessagesScreen._divider)),
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
              const Icon(Icons.send_rounded, size: 30, color: Colors.white),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => ExploreSearchScreen(username: username),
                    ),
                  );
                },
                icon: const Icon(Icons.search_rounded, color: Colors.white, size: 32),
              ),
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

class _MessageUser {
  const _MessageUser({
    required this.name,
    required this.status,
    required this.seed,
  });

  final String name;
  final String status;
  final String seed;
}
