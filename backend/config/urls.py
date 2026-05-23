from django.contrib import admin
from django.http import JsonResponse
from django.urls import include, path
from django.conf import settings
from django.conf.urls.static import static
from posts.views import FeedListView, PostCreateView, comment_post, like_post, post_detail


def api_status(_request):
    return JsonResponse({'status': 'ok'})


urlpatterns = [
    path('', api_status, name='api-status'),
    path('feed/', FeedListView.as_view(), name='feed'),
    path('posts/', FeedListView.as_view(), name='posts'),
    path('posts/create/', PostCreateView.as_view(), name='post-create'),
    path('posts/<int:post_id>/like/', like_post, name='like-post'),
    path('posts/<int:post_id>/comments/', comment_post, name='comment-post'),
    path('posts/<int:post_id>/', post_detail, name='post-detail'),
    path('api/health/', api_status, name='api-health'),
    path('admin/', admin.site.urls),
    path('api/auth/', include('accounts.urls')),
    path('api/posts/', include('posts.urls')),
] + static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
