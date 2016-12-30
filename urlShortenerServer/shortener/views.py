from django.http import HttpResponseRedirect, HttpResponse
from django.shortcuts import redirect, get_object_or_404, render_to_response
from django.template.context_processors import csrf
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from shortener.serializers import UrlSerializer
from shortener.models import Urls
from shortener.forms import URLShortenerForm
from urlShortenerServer.settings import SITE_URL
from django.contrib.auth.forms import UserCreationForm 
from rest_framework.permissions import IsAuthenticated, AllowAny
import string
import random
import json


def index(request):
    c = {}
    c.update(csrf(request))
    return render_to_response('index.html', c)

def register(request):
     if request.method == 'POST':
         form = UserCreationForm(request.POST)
         if form.is_valid():
             form.save()
             return render_to_response('index.html')
     else:
         form = UserCreationForm()
     token = {}
     token.update(csrf(request))
     token['form'] = form
     return render_to_response('register.html', token)

def login(request):
    c = {}
    c.update(csrf(request))
    return render_to_response('login.html', c)


# Create your views here.
class UrlShortener(APIView):
    permission_classes = (AllowAny,)
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
            # If user is authenticated
            if 'username' in request.data:
                new_url.username = request.data['username']
            new_url.save()
            response_data = {}
            response_data['real_url'] = new_url.real_url
            response_data['count'] = new_url.count
            response_data['short_url'] = SITE_URL + new_url.short_url
            return HttpResponse(json.dumps(response_data),
                                content_type="application/json")
        return HttpResponse(json.dumps({"error": "error occurs"}),
                            content_type="application/json")


class ExistingUrl(APIView):
    permission_classes = (AllowAny,)
    def get_object(self, pk):
        try:
            return Urls.objects.get(pk=pk)
        except Urls.DoesNotExist:
            raise Http > 404

    def get(self, request, pk, format=None):
        url = get_object_or_404(Urls, pk=pk)
        url.count += 1
        url.save()
        print(url.real_url)
        return redirect("http://"+url.real_url, permanent=True)

class UrlFromUser(APIView):
    permission_classes = (IsAuthenticated,)
    def post(self, request, format=None):
        print(request.data)
        if 'username' in request.data:
            urls = Urls.objects.filter(username=request.data['username'])
            print(urls)
            response_data = {}
            response_data['urls'] = []
            for url in urls:
                urlJson = {
                    'short_url': SITE_URL + url.short_url,
                    'real_url': url.real_url,
                    'count': url.count,
                }
                response_data['urls'].append(json.dumps(urlJson))
            return HttpResponse(json.dumps(response_data),
                                content_type="application/json")
        return HttpResponse(json.dumps({"error": "No username"}),
                            content_type="application/json")