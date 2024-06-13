from rest_framework.routers import SimpleRouter

from .views import DiscussionThreadView, DiscussionTopicModerationViewSet, DiscussionTopicViewSet

forum_router = SimpleRouter()

forum_router.register(r'topic', DiscussionTopicViewSet, basename='topic')
forum_router.register(r'topic_mod', DiscussionTopicModerationViewSet, basename='topic-mod')
forum_router.register(r'thread', DiscussionThreadView, basename='thread')

