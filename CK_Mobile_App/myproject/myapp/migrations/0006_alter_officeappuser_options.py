# Generated by Django 5.1.5 on 2025-01-18 19:04

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('myapp', '0005_remove_officeappuser_isauthenticated'),
    ]

    operations = [
        migrations.AlterModelOptions(
            name='officeappuser',
            options={'managed': False},
        ),
    ]
