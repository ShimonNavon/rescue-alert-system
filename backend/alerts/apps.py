import os

from django.apps import AppConfig


class AlertsConfig(AppConfig):
    name = 'alerts'

    def ready(self):
        import firebase_admin
        if not firebase_admin._apps:
            cred_path = (
                os.environ.get('FIREBASE_SERVICE_ACCOUNT')
                or os.environ.get('GOOGLE_APPLICATION_CREDENTIALS')
            )
            if cred_path and os.path.exists(cred_path):
                from firebase_admin import credentials
                firebase_admin.initialize_app(credentials.Certificate(cred_path))
            else:
                firebase_admin.initialize_app()

        from django.db.models.signals import post_save
        from django.dispatch import receiver
        from django.contrib.auth.models import User
        from .models import UserProfile

        @receiver(post_save, sender=User)
        def create_user_profile(sender, instance, created, **kwargs):
            if created:
                UserProfile.objects.create(user=instance)

        @receiver(post_save, sender=User)
        def save_user_profile(sender, instance, **kwargs):
            if hasattr(instance, 'userprofile'):
                instance.userprofile.save()
