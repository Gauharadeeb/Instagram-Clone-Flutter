import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/constants/app_colors.dart';
import '../models/post.dart';
import '../services/feed_api_service.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.currentUsername,
    required this.suggestedUsers,
    required this.onToggleLike,
    required this.onAddComment,
    this.isLikePending = false,
    this.isCommentPending = false,
  });

  final Post post;
  final String currentUsername;
  final List<PostUser> suggestedUsers;
  final VoidCallback onToggleLike;
  final Future<void> Function(String text) onAddComment;
  final bool isLikePending;
  final bool isCommentPending;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: InstagramColors.background(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(user: widget.post.user),
          _PostImage(imageUrl: widget.post.imageUrl),
          _PostActions(
            isLiked: widget.post.isLiked,
            isLikePending: widget.isLikePending,
            onToggleLike: widget.onToggleLike,
            onComment: _showCommentsSheet,
            onShare: _showShareSheet,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '${_formatLikes(widget.post.likesCount)} likes',
              style: TextStyle(
                color: InstagramColors.textPrimary(context),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          if (widget.post.caption.isNotEmpty) ...[
            const SizedBox(height: 7),
            _UsernameTextLine(
              username: widget.post.user.username,
              text: widget.post.caption,
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 13),
            child: Text(
              _formatDate(widget.post.createdAt),
              style: TextStyle(color: InstagramColors.textSecondary(context), fontSize: 11),
            ),
          ),
          Divider(height: 1, color: InstagramColors.border(context)),
        ],
      ),
    );
  }

  void _showCommentsSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return _CommentsSheet(
          post: widget.post,
          currentUsername: widget.currentUsername,
          onAddComment: widget.onAddComment,
        );
      },
    );
  }

  void _showShareSheet() {
    final users = _shareUsers();

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _ShareSheet(
        post: widget.post,
        initialUsers: users,
      ),
    );
  }

  List<PostUser> _shareUsers() {
    final users = <PostUser>[];
    final seen = <int>{widget.post.user.id};

    for (final user in widget.suggestedUsers) {
      if (seen.add(user.id)) {
        users.add(user);
      }
      if (users.length == 9) {
        break;
      }
    }

    if (users.length >= 6) {
      return users;
    }

    final filledUsers = [...users];
    final fallbackNames = [
      'alex.photo',
      'maya.daily',
      'sam.frames',
      'nina.travel',
      'dev.studio',
      'riya.edits',
      'karan.life',
      'zoe.visuals',
      'noahstreet',
    ];

    for (var index = 0; filledUsers.length < 9; index++) {
      final id = -9000 - index;
      if (filledUsers.any((user) => user.id == id)) {
        continue;
      }
      filledUsers.add(
        PostUser(
          id: id,
          username: fallbackNames[index % fallbackNames.length],
          email: '',
          profileImageUrl: 'https://i.pravatar.cc/150?img=${index + 12}',
        ),
      );
    }

    return filledUsers;
  }

  String _formatLikes(int likes) {
    if (likes >= 1000000) {
      return '${(likes / 1000000).toStringAsFixed(1)}M';
    }
    if (likes >= 1000) {
      return '${(likes / 1000).toStringAsFixed(1)}K';
    }
    return likes.toString();
  }

  String _formatDate(DateTime date) {
    final difference = DateTime.now().difference(date.toLocal());

    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }
    return DateFormat('MMM d, yyyy').format(date.toLocal());
  }
}

class _PostHeader extends StatelessWidget {
  const _PostHeader({required this.user});

  final PostUser user;

  @override
  Widget build(BuildContext context) {
    final primaryText = InstagramColors.textPrimary(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
      child: Row(
        children: [
          _ProfileImage(imageUrl: user.profileImageUrl, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              user.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: primaryText,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            tooltip: 'More',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
            icon: Icon(Icons.more_horiz, color: primaryText, size: 24),
          ),
        ],
      ),
    );
  }
}

class _PostActions extends StatelessWidget {
  const _PostActions({
    required this.isLiked,
    required this.isLikePending,
    required this.onToggleLike,
    required this.onComment,
    required this.onShare,
  });

  final bool isLiked;
  final bool isLikePending;
  final VoidCallback onToggleLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 2),
      child: Row(
        children: [
          _ActionIconButton(
            tooltip: isLiked ? 'Unlike' : 'Like',
            onPressed: isLikePending ? null : onToggleLike,
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? InstagramColors.likeRed : InstagramColors.icon(context),
              size: 27,
            ),
          ),
          _ActionIconButton(
            tooltip: 'Comment',
            onPressed: onComment,
            icon: Icon(Icons.mode_comment_outlined, color: InstagramColors.icon(context), size: 25),
          ),
          _ActionIconButton(
            tooltip: 'Share',
            onPressed: onShare,
            icon: Icon(Icons.send_outlined, color: InstagramColors.icon(context), size: 25),
          ),
          const Spacer(),
          _ActionIconButton(
            tooltip: 'Save',
            onPressed: () {},
            icon: Icon(Icons.bookmark_border, color: InstagramColors.icon(context), size: 27),
          ),
        ],
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 40, height: 40),
      icon: icon,
    );
  }
}

class _CommentsSheet extends StatefulWidget {
  const _CommentsSheet({
    required this.post,
    required this.currentUsername,
    required this.onAddComment,
  });

  final Post post;
  final String currentUsername;
  final Future<void> Function(String text) onAddComment;

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late List<PostComment> _comments;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _comments = List<PostComment>.from(widget.post.comments);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: FractionallySizedBox(
        heightFactor: 0.88,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: InstagramColors.modal(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const _CommentsSheetHeader(),
                Divider(height: 1, color: InstagramColors.border(context)),
                Expanded(
                  child: _comments.isEmpty
                      ? const _NoCommentsState()
                      : ListView.separated(
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          padding: const EdgeInsets.fromLTRB(16, 14, 12, 16),
                          itemCount: _comments.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 18),
                          itemBuilder: (context, index) {
                            return _CommentTile(comment: _comments[index]);
                          },
                        ),
                ),
                Divider(height: 1, color: InstagramColors.border(context)),
                _CommentComposer(
                  controller: _controller,
                  focusNode: _focusNode,
                  username: widget.currentUsername,
                  isSubmitting: _isSubmitting,
                  onSend: _submitComment,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSubmitting) {
      return;
    }

    final optimisticComment = PostComment(
      id: -DateTime.now().microsecondsSinceEpoch,
      user: PostUser(
        id: 0,
        username: widget.currentUsername,
        email: '',
      ),
      text: text,
      createdAt: DateTime.now(),
    );

    setState(() {
      _isSubmitting = true;
      _comments.add(optimisticComment);
      _controller.clear();
    });

    try {
      await widget.onAddComment(text);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _comments.removeWhere((comment) => comment.id == optimisticComment.id);
        _controller.text = text;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not post comment')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _CommentsSheetHeader extends StatelessWidget {
  const _CommentsSheetHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 9, 16, 12),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF737A86),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Comments',
            style: TextStyle(
              color: InstagramColors.textPrimary(context),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoCommentsState extends StatelessWidget {
  const _NoCommentsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No comments yet',
        style: TextStyle(
          color: InstagramColors.textSecondary(context),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.comment});

  final PostComment comment;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfileImage(imageUrl: comment.user.profileImageUrl, size: 42),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: comment.user.username,
                      style: TextStyle(
                        color: InstagramColors.textPrimary(context),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const TextSpan(text: '  '),
                    TextSpan(
                      text: _formatShortTime(comment.createdAt),
                      style: TextStyle(
                        color: InstagramColors.textSecondary(context),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Text(
                comment.text,
                style: TextStyle(
                  color: InstagramColors.textPrimary(context),
                  fontSize: 15,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Reply',
                style: TextStyle(
                  color: InstagramColors.textSecondary(context),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Icon(Icons.favorite_border, color: Color(0xFFC5CAD3), size: 22),
        ),
      ],
    );
  }

  String _formatShortTime(DateTime date) {
    final difference = DateTime.now().difference(date.toLocal());

    if (difference.inMinutes < 1) {
      return 'now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours}h';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d';
    }
    return '${(difference.inDays / 7).floor()}w';
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer({
    required this.controller,
    required this.focusNode,
    required this.username,
    required this.isSubmitting,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String username;
  final bool isSubmitting;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Column(
        children: [
          const _EmojiQuickBar(),
          const SizedBox(height: 10),
          Row(
            children: [
              _ProfileImage(imageUrl: null, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  enabled: !isSubmitting,
                  cursorColor: InstagramColors.textPrimary(context),
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  style: TextStyle(color: InstagramColors.textPrimary(context), fontSize: 14),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: InstagramColors.elevatedSurface(context),
                    hintText: 'Join the conversation...',
                    hintStyle: TextStyle(
                      color: InstagramColors.textSecondary(context),
                      fontSize: 14,
                    ),
                    suffixIcon: IconButton(
                      onPressed: isSubmitting ? null : onSend,
                      tooltip: 'Post',
                      icon: isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.arrow_upward_rounded),
                      color: const Color(0xFF4DA3FF),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Color(0xFF343B46)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Color(0xFF343B46)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Color(0xFF576170)),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(color: Color(0xFF343B46)),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.fromLTRB(15, 11, 8, 11),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmojiQuickBar extends StatelessWidget {
  const _EmojiQuickBar();

  static const _emojis = [
    '\u2764\uFE0F',
    '\u{1F64C}',
    '\u{1F525}',
    '\u{1F44F}',
    '\u{1F622}',
    '\u{1F60D}',
    '\u{1F62E}',
    '\u{1F602}',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _emojis.length,
        separatorBuilder: (_, __) => const SizedBox(width: 24),
        itemBuilder: (context, index) {
          return Center(
            child: Text(
              _emojis[index],
              style: const TextStyle(fontSize: 24),
            ),
          );
        },
      ),
    );
  }
}

class _UsernameTextLine extends StatelessWidget {
  const _UsernameTextLine({
    required this.username,
    required this.text,
  });

  final String username;
  final String text;

  @override
  Widget build(BuildContext context) {
    final primaryText = InstagramColors.textPrimary(context);
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: username,
            style: TextStyle(
              color: primaryText,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const TextSpan(text: ' '),
          TextSpan(
            text: text,
            style: TextStyle(
              color: primaryText,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareSheet extends StatefulWidget {
  const _ShareSheet({
    required this.post,
    required this.initialUsers,
  });

  final Post post;
  final List<PostUser> initialUsers;

  @override
  State<_ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<_ShareSheet> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final Set<int> _selectedUserIds = {};

  late List<PostUser> _users;

  bool _isLoadingUsers = true;
  bool _isSending = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _users = _dedupeUsers(widget.initialUsers);
    _loadSuggestedUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final filteredUsers = _filteredUsers();

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: FractionallySizedBox(
        heightFactor: 0.86,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: InstagramColors.modal(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const _ShareHeader(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
                  child: _ShareSearchField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                  ),
                ),
                Expanded(
                  child: _isLoadingUsers && _users.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : filteredUsers.isEmpty
                          ? const Center(
                              child: Text(
                                'No users found',
                                style: TextStyle(color: Color(0xFFA8ADB7)),
                              ),
                            )
                          : GridView.builder(
                              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisExtent: 118,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = filteredUsers[index];
                                final isSelected = _selectedUserIds.contains(user.id);

                                return _SelectableShareUser(
                                  user: user,
                                  isSelected: isSelected,
                                  onTap: () => _toggleUser(user.id),
                                );
                              },
                            ),
                ),
                Divider(height: 1, color: InstagramColors.border(context)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Column(
                    children: [
                      _ShareMessageField(controller: _messageController),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: FilledButton(
                          onPressed: _selectedUserIds.isEmpty || _isSending ? null : _sendShare,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0095F6),
                            disabledBackgroundColor: const Color(0xFF26303B),
                            foregroundColor: Colors.white,
                            disabledForegroundColor: const Color(0xFF9AA3AF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          child: _isSending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  _selectedUserIds.isEmpty
                                      ? 'Send'
                                      : 'Send to ${_selectedUserIds.length}',
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadSuggestedUsers() async {
    try {
      final backendUsers = await FeedApiService().getSuggestedUsers();
      if (!mounted) {
        return;
      }
      setState(() {
        _users = _dedupeUsers([...backendUsers, ..._users]);
        _isLoadingUsers = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _users = _dedupeUsers(_users);
        _isLoadingUsers = false;
      });
    }
  }

  List<PostUser> _filteredUsers() {
    final normalizedQuery = _query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return _users;
    }

    return _users.where((user) {
      final fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();
      return user.username.toLowerCase().contains(normalizedQuery) ||
          fullName.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  List<PostUser> _dedupeUsers(List<PostUser> users) {
    final seen = <String>{};
    final result = <PostUser>[];

    for (final user in users) {
      final key = '${user.id}:${user.username.toLowerCase()}';
      if (seen.add(key)) {
        result.add(user);
      }
      if (result.length == 30) {
        break;
      }
    }

    return result;
  }

  void _toggleUser(int userId) {
    setState(() {
      if (!_selectedUserIds.add(userId)) {
        _selectedUserIds.remove(userId);
      }
    });
  }

  Future<void> _sendShare() async {
    setState(() => _isSending = true);

    try {
      await _sendPostLocally(
        postId: widget.post.id,
        recipientIds: _selectedUserIds.toList(),
        message: _messageController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedUserIds.length == 1
                ? 'Sent'
                : 'Sent to ${_selectedUserIds.length} people',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not send post')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  Future<void> _sendPostLocally({
    required int postId,
    required List<int> recipientIds,
    required String message,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
  }
}

class _ShareHeader extends StatelessWidget {
  const _ShareHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 9, 16, 12),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF737A86),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            'Share',
            style: TextStyle(
              color: InstagramColors.textPrimary(context),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Send this post to friends',
            style: TextStyle(
              color: InstagramColors.textSecondary(context),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareSearchField extends StatelessWidget {
  const _ShareSearchField({
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      cursorColor: InstagramColors.textPrimary(context),
      style: TextStyle(color: InstagramColors.textPrimary(context), fontSize: 14),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search, color: InstagramColors.textSecondary(context), size: 21),
        hintText: 'Search',
        hintStyle: TextStyle(color: InstagramColors.textSecondary(context), fontSize: 14),
        filled: true,
        fillColor: InstagramColors.elevatedSurface(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF3B4450)),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 11),
      ),
    );
  }
}

class _SelectableShareUser extends StatelessWidget {
  const _SelectableShareUser({
    required this.user,
    required this.isSelected,
    required this.onTap,
  });

  final PostUser user;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fullName = '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _ProfileImage(imageUrl: user.profileImageUrl, size: 58),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0095F6) : const Color(0xFF202631),
                      shape: BoxShape.circle,
                      border: Border.all(color: InstagramColors.modal(context), width: 2),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 15)
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              fullName.isEmpty ? user.username : fullName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: InstagramColors.textPrimary(context),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              user.username,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: InstagramColors.textSecondary(context),
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareMessageField extends StatelessWidget {
  const _ShareMessageField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: InstagramColors.textPrimary(context),
      minLines: 1,
      maxLines: 3,
      style: TextStyle(color: InstagramColors.textPrimary(context), fontSize: 14),
      decoration: InputDecoration(
        hintText: 'Write a message...',
        hintStyle: TextStyle(color: InstagramColors.textSecondary(context), fontSize: 14),
        filled: true,
        fillColor: InstagramColors.elevatedSurface(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF3B4450)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _ProfileImage extends StatelessWidget {
  const _ProfileImage({
    required this.imageUrl,
    required this.size,
  });

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return ClipOval(
      child: Container(
        width: size,
        height: size,
        color: const Color(0xFFE9EDF4),
        child: hasImage
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _ProfileFallbackIcon(size: size * 0.6),
              )
            : _ProfileFallbackIcon(size: size * 0.6),
      ),
    );
  }
}

class _ProfileFallbackIcon extends StatelessWidget {
  const _ProfileFallbackIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.person,
      color: const Color(0xFF7B838F),
      size: size,
    );
  }
}

class _PostImage extends StatelessWidget {
  const _PostImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final secondaryText = InstagramColors.textSecondary(context);
    final elevatedSurface = InstagramColors.elevatedSurface(context);
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    if (!hasImage) {
      return _PostImageFrame(
        child: ColoredBox(
          color: elevatedSurface,
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: secondaryText,
              size: 44,
            ),
          ),
        ),
      );
    }

    return _PostImageFrame(
      child: Image.network(
        imageUrl!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return ColoredBox(
            color: elevatedSurface,
            child: Center(
              child: SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(InstagramColors.blue),
                ),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) {
          return ColoredBox(
            color: elevatedSurface,
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: secondaryText,
                size: 44,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PostImageFrame extends StatelessWidget {
  const _PostImageFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final height = (width * 1.25).clamp(280.0, 640.0).toDouble();

        return SizedBox(
          width: double.infinity,
          height: height,
          child: ClipRect(child: child),
        );
      },
    );
  }
}
