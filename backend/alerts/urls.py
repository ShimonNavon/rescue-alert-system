from django.urls import path
from rest_framework.routers import DefaultRouter

from .views import (
    AlertViewSet, RegisterDeviceView, WhoAmIView,
    UserProfileViewSet, GroupViewSet, MessageViewSet, NotificationViewSet,
)

router = DefaultRouter()
router.register(r"alerts", AlertViewSet, basename="alert")
router.register(r"user", UserProfileViewSet, basename="user")
router.register(r"group", GroupViewSet, basename="group")
router.register(r"message", MessageViewSet, basename="message")
router.register(r"notification", NotificationViewSet, basename="notification")

urlpatterns = router.urls + [
    # Both spellings are registered on purpose. Shipped mobile builds POST to
    # the slashless form; dropping it would make APPEND_SLASH answer with a 301
    # that most HTTP clients replay as a GET, silently losing the device token.
    # The cost is a drf-spectacular W001 operationId collision, which is
    # cosmetic and resolved with a numeral suffix.
    path('notifications/token', RegisterDeviceView.as_view(), name='register-device'),
    path('notifications/token/', RegisterDeviceView.as_view(), name='register-device-slash'),
    path('auth/whoami/', WhoAmIView.as_view(), name='whoami'),
]
