from rest_framework.routers import SimpleRouter

from users.views import AuthViewSet, UserProfileViewSet

user_router = SimpleRouter()

user_router.register(r'auth', AuthViewSet, basename="auth")
user_router.register(r'user', UserProfileViewSet, basename="user")
