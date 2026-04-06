from django.shortcuts import render

# Create your views here.
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth.models import User
from django.contrib.gis.geos import Point
from django.contrib.gis.db.models.functions import Distance
from django.contrib.gis.measure import D
from .models import Alert, UserProfile, Group, Message, Notification
from .serializers import AlertSerializer, UserProfileSerializer, GroupSerializer, MessageSerializer, NotificationSerializer
    queryset = UserProfile.objects.all()
    serializer_class = UserProfileSerializer
    permission_classes = [IsAuthenticated]

    @action(detail=False, methods=['post'])
    def location(self, request):
        print(request.path)  # Log path to console
        # POST user location
        profile = request.user.userprofile
        latitude = request.data.get('latitude')
        longitude = request.data.get('longitude')
        if latitude and longitude:
            profile.latitude = float(latitude)
            profile.longitude = float(longitude)
            profile.save()
            serializer = self.get_serializer(profile)
            return Response(serializer.data)
        return Response({"error": "latitude and longitude required"}, status=400)

    @action(detail=False, methods=['get'])
    def all(self, request):
        print(request.path)  # Log path to console
        # GET all users location
        profiles = UserProfile.objects.filter(latitude__isnull=False, longitude__isnull=False)
        serializer = self.get_serializer(profiles, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def profile(self, request):
        print(request.path)  # Log path to console
        # GET current user profile
        profile = request.user.userprofile
        serializer = self.get_serializer(profile)
        return Response(serializer.data)

    @action(detail=False, methods=['put'])
    def update_profile(self, request):
        print(request.path)  # Log path to console
        # PUT update current user data
        profile = request.user.userprofile
        serializer = self.get_serializer(profile, data=request.data, partial=True)
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
        print(request.path)  # Log path to console
        # POST group add user
        group = self.get_object()
        user_id = request.data.get('user_id')
        try:
            user = User.objects.get(id=user_id)
            group.members.add(user)
            return Response({"message": "User added to group"})
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=404)

    @action(detail=True, methods=['delete'])
    def remove_user(self, request, pk=None):
        print(request.path)  # Log path to console
        # DELETE group remove user
        group = self.get_object()
        user_id = request.data.get('user_id')
        try:
            user = User.objects.get(id=user_id)
            group.members.remove(user)
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
        print(request.path)  # Log path to console
        # GET list of messages
        messages = Message.objects.all().order_by('-timestamp')
        serializer = self.get_serializer(messages, many=True)
        return Response(serializer.data)


class NotificationViewSet(viewsets.ModelViewSet):
    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]

    def perform_create(self, serializer):
        print(self.request.path)  # Log path to console
        serializer.save(user=self.request.user)


class AlertViewSet(viewsets.ModelViewSet):
    queryset = Alert.objects.all()
    serializer_class = AlertSerializer

    @action(detail=False, methods=['get'])
    def nearby(self, request):
        print(request.path)  # Log path to console
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

        # Create a point from the provided coordinates
        user_location = Point(lon, lat, srid=4326)

        # Query alerts within the specified radius (in meters)
        alerts = Alert.objects.filter(
            location__distance_lte=(user_location, D(m=radius))
        ).annotate(
            distance=Distance('location', user_location)
        ).order_by('distance')

        serializer = self.get_serializer(alerts, many=True)
        return Response(serializer.data)