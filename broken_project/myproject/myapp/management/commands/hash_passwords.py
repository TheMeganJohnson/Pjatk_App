from django.core.management.base import BaseCommand
from django.contrib.auth.hashers import make_password
from myapp.models import OfficeAppUser

class Command(BaseCommand):
    help = 'Hash plain text passwords for existing users'

    def handle(self, *args, **kwargs):
        users = OfficeAppUser.objects.all()
        for user in users:
            if not user.password.startswith('pbkdf2_'):  # Check if the password is already hashed
                user.password = make_password(user.password)
                user.save()
                self.stdout.write(self.style.SUCCESS(f'Password hashed for user {user.login}'))