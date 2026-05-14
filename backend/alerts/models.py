from django.contrib.gis.db import models


class DeviceRegistration(models.Model):
    class Platform(models.TextChoices):
        ANDROID = 'android', 'Android'
        IOS = 'ios', 'iOS'
        OTHER = 'other', 'Other'

    firebase_uid = models.CharField(max_length=128)
    device_id = models.CharField(max_length=256)
    fcm_token = models.TextField()
    platform = models.CharField(max_length=10, choices=Platform.choices, default=Platform.OTHER)
    device_model = models.CharField(max_length=128, blank=True)
    last_seen = models.DateTimeField(auto_now=True)

    class Meta:
        unique_together = [('firebase_uid', 'device_id')]
        indexes = [models.Index(fields=['firebase_uid'])]

    def __str__(self):
        return f'{self.firebase_uid} / {self.platform} / {self.device_model}'


class Alert(models.Model):
    class Status(models.TextChoices):
        OPEN = "OPEN", "Open"
        DISPATCHED = "DISPATCHED", "Dispatched"
        ACCEPTED = "ACCEPTED", "Accepted"
        IN_PROGRESS = "IN_PROGRESS", "In Progress"
        RESOLVED = "RESOLVED", "Resolved"
        CANCELLED = "CANCELLED", "Cancelled"

    class Priority(models.TextChoices):
        LOW = "LOW", "Low"
        MEDIUM = "MEDIUM", "Medium"
        HIGH = "HIGH", "High"
        CRITICAL = "CRITICAL", "Critical"

    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    location = models.PointField(geography=True)
    status = models.CharField(
        max_length=20,
        choices=Status.choices,
        default=Status.OPEN,
    )
    priority = models.CharField(
        max_length=10,
        choices=Priority.choices,
        default=Priority.MEDIUM,
    )
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.title} ({self.status})"