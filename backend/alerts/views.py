import math

from django.contrib.auth import login as django_login, logout as django_logout
from django.contrib.auth.models import User
from django.contrib.gis.geos import Point
from django.contrib.gis.measure import D
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import ensure_csrf_cookie
from drf_spectacular.utils import extend_schema, OpenApiResponse
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.exceptions import TokenError
from rest_framework_simplejwt.tokens import RefreshToken

from .models import Alert, DeviceRegistration, UserProfile, Group, Message, Notification
from .serializers import (
    AlertSerializer, DeviceRegistrationSerializer,
    UserProfileSerializer, GroupSerializer, MessageSerializer, NotificationSerializer,
    RegisterSerializer, SessionLoginSerializer, UserInfoSerializer,
)


class RegisterView(APIView):
    permission_classes = [AllowAny]

    @extend_schema(
        tags=['auth'],
        request=RegisterSerializer,
        responses={201: OpenApiResponse(description='User created; access and refresh tokens returned')},
        description=(
            'Create an account and receive a JWT pair immediately. '
            'An invite code is required when `REGISTRATION_INVITE_CODE` is configured.'
        ),
    )
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        refresh = RefreshToken.for_user(user)
        return Response(
            {
                'access': str(refresh.access_token),
                'refresh': str(refresh),
                'user': UserInfoSerializer(user).data,
            },
            status=status.HTTP_201_CREATED,
        )


class WhoAmIView(APIView):
    @extend_schema(
        tags=['TEST'],
        summary='Verify your token works (start here)',
        responses={
            200: OpenApiResponse(description='Token accepted — returns your identity'),
            401: OpenApiResponse(description='Missing, expired, or invalid token'),
        },
        description=(
            '**Use this before testing anything else.**\n\n'
            'Send a JWT as `Authorization: Bearer <access>` or sign in through the web session. '
            'If you get a 200 back, you are authenticated and ready to test all other endpoints.'
        ),
    )
    def get(self, request):
        return Response({
            'authenticated': True,
            'user': UserInfoSerializer(request.user).data,
        })


@method_decorator(ensure_csrf_cookie, name='dispatch')
class SessionView(APIView):
    permission_classes = [AllowAny]

    @extend_schema(tags=['auth'], responses={200: OpenApiResponse(description='Current session state')})
    def get(self, request):
        if request.user.is_authenticated:
            return Response({
                'authenticated': True,
                'user': UserInfoSerializer(request.user).data,
            })
        return Response({'authenticated': False, 'user': None})


@method_decorator(ensure_csrf_cookie, name='dispatch')
class SessionLoginView(APIView):
    permission_classes = [AllowAny]

    @extend_schema(
        tags=['auth'],
        request=SessionLoginSerializer,
        responses={200: OpenApiResponse(description='Session established')},
    )
    def post(self, request):
        serializer = SessionLoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data['user']
        django_login(request, user)
        return Response({
            'authenticated': True,
            'user': UserInfoSerializer(user).data,
        })


class SessionLogoutView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(tags=['auth'], responses={204: OpenApiResponse(description='Session closed')})
    def post(self, request):
        django_logout(request)
        return Response(status=204)


class JWTLogoutView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        tags=['auth'],
        request=None,
        responses={205: OpenApiResponse(description='Refresh token blacklisted (if supplied)')},
    )
    def post(self, request):
        token = request.data.get('refresh')
        if token:
            try:
                RefreshToken(token).blacklist()
            except TokenError:
                pass
        return Response(status=205)


class RegisterDeviceView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        tags=['notification'],
        request=DeviceRegistrationSerializer,
        responses={
            204: OpenApiResponse(description='Device registered'),
            401: OpenApiResponse(description='Missing or invalid token'),
        },
    )
    def post(self, request):
        serializer = DeviceRegistrationSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        DeviceRegistration.objects.update_or_create(
            user_uid=str(request.user.pk),
            device_id=data['device_id'],
            defaults={
                'push_token': data['push_token'],
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
