from django.contrib import admin
from .models import DiscussionTopic, DiscussionThread, Comment, TopicInvite, TopicMembership

# Register your models here.
admin.site.register(DiscussionTopic)
admin.site.register(DiscussionThread)
admin.site.register(TopicMembership)
admin.site.register(Comment)
admin.site.register(TopicInvite)
