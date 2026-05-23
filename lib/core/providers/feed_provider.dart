import 'package:flutter/foundation.dart';
import '../../models/post.dart';
import '../../services/feed_api_service.dart';

enum FeedStatus {
  initial,
  loading,
  success,
  error,
}

class FeedProvider with ChangeNotifier {
  FeedProvider({
    required this.apiService,
  });

  final FeedApiService apiService;

  List<Post> _posts = [];
  FeedStatus _status = FeedStatus.initial;
  String? _errorMessage;
  bool _isAuthError = false;
  final Set<int> _pendingLikePostIds = {};
  final Set<int> _pendingCommentPostIds = {};

  List<Post> get posts => _posts;
  FeedStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == FeedStatus.loading;
  bool get hasError => _status == FeedStatus.error;
  bool get isAuthError => _isAuthError;
  bool isLikePending(int postId) => _pendingLikePostIds.contains(postId);
  bool isCommentPending(int postId) => _pendingCommentPostIds.contains(postId);

  Future<void> loadFeed() async {
    _status = FeedStatus.loading;
    _errorMessage = null;
    _isAuthError = false;
    notifyListeners();

    try {
      final backendPosts = await apiService.getFeed();
      _posts = backendPosts.isNotEmpty ? backendPosts : await apiService.getDemoFeed();
      _status = FeedStatus.success;
    } on FeedApiException catch (e) {
      if (e.isAuthError) {
        _status = FeedStatus.error;
        _isAuthError = true;
        _errorMessage = e.message;
        _posts = [];
      } else {
        await _loadDemoFallback();
      }
    } catch (e) {
      await _loadDemoFallback();
    }

    notifyListeners();
  }

  Future<void> _loadDemoFallback() async {
    try {
      _posts = await apiService.getDemoFeed();
      _status = FeedStatus.success;
      _errorMessage = null;
      _isAuthError = false;
    } catch (demoError) {
      _status = FeedStatus.error;
      _errorMessage = demoError.toString();
      _posts = [];
    }
  }

  Future<void> refreshFeed() async {
    await loadFeed();
  }

  Future<void> toggleLike(int postId) async {
    if (_pendingLikePostIds.contains(postId)) {
      return;
    }

    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) {
      return;
    }

    final originalPost = _posts[postIndex];
    final shouldLike = !originalPost.isLiked;

    _pendingLikePostIds.add(postId);
    _posts[postIndex] = originalPost.copyWith(
      isLiked: shouldLike,
      likesCount: shouldLike
          ? originalPost.likesCount + 1
          : originalPost.likesCount > 0
              ? originalPost.likesCount - 1
              : 0,
    );
    notifyListeners();

    if (originalPost.isDemo) {
      _pendingLikePostIds.remove(postId);
      notifyListeners();
      return;
    }

    try {
      final result = await apiService.likePost(postId, isLike: shouldLike);

      if (result['status'] == 'success') {
        final likesCount = result['likes_count'];
        final isLiked = result['is_liked'];
        _posts[postIndex] = _posts[postIndex].copyWith(
          likesCount: likesCount as int? ?? _posts[postIndex].likesCount,
          isLiked: isLiked as bool? ?? shouldLike,
        );
      }
    } on FeedApiException catch (e) {
      _posts[postIndex] = originalPost;
      _errorMessage = e.message;
      _isAuthError = e.isAuthError;
      debugPrint('Error toggling post like: $e');
    } catch (e) {
      _posts[postIndex] = originalPost;
      _errorMessage = e.toString();
      debugPrint('Error toggling post like: $e');
    } finally {
      _pendingLikePostIds.remove(postId);
      notifyListeners();
    }
  }

  Future<void> addComment({
    required int postId,
    required String text,
    required String currentUsername,
  }) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty || _pendingCommentPostIds.contains(postId)) {
      return;
    }

    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) {
      return;
    }

    final originalPost = _posts[postIndex];
    final optimisticComment = PostComment(
      id: -DateTime.now().microsecondsSinceEpoch,
      user: PostUser(
        id: 0,
        username: currentUsername,
        email: '',
      ),
      text: trimmedText,
      createdAt: DateTime.now(),
    );

    _pendingCommentPostIds.add(postId);
    _posts[postIndex] = originalPost.copyWith(
      comments: [...originalPost.comments, optimisticComment],
      commentsCount: originalPost.commentsCount + 1,
    );
    notifyListeners();

    if (originalPost.isDemo) {
      _pendingCommentPostIds.remove(postId);
      notifyListeners();
      return;
    }

    try {
      final savedComment = await apiService.addComment(postId, text: trimmedText);
      final currentPost = _posts[postIndex];
      final updatedComments = currentPost.comments.map((comment) {
        return comment.id == optimisticComment.id ? savedComment : comment;
      }).toList();

      _posts[postIndex] = currentPost.copyWith(
        comments: updatedComments,
        commentsCount: updatedComments.length,
      );
    } on FeedApiException catch (e) {
      _posts[postIndex] = originalPost;
      _errorMessage = e.message;
      _isAuthError = e.isAuthError;
      debugPrint('Error adding post comment: $e');
      rethrow;
    } catch (e) {
      _posts[postIndex] = originalPost;
      _errorMessage = e.toString();
      debugPrint('Error adding post comment: $e');
      rethrow;
    } finally {
      _pendingCommentPostIds.remove(postId);
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    _isAuthError = false;
    _status = FeedStatus.initial;
    notifyListeners();
  }
}
