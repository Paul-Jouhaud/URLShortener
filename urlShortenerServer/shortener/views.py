from django.http import HttpResponseRedirect, HttpResponse
from django.shortcuts import redirect, get_object_or_404, render_to_response
from django.template.context_processors import csrf
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from shortener.serializers import UrlSerializer
from shortener.models import Urls
from shortener.forms import URLShortenerForm
import string
import random
import json


def index(request):
    c = {}
    c.update(csrf(request))
    return render_to_response('index.html', c)

# Create your views here.
class UrlShortener(APIView):

    def generate(nb_char):
        char = string.ascii_uppercase + string.digits + string.ascii_lowercase
        randomized = [random.choice(char) for _ in range(nb_char)]
        short_url = ''.join(randomized)
        if Urls.objects.filter(short_url=short_url):
            return UrlShortener.generate(nb_char)
        else:
            return short_url

    def post(self, request, format=None):
        if 'real_url' in request.data:
            # More than 56 billion possibility for 6 numbers in base 62
            short_url = UrlShortener.generate(nb_char=6)
            new_url = Urls()
            new_url.short_url = short_url
            new_url.real_url = request.data['real_url']
            # Not used right now, will be in the future
            if 'username' in request.data:
                new_url.username = request.data['username']
            new_url.save()
            response_data = {}
            response_data['url'] = short_url
            return HttpResponse(json.dumps(response_data),
                                content_type="application/json")
        return HttpResponse(json.dumps({"error": "error occurs"}),
                            content_type="application/json")


class ExistingUrl(APIView):
    def get_object(self, pk):
        try:
            return Urls.objects.get(pk=pk)
        except Urls.DoesNotExist:
            raise Http > 404

    def get(self, request, pk, format=None):
        url = get_object_or_404(Urls, pk=pk)
        url.count += 1
        url.save()
        return redirect(url.real_url, permanent=True)
