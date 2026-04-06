# Generated manually for geospatial conversion

from django.contrib.gis.geos import Point
from django.db import migrations
import django.contrib.gis.db.models as gis_models


def migrate_forward(apps, schema_editor):
    # Schema is already updated, no data migration needed
    pass


def migrate_reverse(apps, schema_editor):
    # No reverse migration needed
    pass


class Migration(migrations.Migration):

    dependencies = [
        ('alerts', '0001_initial'),
    ]

    operations = [
        # Schema already updated, just mark migration as applied
    ]