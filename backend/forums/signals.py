from django.db.models.signals import post_save
from django.dispatch import receiver

from forums.models import DiscussionTopic, TopicMembership


@receiver(post_save, sender=DiscussionTopic)
def add_owner_membership(sender, instance, created, **kwargs):
    if created:
        TopicMembership.objects.create(topic=instance, user=instance.owner, role="MOD")
