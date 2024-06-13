from rest_framework import permissions

class SelfUpdatePermission(permissions.BasePermission):
    message = "You don't have access to this!"

    def has_permission(self, request, view):
        user = request.user
        try:
            if (int(view.kwargs["pk"]) == user.userprofile.pk):
                return True
            else:
                return False
        except:
            return False

