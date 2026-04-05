from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from alerts.models import UserProfile, Group, Message, Alert
import random


class Command(BaseCommand):
    help = 'Populate database with mock data for testing'

    def handle(self, *args, **options):
        self.stdout.write('Creating mock data...')

        # Create test users
        users_data = [
            {'username': 'rescuer1', 'email': 'rescuer1@example.com', 'role': 'rescuer', 'lat': 40.7589, 'lon': -73.9851},
            {'username': 'rescuer2', 'email': 'rescuer2@example.com', 'role': 'rescuer', 'lat': 40.7505, 'lon': -73.9934},
            {'username': 'user1', 'email': 'user1@example.com', 'role': 'user', 'lat': 40.7282, 'lon': -73.7949},
            {'username': 'user2', 'email': 'user2@example.com', 'role': 'user', 'lat': 40.6501, 'lon': -73.9496},
            {'username': 'user3', 'email': 'user3@example.com', 'role': 'user', 'lat': 40.7831, 'lon': -73.9712},
        ]

        users = []
        for user_data in users_data:
            user, created = User.objects.get_or_create(
                username=user_data['username'],
                defaults={'email': user_data['email']}
            )
            if created:
                user.set_password('test123')
                user.save()

            profile, created = UserProfile.objects.get_or_create(
                user=user,
                defaults={
                    'role': user_data['role'],
                    'latitude': user_data['lat'],
                    'longitude': user_data['lon']
                }
            )
            users.append(user)
            self.stdout.write(f'Created user: {user.username}')

        # Create groups
        groups_data = [
            {'name': 'Manhattan Rescuers', 'members': [users[0], users[1]]},
            {'name': 'Brooklyn Responders', 'members': [users[0], users[3]]},
            {'name': 'Emergency Team Alpha', 'members': users[:3]},
        ]

        groups = []
        for group_data in groups_data:
            group, created = Group.objects.get_or_create(
                name=group_data['name']
            )
            if created:
                group.members.set(group_data['members'])
                group.save()
            groups.append(group)
            self.stdout.write(f'Created group: {group.name}')

        # Create messages
        messages_data = [
            {'sender': users[2], 'title': 'Medical Emergency', 'text': 'Person collapsed in Central Park', 'lat': 40.7829, 'lon': -73.9654},
            {'sender': users[3], 'title': 'Fire Alarm', 'text': 'Smoke detected in apartment building', 'lat': 40.6782, 'lon': -73.9442},
            {'sender': users[4], 'title': 'Car Accident', 'text': 'Two vehicles collision on highway', 'lat': 40.7589, 'lon': -73.9851},
            {'sender': users[2], 'title': 'Lost Child', 'text': '5-year-old missing in Times Square area', 'lat': 40.7580, 'lon': -73.9855},
            {'sender': users[0], 'title': 'Team Update', 'text': 'Rescue team en route to incident', 'lat': 40.7505, 'lon': -73.9934},
        ]

        for msg_data in messages_data:
            message = Message.objects.create(
                sender=msg_data['sender'],
                title=msg_data['title'],
                text=msg_data['text'],
                latitude=msg_data['lat'],
                longitude=msg_data['lon']
            )
            self.stdout.write(f'Created message: {message.title}')

        # Create alerts
        alerts_data = [
            {'title': 'Building Fire', 'description': 'Multiple floors affected', 'lat': 40.7505, 'lon': -73.9934, 'priority': 'HIGH', 'status': 'OPEN'},
            {'title': 'Flood Warning', 'description': 'Rising water levels in subway', 'lat': 40.7589, 'lon': -73.9851, 'priority': 'MEDIUM', 'status': 'DISPATCHED'},
            {'title': 'Power Outage', 'description': 'Entire neighborhood affected', 'lat': 40.7282, 'lon': -73.7949, 'priority': 'LOW', 'status': 'RESOLVED'},
        ]

        for alert_data in alerts_data:
            alert = Alert.objects.create(
                title=alert_data['title'],
                description=alert_data['description'],
                latitude=alert_data['lat'],
                longitude=alert_data['lon'],
                priority=alert_data['priority'],
                status=alert_data['status']
            )
            self.stdout.write(f'Created alert: {alert.title}')

        self.stdout.write(self.style.SUCCESS('Mock data created successfully!'))
        self.stdout.write('Test users: rescuer1, rescuer2, user1, user2, user3 (password: test123)')
        self.stdout.write('Admin user: admin (password: admin123)')