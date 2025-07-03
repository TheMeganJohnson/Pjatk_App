#!/bin/bash

# Install dependencies
pip install -r requirements.txt

# Change to Django project directory
cd myproject

# Collect static files
python manage.py collectstatic --noinput

# Run manual database setup (for MySQL 5.5 compatibility)
python manual_setup.py
