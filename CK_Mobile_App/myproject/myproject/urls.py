from django.contrib import admin
from django.urls import path
from myapp.views import list_reservations, create_reservation  # Import the views

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/list_reservations/', list_reservations, name='list_reservations'),
    path('api/create_reservation/', create_reservation, name='create_reservation'),
]