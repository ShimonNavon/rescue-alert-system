from rest_framework import serializers
from django.contrib.auth.models import User
from django.contrib.gis.geos import Point
from .models import Alert, UserProfile, Group, Message, Notification


class UserProfileSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)
    email = serializers.EmailField(source='user.email', read_only=True)

    class Meta:
        model = UserProfile
        fields = ['id', 'username', 'email', 'role', 'latitude', 'longitude']
        read_only_fields = ['id']


class GroupSerializer(serializers.ModelSerializer):
    members = serializers.PrimaryKeyRelatedField(many=True, queryset=User.objects.all())

    class Meta:
        model = Group
        fields = ['id', 'name', 'members']


class MessageSerializer(serializers.ModelSerializer):
    sender = serializers.SerializerMethodField()
    voice_url = serializers.SerializerMethodField()

    class Meta:
        model = Message
        fields = [
            'id',
            'sender',
            'title',
            'text',
            'voice_file',
            'voice_url',
            'latitude',
            'longitude',
            'timestamp',
        ]
        read_only_fields = ['id', 'timestamp', 'sender']

    def get_sender(self, obj):
        profile = getattr(obj.sender, "userprofile", None)
        return {
            "id": obj.sender.id,
            "username": obj.sender.username,
            "email": obj.sender.email,
            "role": profile.role if profile else None,
        }

    def get_voice_url(self, obj):
        if obj.voice_file:
            return obj.voice_file.url
        return None


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ['id', 'user', 'token']
        read_only_fields = ['id', 'user']


class AlertSerializer(serializers.ModelSerializer):
    latitude = serializers.FloatField()
    longitude = serializers.FloatField()

    class Meta:
        model = Alert
        fields = [
            "id",
            "title",
            "description",
            "latitude",
            "longitude",
            "status",
            "priority",
            "created_at",
            "updated_at",
        ]
        read_only_fields = ["id", "created_at", "updated_at"]

    def to_representation(self, instance):
        data = super().to_representation(instance)
        data["latitude"] = instance.latitude
        data["longitude"] = instance.longitude
        return data

    def validate_latitude(self, value):
        if not (-90 <= value <= 90):
            raise serializers.ValidationError("Latitude must be between -90 and 90.")
        return value

    def validate_longitude(self, value):
        if not (-180 <= value <= 180):
            raise serializers.ValidationError("Longitude must be between -180 and 180.")
        return value

    def create(self, validated_data):
        latitude = validated_data.pop("latitude")
        longitude = validated_data.pop("longitude")
        validated_data["location"] = Point(longitude, latitude, srid=4326)
        return super().create(validated_data)

    def update(self, instance, validated_data):
        latitude = validated_data.pop("latitude", None)
        longitude = validated_data.pop("longitude", None)

        if latitude is not None and longitude is not None:
            instance.location = Point(longitude, latitude, srid=4326)
        elif latitude is not None or longitude is not None:
            raise serializers.ValidationError(
                "Both latitude and longitude must be provided together."
            )

        return super().update(instance, validated_data)