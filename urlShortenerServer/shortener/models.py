from django.db import models
from django.utils.timezone import now


# Create your models here.
class Urls(models.Model):
    short_url = models.CharField(max_length=6, primary_key=True)
    real_url = models.URLField()
    date = models.DateTimeField(auto_now=True)
    count = models.IntegerField(default=0)
    username = models.CharField(max_length=255, default="")

    def __str__(self):
        return self.short_url + " " + self.real_url + " " + self.username
