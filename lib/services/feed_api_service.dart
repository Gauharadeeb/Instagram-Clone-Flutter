import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/post.dart';
import 'base_api_service.dart';
import 'token_storage_service.dart';

class FeedApiException implements Exception {
  const FeedApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class FeedApiService extends BaseApiService {
  FeedApiService({
    super.client,
    super.baseUrl,
  });

  final http.Client _publicClient = http.Client();
  final TokenStorageService _tokenStorage = TokenStorageService();

  // Get all posts for home feed
  Future<List<Post>> getFeed() async {
    try {
      final response = await get<List<dynamic>>(
        '/feed/',
        requireAuth: true,
        fromJson: (data) {
          if (data is List) {
            return data;
          }
          return [];
        },
      );

      return response.map((json) => Post.fromJson(json as Map<String, dynamic>)).toList();
    } on ApiException catch (e) {
      throw FeedApiException(e.message);
    } catch (e) {
      throw FeedApiException('Network error: $e');
    }
  }

  Future<List<Post>> getDemoFeed() async {
    try {
      final postsResponse = await _publicClient
          .get(Uri.parse('https://dummyjson.com/posts?limit=12'))
          .timeout(const Duration(seconds: 15));
      final usersResponse = await _publicClient
          .get(Uri.parse('https://dummyjson.com/users?limit=20'))
          .timeout(const Duration(seconds: 15));

      if (postsResponse.statusCode < 200 ||
          postsResponse.statusCode >= 300 ||
          usersResponse.statusCode < 200 ||
          usersResponse.statusCode >= 300) {
        throw const FeedApiException('Could not load demo feed');
      }

      final postsData = jsonDecode(postsResponse.body) as Map<String, dynamic>;
      final usersData = jsonDecode(usersResponse.body) as Map<String, dynamic>;
      final demoPosts = postsData['posts'] as List<dynamic>? ?? [];
      final demoUsers = usersData['users'] as List<dynamic>? ?? [];
      final usersById = <int, Map<String, dynamic>>{};

      for (final userJson in demoUsers) {
        if (userJson is Map<String, dynamic>) {
          final id = userJson['id'];
          if (id is int) {
            usersById[id] = userJson;
          }
        }
      }

      return demoPosts
          .whereType<Map<String, dynamic>>()
          .map((postJson) => _demoPostFromJson(postJson, usersById))
          .toList();
    } on FeedApiException {
      rethrow;
    } catch (e) {
      throw FeedApiException('Demo feed error: $e');
    }
  }

  Future<List<PostUser>> getSuggestedUsers() async {
    try {
      final response = await get<Map<String, dynamic>>(
        '/api/auth/users/',
        requireAuth: true,
        fromJson: (data) {
          if (data is Map<String, dynamic>) {
            return data;
          }
          return {};
        },
      );
      final users = response['users'] as List<dynamic>? ?? [];

      return users
          .whereType<Map<String, dynamic>>()
          .map(PostUser.fromJson)
          .toList();
    } on ApiException catch (e) {
      throw FeedApiException(e.message);
    } catch (e) {
      throw FeedApiException('Suggested users error: $e');
    }
  }

  Post _demoPostFromJson(
    Map<String, dynamic> postJson,
    Map<int, Map<String, dynamic>> usersById,
  ) {
    final postId = postJson['id'] as int? ?? 0;
    final userId = postJson['userId'] as int? ?? 1;
    final userJson = usersById[userId] ?? const <String, dynamic>{};
    final username = userJson['username'] as String? ?? 'instagram_user_$userId';
    final reactions = postJson['reactions'];
    final likes = reactions is Map<String, dynamic>
        ? reactions['likes'] as int? ?? 0
        : postJson['reactions'] as int? ?? 0;
    final createdAt = DateTime.now().subtract(Duration(hours: postId + 1));
    final commentsCount = ((postJson['views'] as int? ?? postId * 17) % 86) + 3;

    return Post(
      id: -postId,
      user: PostUser(
        id: -userId,
        username: username,
        email: userJson['email'] as String? ?? '',
        firstName: userJson['firstName'] as String?,
        lastName: userJson['lastName'] as String?,
        profileImageUrl: userJson['image'] as String?,
      ),
      image: '',
      imageUrl: 'https://picsum.photos/600/600?random=$postId',
      caption: (postJson['body'] as String?) ?? (postJson['title'] as String?) ?? '',
      likesCount: likes,
      isLiked: false,
      comments: _demoCommentsForPost(postId, usersById),
      commentsCount: commentsCount,
      isDemo: true,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  List<PostComment> _demoCommentsForPost(
    int postId,
    Map<int, Map<String, dynamic>> usersById,
  ) {
    final userIds = usersById.keys.take(3).toList();

    return userIds.map((userId) {
      final userJson = usersById[userId] ?? const <String, dynamic>{};
      return PostComment(
        id: -(postId * 100 + userId),
        user: PostUser(
          id: -userId,
          username: userJson['username'] as String? ?? 'friend_$userId',
          email: userJson['email'] as String? ?? '',
          firstName: userJson['firstName'] as String?,
          lastName: userJson['lastName'] as String?,
          profileImageUrl: userJson['image'] as String?,
        ),
        text: _demoCommentText(postId, userId),
        createdAt: DateTime.now().subtract(Duration(minutes: postId + userId)),
      );
    }).toList();
  }

  String _demoCommentText(int postId, int userId) {
    final options = [
      'This is such a good post',
      'Love this vibe',
      'Amazing shot',
      'So beautiful',
      'Need more like this',
    ];
    return options[(postId + userId) % options.length];
  }

  // Like or unlike a post
  Future<Map<String, dynamic>> likePost(int postId, {required bool isLike}) async {
    try {
      final response = await post<Map<String, dynamic>>(
        '/posts/$postId/like/',
        body: {
          'action': isLike ? 'like' : 'unlike',
        },
        requireAuth: true,
        fromJson: (data) {
          if (data is Map<String, dynamic>) {
            return data;
          }
          return {};
        },
      );

      return response;
    } on ApiException catch (e) {
      throw FeedApiException(e.message);
    } catch (e) {
      throw FeedApiException('Network error: $e');
    }
  }

  // Add a comment to a post
  Future<PostComment> addComment(int postId, {required String text}) async {
    try {
      final response = await post<Map<String, dynamic>>(
        '/posts/$postId/comments/',
        body: {
          'text': text,
        },
        requireAuth: true,
        fromJson: (data) {
          if (data is Map<String, dynamic>) {
            return data;
          }
          return {};
        },
      );

      return PostComment.fromJson(response);
    } on ApiException catch (e) {
      throw FeedApiException(e.message);
    } catch (e) {
      throw FeedApiException('Network error: $e');
    }
  }

  Future<Post> createPost({
    required String imagePath,
    required String caption,
  }) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/posts/create/'),
      );

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['caption'] = caption;
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      final streamedResponse = await request.send().timeout(const Duration(seconds: 45));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      }

      if (response.statusCode == 401) {
        throw const FeedApiException('Authentication required. Please login again.');
      }

      throw FeedApiException('Upload failed with status ${response.statusCode}');
    } on FeedApiException {
      rethrow;
    } on FileSystemException catch (e) {
      throw FeedApiException('Image file error: ${e.message}');
    } catch (e) {
      throw FeedApiException('Upload error: $e');
    }
  }

  // Get single post details
  Future<Post> getPostDetail(int postId) async {
    try {
      final response = await get<Map<String, dynamic>>(
        '/posts/$postId/',
        requireAuth: true,
        fromJson: (data) {
          if (data is Map<String, dynamic>) {
            return data;
          }
          return {};
        },
      );

      return Post.fromJson(response);
    } on ApiException catch (e) {
      throw FeedApiException(e.message);
    } catch (e) {
      throw FeedApiException('Network error: $e');
    }
  }
}
