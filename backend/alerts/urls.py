from rest_framework.routers import DefaultRouter
from .views import AlertViewSet, UserProfileViewSet, GroupViewSet, MessageViewSet, NotificationViewSet

router = DefaultRouter()
router.register(r"alerts", AlertViewSet, basename="alert")
router.register(r"user", UserProfileViewSet, basename="user")
router.register(r"group", GroupViewSet, basename="group")
router.register(r"message", MessageViewSet, basename="message")
router.register(r"notification", NotificationViewSet, basename="notification")

urlpatterns = router.urls