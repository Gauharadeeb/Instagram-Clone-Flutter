from django.contrib.auth import get_user_model
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from accounts.serializers import UserSerializer


User = get_user_model()


class UsersView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        users = (
            User.objects.exclude(id=request.user.id)
            .order_by('username')[:30]
        )
        return Response({'users': UserSerializer(users, many=True).data})
