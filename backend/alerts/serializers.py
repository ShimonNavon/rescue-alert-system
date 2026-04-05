from rest_framework import serializers
from django.contrib.auth.models import User
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
    sender = serializers.StringRelatedField(read_only=True)
    voice_url = serializers.SerializerMethodField()

    class Meta:
        model = Message
        fields = ['id', 'sender', 'title', 'text', 'voice_file', 'voice_url', 'latitude', 'longitude', 'timestamp']
        read_only_fields = ['id', 'timestamp']

    def get_voice_url(self, obj):
        if obj.voice_file:
            return obj.voice_file.url
        return None


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ['id', 'user', 'token']
        read_only_fields = ['id']


class AlertSerializer(serializers.ModelSerializer):
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