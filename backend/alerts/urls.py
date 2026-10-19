from django.urls import path
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from .views import (
    AlertViewSet, RegisterDeviceView, WhoAmIView,
    UserProfileViewSet, GroupViewSet, MessageViewSet, NotificationViewSet,
    RegisterView, SessionView, SessionLoginView, SessionLogoutView, JWTLogoutView,
)

router = DefaultRouter()
router.register(r"alerts", AlertViewSet, basename="alert")
router.register(r"user", UserProfileViewSet, basename="user")
router.register(r"group", GroupViewSet, basename="group")
router.register(r"message", MessageViewSet, basename="message")
router.register(r"notification", NotificationViewSet, basename="notification")

urlpatterns = router.urls + [
    # JWT auth for the mobile app and API clients.
    path('token/', TokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('auth/register/', RegisterView.as_view(), name='register'),
    path('auth/logout/', JWTLogoutView.as_view(), name='jwt-logout'),
    path('auth/whoami/', WhoAmIView.as_view(), name='whoami'),

    # Cookie-session auth for the web admin panel (same origin behind nginx).
    path('auth/session/', SessionView.as_view(), name='session'),
    path('auth/session/login/', SessionLoginView.as_view(), name='session-login'),
    path('auth/session/logout/', SessionLogoutView.as_view(), name='session-logout'),

    # Both spellings are registered on purpose. Shipped mobile builds POST to
    # the slashless form; dropping it would make APPEND_SLASH answer with a 301
    # that most HTTP clients replay as a GET, silently losing the device token.
    # The cost is a drf-spectacular W001 operationId collision, which is
    # cosmetic and resolved with a numeral suffix.
    path('notifications/token', RegisterDeviceView.as_view(), name='register-device'),
    path('notifications/token/', RegisterDeviceView.as_view(), name='register-device-slash'),
]
