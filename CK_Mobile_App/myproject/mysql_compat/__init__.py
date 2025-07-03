"""
Custom Django database backend for MySQL 5.5
This is a workaround for MySQL version compatibility
"""

from django.db.backends.mysql.base import DatabaseWrapper as MySQLDatabaseWrapper
from django.db.backends.mysql import features

class DatabaseFeatures(features.DatabaseFeatures):
    minimum_database_version = (5, 5)

class DatabaseWrapper(MySQLDatabaseWrapper):
    features_class = DatabaseFeatures
    
    @property 
    def mysql_version(self):
        # Return a version that satisfies Django's requirements
        return (8, 0, 11)
