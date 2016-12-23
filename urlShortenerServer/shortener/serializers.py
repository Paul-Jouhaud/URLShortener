from rest_framework import serializers
from shortener.models import Urls


class UrlSerializer(serializers.ModelSerializer):
    class Meta:
        model = Urls
        fields = ('short_url', 'real_url', 'date', 'username', 'count')
