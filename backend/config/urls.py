from django.contrib import admin
from django.http import JsonResponse
from django.urls import path, include
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView


def api_404(request, exception=None):
    return JsonResponse({"detail": "Not found."}, status=404)


def api_500(request):
    return JsonResponse({"detail": "Internal server error."}, status=500)


handler404 = "config.urls.api_404"
handler500 = "config.urls.api_500"

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/", include("alerts.urls")),
    path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
    path("api/docs/", SpectacularSwaggerView.as_view(url_name="schema"), name="swagger-ui"),
]
