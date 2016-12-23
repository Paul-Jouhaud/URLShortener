from django import forms
from .models import Urls

class URLShortenerForm(forms.ModelForm):
    class Meta:
        model = Urls
        fields = ('real_url', 'username')