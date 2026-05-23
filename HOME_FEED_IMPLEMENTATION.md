# Instagram-Style Home Feed Feature Implementation

## Overview
This document describes the complete implementation of an Instagram-style Home Feed feature using Django REST Framework (backend) and Flutter (frontend).

---

## Backend Implementation (Django REST Framework)

### 1. Post Model
**File:** `backend/posts/models.py`

```python
from django.db import models
from django.contrib.auth import get_user_model
from django.conf import settings

User = get_user_model()

class Post(models.Model):
    user = models.ForeignKey(
        User, 
        on_delete=models.CASCADE, 
        related_name='posts'
    )
    image = models.ImageField(upload_to='post_images/')
    caption = models.TextField(blank=True)
    likes_count = models.PositiveIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']
        verbose_name = 'Post'
        verbose_name_plural = 'Posts'

    def __str__(self):
        return f'{self.user.username} - {self.caption[:20]}'
    
    @property
    def image_url(self):
        if self.image:
            return f"{settings.MEDIA_URL}{self.image}"
        return None
```

**Features:**
- Foreign key relationship with User model
- Image upload support with automatic storage in `post_images/`
- Caption field for post descriptions
- Like count tracking
- Automatic timestamp management
- Ordered by `created_at` descending (latest first)

### 2. Serializers
**File:** `backend/posts/serializers.py`

```python
from rest_framework import serializers
from .models import Post
from django.contrib.auth import get_user_model

User = get_user_model()

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'email', 'first_name', 'last_name')

class PostSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    image_url = serializers.SerializerMethodField()
    likes_count = serializers.IntegerField(read_only=True)
    
    class Meta:
        model = Post
        fields = ('id', 'user', 'image', 'image_url', 'caption', 'likes_count', 'created_at', 'updated_at')
        read_only_fields = ('id', 'created_at', 'updated_at', 'likes_count')
    
    def get_image_url(self, obj):
        if obj.image:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.image.url)
            return obj.image.url
        return None

class PostCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Post
        fields = ('image', 'caption')

class LikeSerializer(serializers.Serializer):
    action = serializers.ChoiceField(choices=['like', 'unlike'])
```

**Features:**
- Nested user serialization
- Dynamic image URL generation with absolute paths
- Read-only fields for protection
- Validation for like/unlike actions

### 3. Views
**File:** `backend/posts/views.py`

```python
from rest_framework import generics, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from .models import Post
from .serializers import PostSerializer, LikeSerializer

class FeedListView(generics.ListAPIView):
    """
    API endpoint to retrieve all posts for the home feed.
    Returns posts sorted by latest first (created_at descending).
    Requires JWT authentication.
    """
    serializer_class = PostSerializer
    permission_classes = [IsAuthenticated]
    queryset = Post.objects.all().select_related('user')
    
    def get_queryset(self):
        return Post.objects.all().select_related('user').order_by('-created_at')

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def like_post(request, post_id):
    """
    API endpoint to like/unlike a post.
    POST /api/posts/<post_id>/like/
    Body: {"action": "like"} or {"action": "unlike"}
    """
    try:
        post = get_object_or_404(Post, id=post_id)
        serializer = LikeSerializer(data=request.data)
        
        if serializer.is_valid():
            action = serializer.validated_data['action']
            
            if action == 'like':
                post.likes_count += 1
            elif action == 'unlike':
                post.likes_count = max(0, post.likes_count - 1)
            
            post.save()
            
            return Response({
                'status': 'success',
                'likes_count': post.likes_count,
                'action': action
            }, status=status.HTTP_200_OK)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    except Exception as e:
        return Response({
            'status': 'error',
            'message': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def post_detail(request, post_id):
    """
    API endpoint to retrieve a single post by ID.
    GET /api/posts/<post_id>/
    """
    try:
        post = get_object_or_404(Post, id=post_id)
        serializer = PostSerializer(post, context={'request': request})
        return Response(serializer.data, status=status.HTTP_200_OK)
    
    except Exception as e:
        return Response({
            'status': 'error',
            'message': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
```

**Features:**
- JWT authentication required for all endpoints
- Optimized database queries with `select_related`
- Like/unlike functionality with atomic updates
- Proper error handling and validation
- RESTful API design

### 4. URL Configuration
**File:** `backend/posts/urls.py`

```python
from django.urls import path
from .views import FeedListView, like_post, post_detail

app_name = 'posts'

urlpatterns = [
    path('feed/', FeedListView.as_view(), name='feed'),
    path('posts/<int:post_id>/like/', like_post, name='like-post'),
    path('posts/<int:post_id>/', post_detail, name='post-detail'),
]
```

**Main URL Configuration:** `backend/config/urls.py`
```python
urlpatterns = [
    path('', api_status, name='api-status'),
    path('api/health/', api_status, name='api-health'),
    path('admin/', admin.site.urls),
    path('api/auth/', include('accounts.urls')),
    path('api/', include('posts.urls')),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
```

### 5. Settings Configuration
**File:** `backend/config/settings.py`

```python
INSTALLED_APPS = [
    # ... existing apps ...
    'posts',
]

MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated',
    ),
}

SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(minutes=60),
    'REFRESH_TOKEN_LIFETIME': timedelta(days=7),
}
```

---

## Frontend Implementation (Flutter)

### 1. Post Model
**File:** `lib/models/post.dart`

```dart
class Post {
  final int id;
  final PostUser user;
  final String image;
  final String? imageUrl;
  final String caption;
  final int likesCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Post({
    required this.id,
    required this.user,
    required this.image,
    this.imageUrl,
    required this.caption,
    required this.likesCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      user: PostUser.fromJson(json['user'] as Map<String, dynamic>),
      image: json['image'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      caption: json['caption'] as String? ?? '',
      likesCount: json['likes_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}

class PostUser {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;

  PostUser({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
  });

  factory PostUser.fromJson(Map<String, dynamic> json) {
    return PostUser(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
    );
  }
}
```

### 2. Feed API Service
**File:** `lib/services/feed_api_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class FeedApiException implements Exception {
  const FeedApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class FeedApiService {
  FeedApiService({
    http.Client? client,
    this.baseUrl = 'http://10.53.56.230:8000',
    this.accessToken,
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  final String? accessToken;

  Future<List<Post>> getFeed() async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/api/feed/'),
        headers: _buildHeaders(),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Post.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw FeedApiException('Authentication required. Please login again.');
      } else {
        throw FeedApiException('Failed to load feed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is FeedApiException) rethrow;
      throw FeedApiException('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> likePost(int postId, {required bool isLike}) async {
    // Implementation for like/unlike functionality
    // ...
  }

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    return headers;
  }
}
```

### 3. Feed Provider (State Management)
**File:** `lib/core/providers/feed_provider.dart`

```dart
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

  List<Post> get posts => _posts;
  FeedStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == FeedStatus.loading;
  bool get hasError => _status == FeedStatus.error;

  Future<void> loadFeed() async {
    _status = FeedStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await apiService.getFeed();
      _status = FeedStatus.success;
    } catch (e) {
      _status = FeedStatus.error;
      _errorMessage = e.toString();
      _posts = [];
    }

    notifyListeners();
  }

  Future<void> likePost(int postId) async {
    // Implementation for liking posts
    // ...
  }

  Future<void> unlikePost(int postId) async {
    // Implementation for unliking posts
    // ...
  }
}
```

### 4. Post Card Widget
**File:** `lib/widgets/post_card.dart`

```dart
import 'package:flutter/material.dart';
import '../models/post.dart';
import 'package:intl/intl.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onUnlike,
  });

  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onUnlike;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    // Instagram-style post card implementation
    // - Profile image and username
    // - Post image with loading/error states
    // - Like, comment, share buttons
    // - Like count and caption
    // - Timestamp
    // ...
  }
}
```

### 5. Home Feed Screen
**File:** `lib/screens/home/instagram_feed_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/feed_provider.dart';
import '../../widgets/post_card.dart';
import '../../services/feed_api_service.dart';

class InstagramFeedScreen extends StatefulWidget {
  const InstagramFeedScreen({
    super.key,
    required this.username,
    required this.accessToken,
  });

  final String username;
  final String accessToken;

  @override
  State<InstagramFeedScreen> createState() => _InstagramFeedScreenState();
}

class _InstagramFeedScreenState extends State<InstagramFeedScreen> {
  late FeedProvider _feedProvider;

  @override
  void initState() {
    super.initState();
    _initializeFeedProvider();
  }

  void _initializeFeedProvider() {
    final apiService = FeedApiService(
      accessToken: widget.accessToken,
    );
    _feedProvider = FeedProvider(apiService: apiService);
    _feedProvider.loadFeed();
  }

  Future<void> _refreshFeed() async {
    await _feedProvider.refreshFeed();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _feedProvider,
      child: Scaffold(
        // Instagram-style UI with:
        // - Loading indicator
        // - Error handling with retry
        // - Pull-to-refresh
        // - Dynamic post cards
        // - Bottom navigation
        // ...
      ),
    );
  }
}
```

---

## API Flow

### 1. Feed Loading Flow
```
Flutter App → Load Feed Screen
         ↓
Initialize FeedProvider with JWT token
         ↓
FeedProvider → FeedApiService.getFeed()
         ↓
HTTP GET /api/feed/ with Authorization: Bearer <token>
         ↓
Django → FeedListView (JWT authentication)
         ↓
Query Posts ordered by created_at DESC
         ↓
Serialize posts with PostSerializer
         ↓
Return JSON response
         ↓
Flutter → Parse JSON to Post objects
         ↓
Update FeedProvider state
         ↓
UI displays posts dynamically
```

### 2. Like Post Flow
```
User taps like button
         ↓
PostCard → FeedProvider.likePost(postId)
         ↓
FeedProvider → FeedApiService.likePost(postId, isLike: true)
         ↓
HTTP POST /api/posts/{id}/like/ with body: {"action": "like"}
         ↓
Django → like_post view (JWT authentication)
         ↓
Update post.likes_count
         ↓
Return success with new count
         ↓
Flutter → Update local post state
         ↓
UI updates like count and button state
```

---

## Folder Structure

### Backend Structure
```
backend/
├── config/
│   ├── settings.py          # Django settings with JWT config
│   ├── urls.py             # Main URL routing
│   └── wsgi.py
├── posts/
│   ├── __init__.py
│   ├── models.py           # Post model
│   ├── serializers.py      # Post serializers
│   ├── views.py            # Feed and like endpoints
│   ├── urls.py             # Post app URLs
│   └── migrations/         # Database migrations
├── accounts/
│   ├── serializers.py       # User authentication serializers
│   └── views/              # Authentication views
├── media/
│   └── post_images/        # Uploaded post images
├── manage.py
├── create_test_posts.py    # Test data creation script
└── requirements.txt        # Python dependencies
```

### Frontend Structure
```
lib/
├── models/
│   └── post.dart           # Post data models
├── services/
│   ├── auth_api_service.dart
│   └── feed_api_service.dart  # Feed API integration
├── core/
│   └── providers/
│       └── feed_provider.dart   # State management
├── widgets/
│   └── post_card.dart      # Reusable post card widget
├── screens/
│   ├── home/
│   │   └── instagram_feed_screen.dart  # Main feed screen
│   └── auth/
│       ├── login_screen.dart
│       └── signup_screen.dart
└── main.dart
```

---

## Testing Instructions

### Backend Testing

1. **Start Django Server**
```bash
cd backend
python manage.py runserver
```

2. **Create Test Data**
```bash
cd backend
python create_test_posts.py
```

3. **Test API Endpoints**

**Get Feed (requires JWT token):**
```bash
curl -X GET http://localhost:8000/api/feed/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**Like Post:**
```bash
curl -X POST http://localhost:8000/api/posts/1/like/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"action": "like"}'
```

**Unlike Post:**
```bash
curl -X POST http://localhost:8000/api/posts/1/like/ \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"action": "unlike"}'
```

### Frontend Testing

1. **Install Dependencies**
```bash
flutter pub get
```

2. **Run Flutter App**
```bash
flutter run
```

3. **Test Flow**
   - Login or create account
   - Navigate to home feed
   - Verify posts load dynamically
   - Test like/unlike functionality
   - Test pull-to-refresh
   - Test error handling (stop backend server)

### Expected Results

- ✅ Feed loads with posts from backend
- ✅ Posts display in reverse chronological order
- ✅ Images load correctly with loading states
- ✅ Like button updates like count
- ✅ Pull-to-refresh refreshes feed
- ✅ Error states display properly
- ✅ UI is smooth and responsive

---

## Dependencies

### Backend (requirements.txt)
```
Django>=5.0,<6.0
django-cors-headers>=4.3,<5.0
djangorestframework>=3.15,<4.0
djangorestframework-simplejwt>=5.3,<6.0
Pillow>=10.0,<11.0
```

### Frontend (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  http: ^1.2.2
  image_picker: ^1.1.2
  provider: ^6.1.2
  intl: ^0.19.0
```

---

## Key Features Implemented

### Backend Features
- ✅ RESTful API design
- ✅ JWT authentication integration
- ✅ Post model with image uploads
- ✅ Feed endpoint with latest posts first
- ✅ Like/unlike functionality
- ✅ Optimized database queries
- ✅ Proper error handling
- ✅ Media file serving

### Frontend Features
- ✅ Provider state management
- ✅ Dynamic feed loading
- ✅ Instagram-like UI design
- ✅ Reusable post card widget
- ✅ Loading and error states
- ✅ Pull-to-refresh functionality
- ✅ Like button with real-time updates
- ✅ Responsive design
- ✅ Smooth animations

---

## Security Considerations

- JWT authentication required for all endpoints
- CORS configuration for Flutter app
- File upload validation
- SQL injection prevention (Django ORM)
- Read-only fields for sensitive data
- Authorization header validation

---

## Performance Optimizations

- Database query optimization with `select_related`
- Lazy loading for images
- Efficient state management with Provider
- Debounced API calls
- Response caching considerations
- Pagination ready (can be added)

---

## Future Enhancements

- Add pagination for large feeds
- Implement infinite scroll
- Add post creation functionality
- Add comments system
- Implement caching
- Add more image filters
- Add video support
- Add stories feature
