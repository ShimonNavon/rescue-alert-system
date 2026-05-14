from django.urls import path
from rest_framework.routers import DefaultRouter

from .views import AlertViewSet, RegisterDeviceView

router = DefaultRouter()
router.register(r"alerts", AlertViewSet, basename="alert")

urlpatterns = router.urls + [
    path('notifications/token', RegisterDeviceView.as_view(), name='register-device'),
]