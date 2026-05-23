class Post {
  final int id;
  final PostUser user;
  final String image;
  final String? imageUrl;
  final String caption;
  final int likesCount;
  final bool isLiked;
  final List<PostComment> comments;
  final int commentsCount;
  final bool isDemo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.user,
    required this.image,
    this.imageUrl,
    required this.caption,
    required this.likesCount,
    required this.isLiked,
    this.comments = const [],
    this.commentsCount = 0,
    this.isDemo = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    final comments = (json['comments'] as List<dynamic>? ?? [])
        .map((comment) => PostComment.fromJson(comment as Map<String, dynamic>))
        .toList();

    return Post(
      id: json['id'] as int,
      user: PostUser.fromJson(json['user'] as Map<String, dynamic>),
      image: json['image'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      caption: json['caption'] as String? ?? '',
      likesCount: json['likes_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      comments: comments,
      commentsCount: json['comments_count'] as int? ?? comments.length,
      isDemo: json['is_demo'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'image': image,
      'image_url': imageUrl,
      'caption': caption,
      'likes_count': likesCount,
      'is_liked': isLiked,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'comments_count': commentsCount,
      'is_demo': isDemo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Post copyWith({
    int? id,
    PostUser? user,
    String? image,
    String? imageUrl,
    String? caption,
    int? likesCount,
    bool? isLiked,
    List<PostComment>? comments,
    int? commentsCount,
    bool? isDemo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      user: user ?? this.user,
      image: image ?? this.image,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      comments: comments ?? this.comments,
      commentsCount: commentsCount ?? this.commentsCount,
      isDemo: isDemo ?? this.isDemo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PostComment {
  final int id;
  final PostUser user;
  final String text;
  final DateTime createdAt;

  PostComment({
    required this.id,
    required this.user,
    required this.text,
    required this.createdAt,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'] as int,
      user: PostUser.fromJson(json['user'] as Map<String, dynamic>),
      text: json['text'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'text': text,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class PostUser {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? profileImageUrl;

  PostUser({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.profileImageUrl,
  });

  factory PostUser.fromJson(Map<String, dynamic> json) {
    return PostUser(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'profile_image_url': profileImageUrl,
    };
  }
}
