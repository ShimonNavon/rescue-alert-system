from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from django.contrib.gis.geos import Point
from django.contrib.gis.measure import D
import firebase_admin.auth

from .models import Alert, DeviceRegistration
from .serializers import AlertSerializer, DeviceRegistrationSerializer


def _firebase_uid_from_request(request):
    auth_header = request.META.get('HTTP_AUTHORIZATION', '')
    if not auth_header.startswith('Bearer '):
        return None
    token = auth_header[7:]
    try:
        return firebase_admin.auth.verify_id_token(token)['uid']
    except Exception:
        return None


class RegisterDeviceView(APIView):
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




class AlertViewSet(viewsets.ModelViewSet):
    queryset = Alert.objects.all()
    serializer_class = AlertSerializer

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

        point = Point(lon, lat, srid=4326)
        alerts = Alert.objects.filter(location__distance_lte=(point, D(m=radius)))
        serializer = self.get_serializer(alerts, many=True)
        return Response(serializer.data)