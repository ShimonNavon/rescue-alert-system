from django.apps import AppConfig


class AlertsConfig(AppConfig):
    name = 'alerts'

    def ready(self):
        # Importing the module connects the post_save receivers. They must live
        # at module level: signal receivers are held weakly by default, and
        # functions defined inside ready() are garbage-collected afterwards.
        from . import signals  # noqa: F401
