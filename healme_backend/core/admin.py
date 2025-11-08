from django.contrib import admin
from .models import *

admin.site.register(User)
admin.site.register(Patient)
admin.site.register(Therapeute)
admin.site.register(Administrateur)
admin.site.register(Journal)
admin.site.register(Humeur)
admin.site.register(Sommeil)
admin.site.register(Session)
admin.site.register(Room)
admin.site.register(Message)
