from django.urls import path
from .views import FeedListView, PostCreateView, comment_post, like_post, post_detail

app_name = 'posts'

urlpatterns = [
    path('', FeedListView.as_view(), name='post-list'),
    path('create/', PostCreateView.as_view(), name='post-create'),
    path('<int:post_id>/like/', like_post, name='like-post'),
    path('<int:post_id>/comments/', comment_post, name='comment-post'),
    path('<int:post_id>/', post_detail, name='post-detail'),
]
