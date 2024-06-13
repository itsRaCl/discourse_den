from django.contrib.auth import authenticate, login
from django.contrib.auth.models import User
from rest_framework import viewsets
from rest_framework.decorators import action, permission_classes
from rest_framework.exceptions import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken

from users.models import UserProfile
from users.serializers import UserProfileSerializer
from users.permissions import SelfUpdatePermission

# Create your views here.


class AuthViewSet(viewsets.GenericViewSet):

    queryset = User.objects.all()


    @action(detail=False, methods=["post"])
    def login(self, request):
        username = request.data["username"]
        password = request.data["password"]

        user = authenticate(username=username, password=password)
        if user:
            try:
                up = user.userprofile
            except UserProfile.DoesNotExist:
                return Response(
                    {"message": "Invalid Access!"}, status=status.HTTP_403_FORBIDDEN
                )
            tokens = RefreshToken.for_user(user)
            return Response(
                {
                    "message": "Logged In! Welcome! {}".format(user.username),
                    "refresh_token": str(tokens),
                    "access_token": str(tokens.access_token),
                    "user_id": up.id,
                },
                status=status.HTTP_200_OK,
            )

class UserProfileViewSet(viewsets.GenericViewSet, viewsets.mixins.RetrieveModelMixin, viewsets.mixins.UpdateModelMixin, viewsets.mixins.CreateModelMixin):
    serializer_class = UserProfileSerializer
    lookup_field = "username"
    lookup_field_converted = "str"
    def get_queryset(self):
        if self.action in ["update", "partial_update"]:
            return UserProfile.objects.filter(auth_user = self.request.user)
        else:
            return UserProfile.objects.all()

    def get_permissions(self):
        permissions = []
        if self.action in ["update", "partial_update"]:
            permissions = [IsAuthenticated , SelfUpdatePermission] 
        else: 
            permissions = [IsAuthenticated] 
        return [permission() for permission in permissions]
    

    def retrieve(self, request, username="me"):
        try:
            if username=="me":
                    return Response(UserProfileSerializer(request.user.userprofile).data)
            else:
                userprofile = UserProfile.objects.get(auth_user__username=username)
                return Response(self.get_serializer(userprofile).data)
        except UserProfile.DoesNotExist: 
            return Response({"detail" : "No Such User Exists!" }, status=status.HTTP_404_NOT_FOUND)

