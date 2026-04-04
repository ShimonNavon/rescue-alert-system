from django.contrib import admin
from .models import Alert


@admin.register(Alert)
class AlertAdmin(admin.ModelAdmin):
    list_display = ("id", "title", "status", "priority", "created_at")
    list_filter = ("status", "priority", "created_at")
    search_fields = ("title", "description")
    ordering = ("-created_at",)