# Render Deployment Guide

## Quick Setup for Your PJATK App

### 1. Repository Structure
Your Django project is in the `myproject` folder, so Render needs special configuration.

### 2. Render Service Configuration

**Environment:** Python 3

**Build Command:**
```bash
pip install -r requirements.txt && cd myproject && python manage.py collectstatic --noinput && python manual_setup.py
```

**Start Command:**
```bash
cd myproject && gunicorn myproject.wsgi:application --bind 0.0.0.0:$PORT
```

### 3. Environment Variables
Add these in Render dashboard:

```
DB_NAME=sql7788203
DB_USER=sql7788203
DB_PASSWORD=RGWQajnjVy
DB_HOST=sql7.freesqldatabase.com
DB_PORT=3306
DJANGO_SECRET_KEY=iooLYS1*J_$Lp5*Co!74L@xpuzTuJ=lI+gHvlh5ehaBlb4HUn+
DEBUG=False
ALLOWED_HOSTS=*.onrender.com
```

### 4. Important Notes

- The `requirements.txt` is now in the root directory
- The `manual_setup.py` script handles MySQL 5.5 compatibility
- Your Django project is in the `myproject` subdirectory
- Render will automatically create the database tables during deployment

### 5. After Deployment

Once deployed, Render will give you a URL like `https://your-app-name.onrender.com`

Update your Flutter app's `globals.dart`:
```dart
String? pcIP = "your-app-name.onrender.com";
```

### 6. Testing Your Deployment

Test these endpoints:
- `GET https://your-app-name.onrender.com/` (should show Django default page)
- `POST https://your-app-name.onrender.com/api/list_reservations/`
- `POST https://your-app-name.onrender.com/api/create_reservation/`
