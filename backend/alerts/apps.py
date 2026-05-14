from django.apps import AppConfig


class AlertsConfig(AppConfig):
    name = 'alerts'

    def ready(self):
        import firebase_admin
        if not firebase_admin._apps:
            firebase_admin.initialize_app()

