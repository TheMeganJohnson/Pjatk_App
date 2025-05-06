from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.hashers import check_password
from .models import OfficeAppUser, Reservation
from .models import Timetable
import pytz
import json
from datetime import datetime

@csrf_exempt
def check_login(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            login_or_email = data.get('login')
            password = data.get('password')

            try:
                user = OfficeAppUser.objects.get(login=login_or_email)
            except OfficeAppUser.DoesNotExist:
                try:
                    user = OfficeAppUser.objects.get(email=login_or_email)
                except OfficeAppUser.DoesNotExist:
                    return JsonResponse({'status': 'error', 'message': 'User not found'}, status=404)

            if check_password(password, user.password):
                user_data = {
                    'name': user.name,
                    'surname': user.surname,
                    'email': user.email,
                    'isAuthenticated': user.isAuthenticated,  # Use is_authenticated correctly
                    'permissions': user.permissions,
                    'group': user.group,
                }
                return JsonResponse({'status': 'success', 'user_data': user_data})
            else:
                return JsonResponse({'status': 'error', 'message': 'Invalid password'}, status=400)
        except json.JSONDecodeError:
            return JsonResponse({'status': 'error', 'message': 'Invalid JSON'}, status=400)
    return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=400)

@csrf_exempt
def list_reservations(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            group = data.get('group')
            date_str = data.get('date')

            if not date_str:
                return JsonResponse({'status': 'error', 'message': 'Date is required'}, status=400)

            date = datetime.strptime(date_str, '%Y-%m-%d').date()

            reservations = Timetable.objects.filter(group=group, from_datetime__date=date)
            reservations_data = [
                {
                    'name': reservation.name,
                    'room': reservation.room,
                    'code': reservation.code,
                    'duration_minutes': reservation.duration_minutes,
                    'from_datetime': reservation.from_datetime,
                    'group': reservation.group,
                    'is_canceled': reservation.is_canceled,
                    'color': reservation.color,
                    'user': reservation.user,
                }
                for reservation in reservations
            ]

            return JsonResponse({'status': 'success', 'reservations': reservations_data})
        except json.JSONDecodeError:
            return JsonResponse({'status': 'error', 'message': 'Invalid JSON'}, status=400)
    return JsonResponse({'status': 'error', 'message': 'Invalid request method'}, status=400)

@csrf_exempt
def create_reservation(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            print(f"Received data: {data}")  # Debug print to check received data

            # Convert naive datetime strings to timezone-aware datetime objects
            timezone = pytz.timezone('UTC')  # Use the appropriate timezone
            from_datetime = timezone.localize(datetime.strptime(data['from_datetime'], '%Y-%m-%dT%H:%M:%S.%f'))
            to_datetime = timezone.localize(datetime.strptime(data['to_datetime'], '%Y-%m-%dT%H:%M:%S.%f'))

            reservation = Reservation(
                name=data['name'],
                room=data['room'],
                code=data['code'],
                duration_minutes=data.get('duration_minutes', 90),
                from_datetime=from_datetime,
                to_datetime=to_datetime,
                group=data['group'],
                user=data['user']  # Use data['user'] as a string
            )
            reservation.save()
            print(f"Reservation saved: {reservation}")  # Debug print to confirm saving
            return JsonResponse({'status': 'success'})
        except Exception as e:
            print(f"Error: {e}")  # Debug print to check the error
            return JsonResponse({'status': 'error', 'message': str(e)})
    return JsonResponse({'status': 'error', 'message': 'Invalid request method'})