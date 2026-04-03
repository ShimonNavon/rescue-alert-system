# rescue-alert-system
A real-time location-based volunteer alert system for emergency response, developed for Malachim Badrachim, a volunteer-based initiative focused on helping people in urgent situations on the road and beyond. (מלאכים בדרכים).

.

🚨 Overview

When an incident occurs, the system identifies nearby available volunteers and sends them a push notification, allowing them to respond immediately.

⚙️ Core Features 
Volunteer registration and availability status
Real-time (or recent) location tracking
Incident creation by dispatcher/admin
Radius-based volunteer matching
Push notifications to nearby responders
Accept / decline response system
Responder tracking and coordination

🧠 How It Works
1 - A dispatcher creates an incident with a location
2 - The system finds nearby available volunteers
3 - Notifications are sent in real time
4 - Volunteers can accept or decline the call
5 - Responders are tracked and managed by the system

🛠 Tech Stack (Planned)
Backend: Django + Django REST Framework
Database: PostgreSQL + PostGIS (for geolocation queries)
Mobile App: Flutter
Notifications: Firebase Cloud Messaging (FCM)

📄 License 
This project is licensed under the MIT License.



