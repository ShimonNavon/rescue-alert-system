import logging

import firebase_admin.auth
from django.contrib.auth.models import User
from drf_spectacular.extensions import OpenApiAuthenticationExtension
from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed

from .models import UserProfile

logger = logging.getLogger(__name__)


class FirebaseAuthentication(BaseAuthentication):
    def authenticate_header(self, request):
        return 'Bearer'

    def authenticate(self, request):
        auth_header = request.META.get('HTTP_AUTHORIZATION', '')
        if not auth_header.startswith('Bearer '):
            return None

        token = auth_header[7:]
        try:
            decoded = firebase_admin.auth.verify_id_token(token)
        except firebase_admin.auth.ExpiredIdTokenError:
            raise AuthenticationFailed('Firebase token has expired.')
        except firebase_admin.auth.InvalidIdTokenError:
            raise AuthenticationFailed('Firebase token is invalid.')
        except Exception as exc:
            logger.exception('Firebase token verification failed: %s', exc)
            raise AuthenticationFailed('Firebase token could not be verified.')

        uid = decoded['uid']
        email = decoded.get('email', f'{uid}@firebase.local')
        name = decoded.get('name', '')

        user, created = User.objects.get_or_create(
            username=uid,
            defaults={
                'email': email,
                'first_name': name.split(' ')[0] if name else '',
                'last_name': ' '.join(name.split(' ')[1:]) if name else '',
            },
        )

        if not created and user.email != email:
            user.email = email
            user.save(update_fields=['email'])

        UserProfile.objects.get_or_create(user=user)

        return (user, token)


class FirebaseAuthenticationScheme(OpenApiAuthenticationExtension):
    target_class = 'alerts.authentication.FirebaseAuthentication'
    name = 'bearerAuth'

    def get_security_definition(self, auto_schema):
        return {
            'type': 'http',
            'scheme': 'bearer',
            'bearerFormat': 'Firebase ID Token',
        }
