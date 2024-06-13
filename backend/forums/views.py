from django.db import transaction
from django.db.models import F

from rest_framework import status, viewsets
from rest_framework.exceptions import ParseError
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.decorators import action

from forums.models import DiscussionThread, DiscussionTopic, TopicMembership
from forums.permissions import HasUserProfile, ModeratorOnly
from forums.serializers import DiscussionThreadSerializer, DiscussionTopicSerializer

from users.models import UserProfile
from users.serializers import UserProfileSerializer

# Create your views here.


class DiscussionTopicViewSet(
    viewsets.GenericViewSet,
    viewsets.mixins.ListModelMixin,
    viewsets.mixins.CreateModelMixin,
):

    permission_classes = [IsAuthenticated, HasUserProfile]
    serializer_class = DiscussionTopicSerializer

    def get_queryset(self):
        if self.action == "list":
            return DiscussionTopic.objects.filter(visiblity="PUB")
        else:
            return DiscussionTopic.objects.all()

    def list(self, request):
        queryset = self.get_queryset()

        data = self.get_serializer(queryset, many=True).data

        return Response({"data": data})

    def create(self, request):
        data = request.data

        try:
            user = request.user.userprofile
            data["owner"] = user.pk
            created_topic = self.get_serializer(data=data)
            created_topic.is_valid(raise_exception=True)
            created_topic.save()
            return Response(created_topic.data, status=status.HTTP_201_CREATED)
        except KeyError:
            raise ParseError

    @action(methods=["GET"], detail=False, url_name="my", url_path="my")
    def my_topics(self, request):
        user = request.user.userprofile

        joined_topics = user.joined_topics.all()

        serialized_data = self.get_serializer(joined_topics, many=True)

        return Response({"data": serialized_data.data})

    @action(methods=["POST"], detail=True, url_name="join", url_path="join")
    def join(self, request, pk):
        user_profile = request.user.userprofile
        try:
            topic = DiscussionTopic.objects.get(id=pk)
        except DiscussionTopic.DoesNotExist:
            return Response(
                {"detail": "No such topic!"}, status=status.HTTP_400_BAD_REQUEST
            )

        if topic.members.filter(id=user_profile.id).exists():
            return Response(
                {"detail": "Already Joined!"}, status=status.HTTP_400_BAD_REQUEST
            )

        with transaction.atomic():
            TopicMembership.objects.create(user=user_profile, topic=topic, role="MEM")
        return Response({"detail": "Successfully Joined!"}, status=status.HTTP_200_OK)

    @action(methods=["GET"], detail=True, url_name="threads", url_path="threads")
    def threads(self, request, pk):
        user = request.user.userprofile
        try:
            topic = DiscussionTopic.objects.get(id=pk)
        except DiscussionTopic.DoesNotExist:
            return Response(
                {"detail": "No such topic!"}, status=status.HTTP_400_BAD_REQUEST
            )
        threads = topic.threads.all()
        thread_data = DiscussionThreadSerializer(threads, many=True).data
        topic_data = self.get_serializer(topic).data
        try:
            membership = TopicMembership.objects.get(user=user, topic=topic)
            user_status = membership.role
        except TopicMembership.DoesNotExist:
            user_status = "NAN"

        return Response(
            {"user_status": user_status, "topic": topic_data, "threads": thread_data}
        )

    @action(methods=["POST"], detail=True, url_name="leave", url_path="leave")
    def leave(self, request, pk):
        user_profile = request.user.userprofile
        topic = DiscussionTopic.objects.get(id=pk)

        if not topic.members.filter(id=user_profile.id).exists():
            return Response(
                {"detail": "Haven't Joined!"}, status=status.HTTP_400_BAD_REQUEST
            )

        with transaction.atomic():
            TopicMembership.objects.get(user=user_profile, topic=topic).delete()
            topic.save()
        return Response({"detail": "Successfully Left!"}, status=status.HTTP_200_OK)


class DiscussionTopicModerationViewSet(viewsets.GenericViewSet):
    permission_classes = [IsAuthenticated, HasUserProfile, ModeratorOnly]

    @action(
        methods=["GET"], detail=True, url_name="view_members", url_path="list_members"
    )
    def list_members(self, request, pk):
        user = request.user.userprofile
        topic = DiscussionTopic.objects.get(id=pk)

        if not topic.check_mod_status(user):
            raise PermissionError

        members = topic.members.exclude(user=user).values(
            username=F("auth_user__username"), role=F("topicmembership__role")
        )

        return Response(members)

    @action(
        methods=["POST"],
        detail=True,
        url_name="kick_members",
        url_path=r"kick/(?P<username>\w+)",
    )
    def kick_member(self, request, pk, username):
        try:
            user = UserProfile.objects.get(auth_user__username=username)
            topic = DiscussionTopic.objects.get(id=pk)

            if not TopicMembership.objects.filter(user=user, topic=topic).exists():
                return Response(
                    {"detail": "Users hasn't joined!"},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            if user == request.user.userprofile:
                return Response(
                    {"detail": "You can't kick yourself"},
                    status=status.HTTP_400_BAD_REQUEST,
                )

            TopicMembership.objects.get(user=user, topic=topic).delete()
            return Response({"detail": "User kicked!"})
        except UserProfile.DoesNotExist:
            return Response(
                {"detail": "No such user exists!"}, status=status.HTTP_400_BAD_REQUEST
            )

    @action(
        methods=["POST"],
        detail=True,
        url_name="mod_member",
        url_path=r"mod/(?P<username>\w+)",
    )
    def mod_member(self, request, pk, username):
        try:
            user = UserProfile.objects.get(auth_user__username=username)
            topic = DiscussionTopic.objects.get(id=pk)

            try:
                if user == request.user.userprofile:
                    return Response(
                        {"detail": "You can't mod yourself"},
                        status=status.HTTP_400_BAD_REQUEST,
                    )
                membership = TopicMembership.objects.get(
                    user=user, topic=topic, role="MEM"
                )
                membership.role = "MOD"
                membership.save()
                return Response({"detail": "User made a moderator!"})
            except TopicMembership.DoesNotExist:
                return Response(
                    {"detail": "Users hasn't joined or is already a mod!"},
                    status=status.HTTP_400_BAD_REQUEST,
                )

        except UserProfile.DoesNotExist:
            return Response(
                {"detail": "No such user exists!"}, status=status.HTTP_400_BAD_REQUEST
            )
        except DiscussionTopic.DoesNotExist:
            return Response(
                {"detail": "No such topic exists!"}, status=status.HTTP_400_BAD_REQUEST
            )

    @action(
        methods=["PUT"],
        detail=True,
        url_name="toggle_visiblity",
        url_path="toggle_visiblity",
    )
    def toggle_visiblity(self, request, pk):
        try:
            topic = DiscussionTopic.objects.get(id=pk)

            if topic.visiblity == "PUB":
                topic.visiblity = "PVT"
            else:
                topic.visiblity = "PUB"

            topic.save()
            return Response({"detail": "Visibilty set to {}".format(topic.visiblity)})
        except DiscussionTopic.DoesNotExist:
            return Response(
                {"detail": "No such topic exists!"}, status=status.HTTP_400_BAD_REQUEST
            )


class DiscussionThreadView(
    viewsets.GenericViewSet,
    viewsets.mixins.CreateModelMixin,
):

    permission_classes = [IsAuthenticated, HasUserProfile]
    serializer_class = DiscussionThreadSerializer
    queryset = DiscussionThread.objects.all()

    def create(self, request):
        data = request.data
        user = request.user.username

        if data["topic"] not in request.user.userprofile.joined_topics.values_list(
            "id", flat=True
        ):
            return Response(
                {"detail": "You haven't joined the topic!"},
                status=status.HTTP_400_BAD_REQUEST,
            )
        data["created_by"] = user
        created_thread = self.get_serializer(data=data)
        created_thread.is_valid(raise_exception=True)
        created_thread.save()
        return Response(created_thread.data)
