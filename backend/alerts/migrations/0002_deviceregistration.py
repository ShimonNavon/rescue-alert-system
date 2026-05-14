from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('alerts', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='DeviceRegistration',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('firebase_uid', models.CharField(max_length=128)),
                ('device_id', models.CharField(max_length=256)),
                ('fcm_token', models.TextField()),
                ('platform', models.CharField(
                    choices=[('android', 'Android'), ('ios', 'iOS'), ('other', 'Other')],
                    default='other',
                    max_length=10,
                )),
                ('device_model', models.CharField(blank=True, max_length=128)),
                ('last_seen', models.DateTimeField(auto_now=True)),
            ],
            options={
                'indexes': [
                    models.Index(fields=['firebase_uid'], name='alerts_devi_firebas_idx'),
                ],
                'unique_together': {('firebase_uid', 'device_id')},
            },
        ),
    ]
