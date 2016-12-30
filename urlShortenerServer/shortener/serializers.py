from rest_framework import serializers
from shortener.models import Urls


class UrlSerializer(serializers.ModelSerializer):
    short_url = serializers.CharField(max_length=6, required=False)
    count = serializers.IntegerField(required=False)
    username = serializers.CharField(required=False)
    class Meta:
        model = Urls
        fields = ('short_url', 'real_url', 'date', 'username', 'count')
