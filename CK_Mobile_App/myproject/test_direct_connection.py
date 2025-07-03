#!/usr/bin/env python
"""
Test direct database connection using PyMySQL
"""

import pymysql
import os
from dotenv import load_dotenv

load_dotenv()

def test_connection():
    try:
        connection = pymysql.connect(
            host=os.getenv('DB_HOST', 'sql7.freesqldatabase.com'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD'),
            database=os.getenv('DB_NAME'),
            port=int(os.getenv('DB_PORT', '3306')),
            charset='utf8'
        )
        
        print("✓ Direct PyMySQL connection successful!")
        
        # Test a simple query
        cursor = connection.cursor()
        cursor.execute("SELECT VERSION()")
        version = cursor.fetchone()
        print(f"MySQL Version: {version[0]}")
        
        # Test if timetable exists
        cursor.execute("SHOW TABLES LIKE 'timetable'")
        result = cursor.fetchone()
        if result:
            print("✓ 'timetable' table exists")
        else:
            print("⚠ 'timetable' table does not exist - you may need to create it")
        
        cursor.close()
        connection.close()
        return True
        
    except Exception as e:
        print(f"✗ Connection failed: {e}")
        return False

if __name__ == '__main__':
    print("=== Direct Database Connection Test ===")
    test_connection()
