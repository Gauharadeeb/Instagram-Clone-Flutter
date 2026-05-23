from django.urls import path

from accounts.views.create_account import CreateAccountView
from accounts.views.login import LoginView
from accounts.views.me import MeView
from accounts.views.signup import SignupView
from accounts.views.users import UsersView


urlpatterns = [
    path('signup/', SignupView.as_view(), name='signup'),
    path('create-account/', CreateAccountView.as_view(), name='create-account'),
    path('login/', LoginView.as_view(), name='login'),
    path('me/', MeView.as_view(), name='me'),
    path('users/', UsersView.as_view(), name='users'),
]
