#!/usr/bin/env python
"""
Test API endpoints with your new database setup
"""

import requests
import json
from datetime import datetime

def test_api_endpoints():
    base_url = "http://localhost:8000"
    
    print("=== Testing API Endpoints ===")
    
    # Test 1: List reservations
    print("\n1. Testing list_reservations endpoint...")
    try:
        response = requests.post(
            f"{base_url}/api/list_reservations/",
            json={
                "group": "GIs I.7",
                "date": "2025-07-04"
            },
            headers={'Content-Type': 'application/json'}
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            data = response.json()
            if data.get('status') == 'success':
                print("✓ List reservations endpoint working!")
                print(f"Found {len(data.get('reservations', []))} reservations")
            else:
                print(f"⚠ API returned: {data}")
        else:
            print(f"✗ Failed with status {response.status_code}")
            
    except Exception as e:
        print(f"✗ Error testing list_reservations: {e}")
    
    # Test 2: Create reservation
    print("\n2. Testing create_reservation endpoint...")
    try:
        test_reservation = {
            "name": "Test Reservation",
            "room": "A101",
            "code": "TEST123",
            "duration_minutes": 90,
            "from_datetime": "2025-07-04T10:00:00.000",
            "to_datetime": "2025-07-04T11:30:00.000",
            "group": "GIs I.7",
            "user": "Test User"
        }
        
        response = requests.post(
            f"{base_url}/api/create_reservation/",
            json=test_reservation,
            headers={'Content-Type': 'application/json'}
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 200:
            data = response.json()
            if data.get('status') == 'success':
                print("✓ Create reservation endpoint working!")
            else:
                print(f"⚠ API returned: {data}")
        else:
            print(f"✗ Failed with status {response.status_code}")
            
    except Exception as e:
        print(f"✗ Error testing create_reservation: {e}")

if __name__ == '__main__':
    test_api_endpoints()
