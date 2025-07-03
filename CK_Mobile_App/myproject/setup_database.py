#!/usr/bin/env python
"""
Database Migration Setup Script
This script helps you migrate from local MySQL to sql7.freesqldatabase.com
"""

import os
import sys
import django
from django.core.management import execute_from_command_line

def main():
    print("=== PJATK App Database Migration Setup ===")
    print()
    
    # Check if .env file exists
    if not os.path.exists('.env'):
        print("ERROR: .env file not found!")
        print("Please create a .env file with your database credentials.")
        print("Example:")
        print("DB_NAME=sql7123456_mydb")
        print("DB_USER=sql7123456")
        print("DB_PASSWORD=YourPassword")
        print("DB_HOST=sql7.freesqldatabase.com")
        print("DB_PORT=3306")
        return
    
    # Set Django settings
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'myproject.settings')
    django.setup()
    
    print("1. Testing database connection...")
    try:
        from django.db import connection
        cursor = connection.cursor()
        cursor.execute("SELECT 1")
        print("✓ Database connection successful!")
    except Exception as e:
        print(f"✗ Database connection failed: {e}")
        print("Please check your .env file and database credentials.")
        return
    
    print("\n2. Running migrations...")
    try:
        execute_from_command_line(['manage.py', 'migrate', '--verbosity=2'])
        print("✓ Migrations completed successfully!")
    except Exception as e:
        print(f"✗ Migration failed: {e}")
        return
    
    print("\n3. Creating superuser (optional)...")
    create_superuser = input("Do you want to create a Django admin superuser? (y/n): ")
    if create_superuser.lower() == 'y':
        try:
            execute_from_command_line(['manage.py', 'createsuperuser'])
        except Exception as e:
            print(f"Superuser creation failed: {e}")
    
    print("\n=== Setup Complete! ===")
    print("Your Django app is now configured to use sql7.freesqldatabase.com")
    print("You can start your server with: python manage.py runserver")

if __name__ == '__main__':
    main()
