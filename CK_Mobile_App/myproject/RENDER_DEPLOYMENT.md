# Render Deployment Guide

## Steps to Deploy on Render:

1. **Create a Render Account**
   - Go to https://render.com
   - Sign up with GitHub

2. **Create a Web Service**
   - Click "New +" → "Web Service"
   - Connect your GitHub repository
   - Choose your repository

3. **Configure the Service**
   - Name: your-app-name
   - Environment: Python 3
   - Build Command: `pip install -r requirements.txt`
   - Start Command: `gunicorn myproject.wsgi:application`

4. **Add Environment Variables**
   ```
   DB_NAME=your_actual_db_name
   DB_USER=your_actual_username
   DB_PASSWORD=your_actual_password
   DB_HOST=sql7.freesqldatabase.com
   DB_PORT=3306
   DJANGO_SECRET_KEY=iooLYS1*J_$Lp5*Co!74L@xpuzTuJ=lI+gHvlh5ehaBlb4HUn+
   DEBUG=False
   ```

5. **Deploy**
   - Click "Create Web Service"
   - Render will build and deploy automatically

## Advantages:
- Free tier (750 hours/month)
- Automatic SSL certificates
- GitHub integration
- Easy to use interface
