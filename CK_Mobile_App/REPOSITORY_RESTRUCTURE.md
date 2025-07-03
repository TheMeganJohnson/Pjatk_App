# Alternative: Move Django Project to Repository Root

If you want to restructure your repository for cleaner deployment:

## Current Structure (assumed):
```
Pjatk_App/
└── CK_Mobile_App/
    ├── lib/ (Flutter)
    ├── android/ (Flutter)
    ├── requirements.txt
    ├── myproject/ (Django)
    └── other Flutter files
```

## Recommended Structure:
```
Pjatk_App/
├── requirements.txt (moved from CK_Mobile_App/)
├── myproject/ (moved from CK_Mobile_App/)
├── CK_Mobile_App/ (Flutter app)
│   ├── lib/
│   ├── android/
│   └── pubspec.yaml
└── README.md
```

## Git Commands to Restructure:
```bash
# 1. Move Django files to root
git mv CK_Mobile_App/requirements.txt ./
git mv CK_Mobile_App/myproject ./
git mv CK_Mobile_App/RENDER_DEPLOYMENT.md ./

# 2. Commit changes
git add .
git commit -m "Restructure repository for easier deployment"

# 3. Push changes
git push origin main
```

## Then Use Original Build Commands:
- Build: `pip install -r requirements.txt && cd myproject && python manage.py collectstatic --noinput && python manual_setup.py`
- Start: `cd myproject && gunicorn myproject.wsgi:application --bind 0.0.0.0:$PORT`
