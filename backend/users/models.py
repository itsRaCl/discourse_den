from django.db import models
from django.contrib.auth.models import User
from django.core.validators import MinValueValidator

from forums.models import TopicMembership

# Create your models here.
GENDER_CHOICES = [
    ("M", "Male"),
    ("F", "Female"),
    ("O", "Other"),
]


class UserProfile(models.Model):

    auth_user = models.OneToOneField(User, on_delete=models.CASCADE)
    email = models.EmailField()
    name = models.CharField(max_length=100)
    age = models.PositiveSmallIntegerField(
        validators=[MinValueValidator(16, message="You must be 16 to use the site")]
    )
    gender = models.CharField(max_length=1, choices=GENDER_CHOICES)
    about = models.TextField(max_length=500)
    interests = models.TextField(max_length=100)

    def __str__(self):
        return f"{self.name} | {self.email} | {self.auth_user.username}"
