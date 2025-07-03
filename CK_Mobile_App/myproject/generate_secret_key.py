#!/usr/bin/env python
"""
Generate a new Django secret key for production use
"""

import secrets
import string

def generate_secret_key(length=50):
    """Generate a random secret key suitable for Django"""
    alphabet = string.ascii_letters + string.digits + '!@#$%^&*(-_=+)'
    return ''.join(secrets.choice(alphabet) for i in range(length))

if __name__ == '__main__':
    secret_key = generate_secret_key()
    print("Your new Django secret key:")
    print(secret_key)
    print("\nAdd this to your environment variables as DJANGO_SECRET_KEY")
