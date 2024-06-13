from rest_framework import serializers

from forums.models import DiscussionThread, DiscussionTopic, Comment
from users.models import UserProfile


class DiscussionThreadSerializer(serializers.ModelSerializer):
    created_by = serializers.SlugRelatedField(
        slug_field="auth_user__username", queryset=UserProfile.objects.all()
    )

    class Meta:
        model = DiscussionThread
        fields = [
            "id",
            "title",
            "topic",
            "created_by",
            "created_at",
            "like_count",
            "dislike_count",
            "comment_count",
        ]
        write_only = ["topic"]

    def create(self, validated_data):
        return DiscussionThread.objects.create(**validated_data)

class DiscussionTopicSerializer(serializers.ModelSerializer):
    owner = serializers.SlugRelatedField(slug_field="auth_user__username", queryset=UserProfile.objects.all())
    class Meta:
        model = DiscussionTopic
        fields = ["id", "name", "description", "created_at", "owner"]


class DiscussionCommentSerializer(serializers.ModelSerializer):
    class Meta:
        model = Comment
        fields = "__all__"
