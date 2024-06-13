from rest_framework import permissions
from users.models import UserProfile
from forums.models import TopicMembership


class ModeratorOnly(permissions.BasePermission):
    message = "You have to be a moderator to do this!"

    def has_permission(self, request, view):
        if int(view.kwargs["pk"]) in TopicMembership.objects.filter(user=request.user.userprofile, role="MOD").values_list("topic", flat=True):
            return True
        return False

class HasUserProfile(permissions.BasePermission):
    message = "You're not allowed to access this!"

    def has_permission(self, request, view):
        try:
            request.user.userprofile
            return True
        except UserProfile.DoesNotExist:
            return False
