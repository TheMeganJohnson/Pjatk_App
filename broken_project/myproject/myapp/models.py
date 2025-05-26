from django.db import models

class OfficeAppUser(models.Model):
    email = models.EmailField(unique=True)
    password = models.CharField(max_length=100)
    login = models.CharField(max_length=100, unique=True)
    name = models.CharField(max_length=100)
    surname = models.CharField(max_length=100)
    permissions = models.IntegerField(default=0)  # 0 for Student, 1 for Admin
    isAuthenticated = models.SmallIntegerField(default=0)
    group = models.CharField(max_length=10, null=True)

    class Meta:
        managed = False  # No migrations will be created for this model
        db_table = 'office_app_user'  # Table name in the database

    def __str__(self):
        return self.login
    
class Timetable(models.Model):
    name = models.CharField(max_length=100)
    room = models.CharField(max_length=9)
    code = models.CharField(max_length=9)
    duration_minutes = models.IntegerField()
    from_datetime = models.DateTimeField()
    group = models.CharField(max_length=20)
    is_canceled = models.BooleanField(default=False)
    color = models.CharField(max_length=7)
    user = models.CharField(max_length=255)
    verified = models.BooleanField(default=False)

    class Meta:
        db_table = 'timetable'

    def __str__(self):
        return self.name

class Reservation(models.Model):
    name = models.CharField(max_length=255)
    room = models.CharField(max_length=255)
    code = models.CharField(max_length=255)
    duration_minutes = models.IntegerField(default=90)
    from_datetime = models.DateTimeField()
    to_datetime = models.DateTimeField()
    group = models.CharField(max_length=255)
    user = models.CharField(max_length=255)
    verified = models.BooleanField(default=False)

    class Meta:
        unique_together = ('name', 'room', 'code', 'from_datetime', 'to_datetime')
        db_table = 'timetable'
        managed = False


    def __str__(self):
        return (f"Name: {self.name}, Room: {self.room}, Code: {self.code}, "
                f"Duration: {self.duration_minutes} minutes, From: {self.from_datetime}, "
                f"To: {self.to_datetime}, Group: {self.group}, User: {self.user}")