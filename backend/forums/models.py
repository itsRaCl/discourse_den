from django.db import models


ROLE_CHOICES = [
    ("MEM", "Member"),
    ("MOD", "Moderator"),
]
VISIBLITY_OPTIONS = {
    "PUB": "Public",
    "PVT": "Private",
}
COMMENT_CHOICES = [
    ("Q", "Quote"),
    ("N", "Normal"),
]
STATUS_CHOICES = [
    ("P", "Pending"),
    ("A", "Accepted"),
    ("D", "Declined"),
]


# Create your models here.
class DiscussionTopic(models.Model):

    name = models.CharField(max_length=100, unique=True)
    description = models.TextField(max_length=500)
    created_at = models.DateTimeField(auto_now_add=True, editable=False)
    owner = models.ForeignKey(
        "users.UserProfile", on_delete=models.PROTECT, related_name="owned_topics"
    )
    visiblity = models.CharField(max_length=3, choices=VISIBLITY_OPTIONS, default="PUB")
    members = models.ManyToManyField("users.UserProfile", through="TopicMembership", related_name="joined_topics")

    def __str__(self):
        return f"{ self.name }"

    @property
    def moderators(self):
        return TopicMembership.objects.filter(topic = self, role="MOD")

    def check_mod_status(self, user_profile):
        return TopicMembership.objects.filter(topic=self, user=user_profile, role="MOD").exists()


class DiscussionThread(models.Model):
    title = models.CharField(max_length=100)
    topic = models.ForeignKey(
        DiscussionTopic, on_delete=models.RESTRICT, related_name="threads"
    )
    created_by = models.ForeignKey(
        "users.UserProfile",
        on_delete=models.SET_NULL,
        null=True,
        related_name="created_threads",
    )
    created_at = models.DateTimeField(auto_now_add=True, editable=False)
    likes = models.ManyToManyField("users.UserProfile", related_name="liked_threads")
    dislikes = models.ManyToManyField("users.UserProfile", related_name="disliked_threads")

    def __str__(self):
        return f"{self.title} | {self.topic}"

    @property
    def comment_count(self):
        return self.comments.count()

    @property
    def like_count(self):
        return self.likes.count()

    @property
    def dislike_count(self):
        return self.dislikes.count()


class Comment(models.Model):
    parent_thread = models.ForeignKey(DiscussionThread, on_delete=models.CASCADE, related_name="comments")
    quoted_comment = models.ForeignKey(
        "self", related_name="quoted_by", on_delete=models.SET_NULL, null=True, blank=True
    )
    comment_type = models.CharField(max_length=1, choices=COMMENT_CHOICES, default="N")
    comment_text = models.TextField(max_length=500)

    created_by = models.ForeignKey(
        "users.UserProfile", on_delete=models.SET_NULL, related_name="comments", null=True
    )
    created_at = models.DateTimeField(auto_now_add=True, editable=False)
    likes = models.ManyToManyField("users.UserProfile", related_name="liked_comments")
    dislikes = models.ManyToManyField("users.UserProfile", related_name="disliked_comments")

    def __str__(self):
        return f"{self.created_by} | {self.parent_thread}"

    @property
    def like_count(self):
        return self.likes.count()

    @property
    def dislike_count(self):
        return self.dislikes.count()


class TopicMembership(models.Model):
    topic = models.ForeignKey(DiscussionTopic, on_delete=models.CASCADE )
    user = models.ForeignKey("users.UserProfile", on_delete=models.CASCADE )
    joined_at = models.DateTimeField(auto_now_add=True, editable=False)
    role = models.CharField(max_length=3, choices=ROLE_CHOICES)

    def __str__(self):
        return f"{self.user.name} | {self.topic}"


class TopicInvite(models.Model):
    topic = models.ForeignKey(
        DiscussionTopic, on_delete=models.CASCADE, related_name="sent_invites"
    )
    recipient = models.ForeignKey(
        "users.UserProfile", on_delete=models.CASCADE, related_name="recieved_invites"
    )
    invited_at = models.DateTimeField(auto_now_add=True, editable=False)
    invited_by = models.ForeignKey(
        "users.UserProfile",
        on_delete=models.SET_NULL,
        null=True,
        related_name="created_invites",
    )
    status = models.CharField(max_length=1, choices=STATUS_CHOICES)

    def __str__(self):
        return f"{self.recipient} | {self.topic}"
