import math

from django.contrib.auth.models import User
from django.contrib.gis.geos import Point
from django.contrib.gis.measure import D
from drf_spectacular.utils import extend_schema, OpenApiResponse
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
import firebase_admin.auth

from .models import Alert, DeviceRegistration, UserProfile, Group, Message, Notification
from .serializers import (
    AlertSerializer, DeviceRegistrationSerializer,
    UserProfileSerializer, GroupSerializer, MessageSerializer, NotificationSerializer,
)


def _firebase_uid_from_request(request):
    auth_header = request.META.get('HTTP_AUTHORIZATION', '')
    if not auth_header.startswith('Bearer '):
        return None
    token = auth_header[7:]
    try:
        return firebase_admin.auth.verify_id_token(token)['uid']
    except Exception:
        return None


class WhoAmIView(APIView):
    @extend_schema(
        tags=['TEST'],
        summary='Verify your token works (start here)',
        responses={
            200: OpenApiResponse(description='Token accepted — returns your identity'),
            401: OpenApiResponse(description='Missing, expired, or invalid Firebase token'),
        },
        description=(
            '**Use this before testing anything else.**\n\n'
            'Send your Firebase ID token as `Authorization: Bearer <token>`. '
            'If you get a 200 back with your email, you are authenticated and ready to test all other endpoints.\n\n'
            'If you get 401, your token is missing, expired, or invalid — go back to `/get-token.html` and get a fresh one.'
        ),
    )
    def get(self, request):
        return Response({
            'authenticated': True,
            'firebase_uid': request.user.username,
            'email': request.user.email,
            'name': request.user.get_full_name(),
        })


class RegisterDeviceView(APIView):
    @extend_schema(
        request=DeviceRegistrationSerializer,
        responses={
            204: OpenApiResponse(description='Device registered'),
            401: OpenApiResponse(description='Missing or invalid Firebase token'),
        },
    )
    def post(self, request):
        uid = _firebase_uid_from_request(request)
        if not uid:
            return Response({'error': 'Unauthorized'}, status=401)

        serializer = DeviceRegistrationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        DeviceRegistration.objects.update_or_create(
            firebase_uid=uid,
            device_id=data['device_id'],
            defaults={
                'fcm_token': data['fcm_token'],
                'platform': data['platform'],
                'device_model': data.get('device_model', ''),
            },
        )
        return Response(status=204)


class UserProfileViewSet(viewsets.ModelViewSet):
    queryset = UserProfile.objects.all()
    serializer_class = UserProfileSerializer
    permission_classes = [IsAuthenticated]

    @action(detail=False, methods=['post'])
    def location(self, request):
        profile = request.user.userprofile
        latitude = request.data.get('latitude')
        longitude = request.data.get('longitude')
        if latitude and longitude:
            profile.latitude = float(latitude)
            profile.longitude = float(longitude)
            profile.save()
            return Response(self.get_serializer(profile).data)
        return Response({"error": "latitude and longitude required"}, status=400)

    @action(detail=False, methods=['get'])
    def all(self, request):
        profiles = UserProfile.objects.filter(latitude__isnull=False, longitude__isnull=False)
        return Response(self.get_serializer(profiles, many=True).data)

    @action(detail=False, methods=['get'])
    def profile(self, request):
        return Response(self.get_serializer(request.user.userprofile).data)

    @action(detail=False, methods=['put'])
    def update_profile(self, request):
        serializer = self.get_serializer(request.user.userprofile, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=400)


class GroupViewSet(viewsets.ModelViewSet):
    queryset = Group.objects.all()
    serializer_class = GroupSerializer
    permission_classes = [IsAuthenticated]

    @action(detail=True, methods=['post'])
    def add_user(self, request, pk=None):
        group = self.get_object()
        try:
            group.members.add(User.objects.get(id=request.data.get('user_id')))
            return Response({"message": "User added to group"})
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=404)

    @action(detail=True, methods=['delete'])
    def remove_user(self, request, pk=None):
        group = self.get_object()
        try:
            group.members.remove(User.objects.get(id=request.data.get('user_id')))
            return Response({"message": "User removed from group"})
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=404)


class MessageViewSet(viewsets.ModelViewSet):
    queryset = Message.objects.all()
    serializer_class = MessageSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(sender=self.request.user)

    @action(detail=False, methods=['get'])
    def list_messages(self, request):
        messages = Message.objects.all().order_by('-timestamp')
        return Response(self.get_serializer(messages, many=True).data)


class NotificationViewSet(viewsets.ModelViewSet):
    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


class AlertViewSet(viewsets.ModelViewSet):
    queryset = Alert.objects.all()
    serializer_class = AlertSerializer
    permission_classes = [IsAuthenticated]

    @action(detail=False, methods=['get'])
    def nearby(self, request):
        lat = request.query_params.get('lat')
        lon = request.query_params.get('lon')
        radius = request.query_params.get('radius')

        if not all([lat, lon, radius]):
            return Response(
                {"error": "lat, lon, and radius query parameters are required"},
                status=400
            )

        try:
            lat = float(lat)
            lon = float(lon)
            radius = int(radius)
        except ValueError:
            return Response(
                {"error": "lat and lon must be floats, radius must be an integer"},
                status=400
            )

        user_location = Point(lon, lat, srid=4326)
        all_alerts = Alert.objects.all()
        alerts = []
        for alert in all_alerts:
            if alert.location:
                lat_diff = abs(alert.location.y - lat) * 111000
                lon_diff = abs(alert.location.x - lon) * 111000 * math.cos(math.radians(lat))
                if math.sqrt(lat_diff**2 + lon_diff**2) <= radius:
                    alerts.append(alert)

        return Response(self.get_serializer(alerts, many=True).data)
