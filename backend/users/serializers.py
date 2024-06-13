from rest_framework import serializers
from django.contrib.auth.models import User

from .models import UserProfile, GENDER_CHOICES


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ["username", "password"]
        extra_kwargs = {
            "password": {
                "write_only": True,
            },
        }


class UserProfileSerializer(serializers.ModelSerializer):
    auth_user = UserSerializer()
    gender = serializers.ChoiceField(choices=GENDER_CHOICES)

    class Meta:
        model = UserProfile
        fields = ["auth_user","id", "name", "age", "email", "gender", "about", "interests"]
        read_only_fields = ["id"]

    def create(self, validated_data: dict):
        u = User.objects.create(username=validated_data["auth_user"]["username"])
        u.set_password(validated_data["auth_user"]["password"])
        u.save()
        validated_data["auth_user"] = u
        user_profile = UserProfile.objects.create(**validated_data)
        return user_profile
