import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'instagram_home_screen.dart';

class InstagramFeedScreen extends StatelessWidget {
  const InstagramFeedScreen({super.key});

  static const _posts = [
    _FeedPost(
      username: 'aria.james',
      location: 'Mumbai, India',
      imageUrl: 'https://picsum.photos/seed/classico1/800/900',
      likes: '14,281 likes',
      caption: 'Weekend coffee, sunshine, and soft moments.',
    ),
    _FeedPost(
      username: 'noahstreet',
      location: 'Delhi',
      imageUrl: 'https://picsum.photos/seed/classico2/800/900',
      likes: '8,943 likes',
      caption: 'City lights always feel different after rain.',
    ),
    _FeedPost(
      username: 'mia.visuals',
      location: 'Jaipur',
      imageUrl: 'https://picsum.photos/seed/classico3/800/900',
      likes: '22,110 likes',
      caption: 'Colors, texture, and a little golden hour magic.',
    ),
    _FeedPost(
      username: 'liamframes',
      location: 'Goa',
      imageUrl: 'https://picsum.photos/seed/classico4/800/900',
      likes: '11,507 likes',
      caption: 'Ocean breeze and no plans for the rest of the day.',
    ),
    _FeedPost(
      username: 'zoe.daily',
      location: 'Bangalore',
      imageUrl: 'https://picsum.photos/seed/classico5/800/900',
      likes: '19,764 likes',
      caption: 'Simple outfit, good mood, and one perfect shot.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Instagram',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w800,
              ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(Icons.favorite_border_rounded),
          ),
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(Icons.chat_bubble_outline_rounded),
          ),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 108,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              scrollDirection: Axis.horizontal,
              children: const [
                _StoryBubble(name: 'You'),
                _StoryBubble(name: 'Aria'),
                _StoryBubble(name: 'Noah'),
                _StoryBubble(name: 'Mia'),
                _StoryBubble(name: 'Liam'),
                _StoryBubble(name: 'Zoe'),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          ..._posts.map((post) => _PostCard(post: post)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.home_filled, size: 28),
                const Icon(Icons.search_rounded, size: 28),
                const Icon(Icons.add_box_outlined, size: 28),
                const Icon(Icons.video_collection_outlined, size: 28),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const InstagramHomeScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.textPrimary, width: 2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StoryBubble extends StatelessWidget {
  const _StoryBubble({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFEDA75),
                  Color(0xFFFA7E1E),
                  Color(0xFFD62976),
                  Color(0xFF962FBF),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.textSecondary,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({required this.post});

  final _FeedPost post;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFEDA75),
                      Color(0xFFD62976),
                      Color(0xFF962FBF),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(2.5),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      post.location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz_rounded),
            ],
          ),
        ),
        ClipRRect(
          child: Image.network(
            post.imageUrl,
            height: 420,
            width: double.infinity,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                return child;
              }

              return Container(
                height: 420,
                color: const Color(0xFFF3F4F6),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
          child: Row(
            children: const [
              Icon(Icons.favorite_border_rounded, size: 28),
              SizedBox(width: 14),
              Icon(Icons.mode_comment_outlined, size: 26),
              SizedBox(width: 14),
              Icon(Icons.send_outlined, size: 25),
              Spacer(),
              Icon(Icons.bookmark_border_rounded, size: 27),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Text(
            post.likes,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: '${post.username} ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: post.caption),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Text(
            'View all comments',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(14, 0, 14, 18),
          child: Text(
            '2 HOURS AGO',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _FeedPost {
  const _FeedPost({
    required this.username,
    required this.location,
    required this.imageUrl,
    required this.likes,
    required this.caption,
  });

  final String username;
  final String location;
  final String imageUrl;
  final String likes;
  final String caption;
}
