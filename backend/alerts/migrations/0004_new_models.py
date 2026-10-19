import django.contrib.gis.db.models.fields
from django.conf import settings
from django.db import migrations


class Migration(migrations.Migration):
    """
    Converts the Alert model from latitude/longitude floats to a PostGIS location.

    Earlier versions of this migration also re-created UserProfile, Group, Message
    and Notification, which 0001_initial already creates. That made a fresh
    `migrate` fail with "relation already exists", so those operations were
    removed. Databases that applied the old version are unaffected.
    """

    dependencies = [
        ('alerts', '0003_deviceregistration'),
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.RemoveField(model_name='alert', name='latitude'),
        migrations.RemoveField(model_name='alert', name='longitude'),
        migrations.AddField(
            model_name='alert',
            name='location',
            field=django.contrib.gis.db.models.fields.PointField(geography=False, srid=4326),
        ),
    ]
