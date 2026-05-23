import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/providers/feed_provider.dart';
import '../../models/post.dart';
import '../../services/feed_api_service.dart';
import '../../widgets/post_card.dart';

class InstagramFeedScreen extends StatefulWidget {
  const InstagramFeedScreen({
    super.key,
    required this.username,
    this.onCreatePost,
    this.refreshToken = 0,
  });

  final String username;
  final VoidCallback? onCreatePost;
  final int refreshToken;

  @override
  State<InstagramFeedScreen> createState() => _InstagramFeedScreenState();
}

class _InstagramFeedScreenState extends State<InstagramFeedScreen> {
  late final FeedProvider _feedProvider;

  @override
  void initState() {
    super.initState();
    _feedProvider = FeedProvider(apiService: FeedApiService());
    _feedProvider.loadFeed();
  }

  @override
  void didUpdateWidget(covariant InstagramFeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _feedProvider.refreshFeed();
    }
  }

  @override
  void dispose() {
    _feedProvider.dispose();
    super.dispose();
  }

  Future<void> _refreshFeed() => _feedProvider.refreshFeed();

  @override
  Widget build(BuildContext context) {
    final background = InstagramColors.background(context);
    final primaryText = InstagramColors.textPrimary(context);
    final divider = InstagramColors.border(context);

    return ChangeNotifierProvider.value(
      value: _feedProvider,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: background,
          foregroundColor: primaryText,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: 48,
          leading: IconButton(
            onPressed: widget.onCreatePost,
            icon: const Icon(Icons.add, size: 28),
          ),
          title: Text(
            'Instagram',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: primaryText,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w800,
                  fontSize: 27,
                ),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(Icons.favorite_border_rounded, size: 28),
            ),
          ],
        ),
        body: Consumer<FeedProvider>(
          builder: (context, feedProvider, child) {
            if (feedProvider.isLoading && feedProvider.posts.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(InstagramColors.blue),
                ),
              );
            }

            if (feedProvider.hasError && feedProvider.posts.isEmpty) {
              return _FeedErrorState(
                message: feedProvider.errorMessage ?? 'Failed to load feed',
                onRetry: _refreshFeed,
              );
            }

            if (feedProvider.posts.isEmpty) {
              return const _EmptyFeedState();
            }

            final suggestedUsers = _uniqueUsers(feedProvider.posts);

            return RefreshIndicator(
              onRefresh: _refreshFeed,
              color: InstagramColors.blue,
              backgroundColor: InstagramColors.modal(context),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  _StoriesStrip(
                    username: widget.username,
                    users: suggestedUsers,
                  ),
                  Divider(height: 1, color: divider),
                  for (var index = 0; index < feedProvider.posts.length; index++) ...[
                    PostCard(
                      post: feedProvider.posts[index],
                      currentUsername: widget.username,
                      suggestedUsers: suggestedUsers,
                      isLikePending: feedProvider.isLikePending(
                        feedProvider.posts[index].id,
                      ),
                      isCommentPending: feedProvider.isCommentPending(
                        feedProvider.posts[index].id,
                      ),
                      onToggleLike: () => feedProvider.toggleLike(
                        feedProvider.posts[index].id,
                      ),
                      onAddComment: (text) => feedProvider.addComment(
                        postId: feedProvider.posts[index].id,
                        text: text,
                        currentUsername: widget.username,
                      ),
                    ),
                    if (index == 0 && suggestedUsers.isNotEmpty)
                      _SuggestedUsersSection(users: suggestedUsers),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<PostUser> _uniqueUsers(List<Post> posts) {
    final seen = <int>{};
    final users = <PostUser>[];

    for (final post in posts) {
      if (seen.add(post.user.id)) {
        users.add(post.user);
      }
    }

    return users.take(8).toList();
  }
}

class _FeedErrorState extends StatelessWidget {
  const _FeedErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final primaryText = InstagramColors.textPrimary(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: primaryText, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: primaryText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: InstagramColors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoriesStrip extends StatelessWidget {
  const _StoriesStrip({
    required this.username,
    required this.users,
  });

  final String username;
  final List<PostUser> users;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 102,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
        children: [
          _StoryBubble(username: 'Your story', isCurrentUser: true),
          for (final user in users)
            _StoryBubble(
              username: user.username,
              imageUrl: user.profileImageUrl,
            ),
        ],
      ),
    );
  }
}

class _StoryBubble extends StatelessWidget {
  const _StoryBubble({
    required this.username,
    this.imageUrl,
    this.isCurrentUser = false,
  });

  final String username;
  final String? imageUrl;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final background = InstagramColors.background(context);
    final primaryText = InstagramColors.textPrimary(context);

    return SizedBox(
      width: 76,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 66,
                height: 66,
                padding: EdgeInsets.all(isCurrentUser ? 0 : 2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrentUser ? const Color(0xFFE9EDF4) : null,
                  gradient: isCurrentUser
                      ? null
                      : const LinearGradient(
                          colors: [
                            Color(0xFFFEDA75),
                            Color(0xFFFA7E1E),
                            Color(0xFFD62976),
                            Color(0xFF962FBF),
                          ],
                        ),
                ),
                child: ClipOval(
                  child: ColoredBox(
                    color: const Color(0xFFE9EDF4),
                    child: hasImage
                        ? Image.network(imageUrl!, fit: BoxFit.cover)
                        : const Icon(
                            Icons.person,
                            color: Color(0xFF7B838F),
                            size: 34,
                          ),
                  ),
                ),
              ),
              if (isCurrentUser)
                Positioned(
                  right: 1,
                  bottom: 1,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: background,
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      Icons.add,
                      color: background,
                      size: 15,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(color: primaryText, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

class _SuggestedUsersSection extends StatelessWidget {
  const _SuggestedUsersSection({required this.users});

  final List<PostUser> users;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: InstagramColors.background(context),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 0, 18),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Suggested for you',
                      style: TextStyle(
                        color: InstagramColors.textPrimary(context),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Text(
                    'See all',
                    style: TextStyle(
                      color: Color(0xFF8EA7FF),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 202,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: users.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return _SuggestedUserCard(user: users[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestedUserCard extends StatelessWidget {
  const _SuggestedUserCard({required this.user});

  final PostUser user;

  @override
  Widget build(BuildContext context) {
    final hasImage = user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty;

    return Container(
      width: 166,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: InstagramColors.elevatedSurface(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF272D37)),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(
              Icons.close,
              color: Color(0xD9FFFFFF),
              size: 18,
            ),
          ),
          ClipOval(
            child: Container(
              width: 76,
              height: 76,
              color: const Color(0xFFE9EDF4),
              child: hasImage
                  ? Image.network(user.profileImageUrl!, fit: BoxFit.cover)
                  : const Icon(
                      Icons.person,
                      color: Color(0xFF7B838F),
                      size: 42,
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            user.username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: InstagramColors.textPrimary(context),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Suggested for you',
            style: TextStyle(color: Color(0xFFA8ADB7), fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _EmptyFeedState extends StatelessWidget {
  const _EmptyFeedState();

  @override
  Widget build(BuildContext context) {
    final primaryText = InstagramColors.textPrimary(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, color: primaryText, size: 48),
          const SizedBox(height: 16),
          Text('No posts yet', style: TextStyle(color: primaryText)),
        ],
      ),
    );
  }
}
