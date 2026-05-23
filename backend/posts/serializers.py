from rest_framework import serializers
from .models import Post, PostComment
from django.contrib.auth import get_user_model

User = get_user_model()


class UserSerializer(serializers.ModelSerializer):
    profile_image_url = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = (
            'id',
            'username',
            'email',
            'first_name',
            'last_name',
            'profile_image_url',
        )

    def get_profile_image_url(self, obj):
        image = getattr(obj, 'profile_image', None)
        if not image:
            return None

        request = self.context.get('request')
        if request:
            return request.build_absolute_uri(image.url)
        return image.url


class PostSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    image_url = serializers.SerializerMethodField()
    is_liked = serializers.SerializerMethodField()
    comments = serializers.SerializerMethodField()
    comments_count = serializers.SerializerMethodField()
    likes_count = serializers.IntegerField(read_only=True)
    
    class Meta:
        model = Post
        fields = (
            'id',
            'user',
            'image',
            'image_url',
            'caption',
            'likes_count',
            'is_liked',
            'comments',
            'comments_count',
            'created_at',
            'updated_at',
        )
        read_only_fields = ('id', 'created_at', 'updated_at', 'likes_count')
    
    def get_image_url(self, obj):
        if obj.image:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.image.url)
            return obj.image.url
        return None

    def get_is_liked(self, obj):
        request = self.context.get('request')
        if not request or not request.user.is_authenticated:
            return False
        return obj.likes.filter(user=request.user).exists()

    def get_comments(self, obj):
        comments = obj.comments.select_related('user').order_by('created_at')
        return PostCommentSerializer(comments, many=True, context=self.context).data

    def get_comments_count(self, obj):
        return obj.comments.count()


class PostCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = Post
        fields = ('image', 'caption')


class LikeSerializer(serializers.Serializer):
    action = serializers.ChoiceField(choices=['like', 'unlike'])


class PostCommentSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)

    class Meta:
        model = PostComment
        fields = (
            'id',
            'user',
            'text',
            'created_at',
        )
        read_only_fields = ('id', 'user', 'created_at')


class CommentCreateSerializer(serializers.Serializer):
    text = serializers.CharField(max_length=2200, trim_whitespace=True)
