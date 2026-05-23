from rest_framework import generics, status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from django.db import transaction
from .models import Post, PostComment, PostLike
from .serializers import CommentCreateSerializer, LikeSerializer, PostCommentSerializer, PostCreateSerializer, PostSerializer


class FeedListView(generics.ListAPIView):
    """
    API endpoint to retrieve all posts for the home feed.
    Returns posts sorted by latest first (created_at descending).
    Requires JWT authentication.
    """
    serializer_class = PostSerializer
    permission_classes = [IsAuthenticated]
    queryset = Post.objects.all().select_related('user').prefetch_related('comments__user')
    
    def get_queryset(self):
        return Post.objects.all().select_related('user').prefetch_related('comments__user').order_by('-created_at')


class PostCreateView(generics.CreateAPIView):
    """
    API endpoint to create a post with multipart image upload.
    POST /api/posts/create/
    Body: image=<file>, caption=<text>
    """
    serializer_class = PostCreateSerializer
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        post = serializer.instance
        serializer = PostSerializer(post, context={'request': request})
        return Response(serializer.data, status=status.HTTP_201_CREATED)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def like_post(request, post_id):
    """
    API endpoint to like/unlike a post.
    POST /api/posts/<post_id>/like/
    Body: {"action": "like"} or {"action": "unlike"}
    """
    post = get_object_or_404(Post, id=post_id)
    serializer = LikeSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    action = serializer.validated_data['action']

    with transaction.atomic():
        if action == 'like':
            PostLike.objects.get_or_create(post=post, user=request.user)
        else:
            PostLike.objects.filter(post=post, user=request.user).delete()

        likes_count = PostLike.objects.filter(post=post).count()
        Post.objects.filter(id=post.id).update(likes_count=likes_count)

    return Response({
        'status': 'success',
        'likes_count': likes_count,
        'is_liked': action == 'like',
        'action': action,
    }, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def comment_post(request, post_id):
    """
    API endpoint to add a comment to a post.
    POST /api/posts/<post_id>/comments/
    Body: {"text": "Nice shot"}
    """
    post = get_object_or_404(Post, id=post_id)
    serializer = CommentCreateSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    comment = PostComment.objects.create(
        post=post,
        user=request.user,
        text=serializer.validated_data['text'],
    )
    response_serializer = PostCommentSerializer(comment, context={'request': request})
    return Response(response_serializer.data, status=status.HTTP_201_CREATED)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def post_detail(request, post_id):
    """
    API endpoint to retrieve a single post by ID.
    GET /api/posts/<post_id>/
    """
    post = get_object_or_404(Post, id=post_id)
    serializer = PostSerializer(post, context={'request': request})
    return Response(serializer.data, status=status.HTTP_200_OK)
