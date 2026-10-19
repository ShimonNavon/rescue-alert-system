from django.contrib.auth.models import User
from django.test import override_settings
from rest_framework.test import APITestCase

from .models import DeviceRegistration


@override_settings(REGISTRATION_INVITE_CODE='invite-123')
class AuthApiTests(APITestCase):
    def register(self, email='new@example.com', password='strongpass123', invite='invite-123'):
        return self.client.post(
            '/api/auth/register/',
            {
                'email': email,
                'password': password,
                'full_name': 'New Responder',
                'invite_code': invite,
            },
            format='json',
        )

    def test_register_login_refresh_and_whoami(self):
        response = self.register()
        self.assertEqual(response.status_code, 201)
        access = response.data['access']
        refresh = response.data['refresh']
        self.assertEqual(response.data['user']['username'], 'new@example.com')
        self.assertEqual(response.data['user']['role'], 'user')

        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {access}')
        whoami = self.client.get('/api/auth/whoami/')
        self.assertEqual(whoami.status_code, 200)
        self.assertEqual(whoami.data['user']['email'], 'new@example.com')
        self.assertEqual(self.client.get('/api/alerts/').status_code, 200)

        self.client.credentials()
        refreshed = self.client.post('/api/token/refresh/', {'refresh': refresh}, format='json')
        self.assertEqual(refreshed.status_code, 200)
        self.assertIn('access', refreshed.data)

    def test_login_with_email(self):
        self.register()
        self.client.credentials()
        response = self.client.post(
            '/api/token/',
            {'username': 'new@example.com', 'password': 'strongpass123'},
            format='json',
        )
        self.assertEqual(response.status_code, 200)
        self.assertIn('access', response.data)

    def test_register_requires_valid_invite(self):
        response = self.register(invite='wrong')
        self.assertEqual(response.status_code, 400)
        self.assertIn('invite_code', response.data)

    def test_duplicate_email_is_rejected(self):
        self.assertEqual(self.register().status_code, 201)
        response = self.register()
        self.assertEqual(response.status_code, 400)
        self.assertIn('email', response.data)

    def test_alerts_require_authentication(self):
        self.assertEqual(self.client.get('/api/alerts/').status_code, 401)

    def test_whoami_requires_authentication(self):
        self.assertEqual(self.client.get('/api/auth/whoami/').status_code, 401)

    def test_device_registration_requires_authentication(self):
        response = self.client.post(
            '/api/notifications/token',
            {
                'push_token': 'topic-1',
                'device_id': 'device-1',
                'platform': 'android',
                'device_model': 'Pixel',
            },
            format='json',
        )
        self.assertEqual(response.status_code, 401)

    def test_jwt_logout_blacklists_refresh_token(self):
        response = self.register()
        access = response.data['access']
        refresh = response.data['refresh']

        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {access}')
        logged_out = self.client.post(
            '/api/auth/logout/',
            {'refresh': refresh},
            format='json',
        )
        self.assertEqual(logged_out.status_code, 205)

        self.client.credentials()
        refreshed = self.client.post(
            '/api/token/refresh/',
            {'refresh': refresh},
            format='json',
        )
        self.assertEqual(refreshed.status_code, 401)

    def test_device_registration_ties_to_authenticated_user(self):
        response = self.register()
        self.client.credentials(HTTP_AUTHORIZATION=f"Bearer {response.data['access']}")
        registered = self.client.post(
            '/api/notifications/token',
            {
                'push_token': 'topic-1',
                'device_id': 'device-1',
                'platform': 'android',
                'device_model': 'Pixel',
            },
            format='json',
        )
        self.assertEqual(registered.status_code, 204)

        user = User.objects.get(email='new@example.com')
        device = DeviceRegistration.objects.get(user_uid=str(user.pk), device_id='device-1')
        self.assertEqual(device.push_token, 'topic-1')


class SessionAuthTests(APITestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='dispatcher',
            email='dispatcher@example.com',
            password='strongpass123',
            is_staff=True,
        )

    def test_session_login_and_logout(self):
        anonymous = self.client.get('/api/auth/session/')
        self.assertEqual(anonymous.status_code, 200)
        self.assertFalse(anonymous.data['authenticated'])

        logged_in = self.client.post(
            '/api/auth/session/login/',
            {'username': 'dispatcher@example.com', 'password': 'strongpass123'},
            format='json',
        )
        self.assertEqual(logged_in.status_code, 200)
        self.assertTrue(logged_in.data['authenticated'])

        current = self.client.get('/api/auth/session/')
        self.assertTrue(current.data['authenticated'])
        self.assertEqual(current.data['user']['username'], 'dispatcher')

        logged_out = self.client.post('/api/auth/session/logout/')
        self.assertEqual(logged_out.status_code, 204)
        self.assertFalse(self.client.get('/api/auth/session/').data['authenticated'])

    def test_session_login_rejects_non_staff(self):
        User.objects.create_user(
            username='volunteer',
            email='volunteer@example.com',
            password='strongpass123',
        )
        response = self.client.post(
            '/api/auth/session/login/',
            {'username': 'volunteer@example.com', 'password': 'strongpass123'},
            format='json',
        )
        self.assertEqual(response.status_code, 400)
        self.assertIn('non_field_errors', response.data)
