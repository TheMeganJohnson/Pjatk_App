from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.hashers import check_password
from .models import Reservation
from .models import Timetable
import pytz
import json
from datetime import datetime


@csrf_exempt
def list_reservations(request):
    if request.method == 'POST':
        try:
            # Debug: print request details
            print(f"Request body: {request.body}")
            print(f"Request headers: {request.headers}")
            
            data = json.loads(request.body)
            print(f"Parsed data: {data}")
            
            group = data.get('group')
            date_str = data.get('date')
            
            print(f"Group: {group}, Date: {date_str}")

            if not date_str:
                return JsonResponse({'status': 'error', 'message': 'Date is required'}, status=400)

            date = datetime.strptime(date_str, '%Y-%m-%d').date()

            reservations = Timetable.objects.filter(group=group, from_datetime__date=date)
            print(f"Found {reservations.count()} reservations")
            
            reservations_data = [
                {
                    'name': reservation.name,
                    'room': reservation.room,
                    'code': reservation.code,
                    'duration_minutes': reservation.duration_minutes,
                    'from_datetime': reservation.from_datetime,
                    'group': reservation.group,
                    'color': reservation.color,
                    'user': reservation.user,
                }
                for reservation in reservations
            ]

            return JsonResponse({'status': 'success', 'reservations': reservations_data})
        except json.JSONDecodeError as e:
            print(f"JSON decode error: {e}")
            return JsonResponse({'status': 'error', 'message': f'Invalid JSON: {e}'}, status=400)
        except Exception as e:
            print(f"General error: {e}")
            return JsonResponse({'status': 'error', 'message': f'Server error: {e}'}, status=500)
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
                group=data['group'],
                user=data['user']
            )
            reservation.save()
            print(f"Reservation saved: {reservation}")  # Debug print to confirm saving
            return JsonResponse({'status': 'success'})
        except Exception as e:
            print(f"Error: {e}")  # Debug print to check the error
            return JsonResponse({'status': 'error', 'message': str(e)})
    return JsonResponse({'status': 'error', 'message': 'Invalid request method'})