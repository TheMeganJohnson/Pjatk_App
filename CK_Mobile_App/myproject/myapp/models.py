from django.db import models
    
class Timetable(models.Model):
    name = models.CharField(max_length=100)
    room = models.CharField(max_length=9)
    code = models.CharField(max_length=9)
    duration_minutes = models.IntegerField()
    from_datetime = models.DateTimeField()
    group = models.CharField(max_length=20)
    color = models.CharField(max_length=7)
    user = models.CharField(max_length=255)

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
    group = models.CharField(max_length=255)
    user = models.CharField(max_length=255)

    class Meta:
        unique_together = ('name', 'room', 'code', 'from_datetime')
        db_table = 'timetable'
        managed = False


    def __str__(self):
        return (f"Name: {self.name}, Room: {self.room}, Code: {self.code}, "
                f"Duration: {self.duration_minutes} minutes, From: {self.from_datetime}, "
                f"Group: {self.group}, User: {self.user}")