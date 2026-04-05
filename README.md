<h1>🚑 rescue-alert-system</h1>

<p>
A real-time, location-based volunteer alert system for emergency response.
Built as an <strong>MIT open-source project</strong> for Malachim Badrachim (מלאכים בדרכים), a volunteer initiative focused on helping people in urgent situations on the road and beyond.
</p>

<p>
<strong>Anyone is welcome to clone, use, fork, or adapt this project</strong> to build their own rescue alert system.
</p>

<hr>

<h2>🚨 Overview</h2>

<p>
When an incident occurs, the system identifies nearby available volunteers and alerts them in real time so they can respond quickly and efficiently.
</p>

<hr>

<h2>⚙️ Core Features</h2>

<ul>
  <li>Volunteer registration and availability status</li>
  <li>Real-time or recent location tracking</li>
  <li>Incident creation by dispatcher/admin</li>
  <li>Radius-based volunteer matching</li>
  <li>Push notifications to nearby responders</li>
  <li>Accept / decline response flow</li>
  <li>Responder tracking and coordination</li>
</ul>

<hr>

<h2>🧠 How It Works</h2>

<ol>
  <li>A dispatcher creates an alert with a location</li>
  <li>The system finds nearby available volunteers</li>
  <li>Notifications are sent in real time</li>
  <li>Volunteers can accept or decline the alert</li>
  <li>Responders are tracked and coordinated by the system</li>
</ol>

<hr>

<h2>🛠 Tech Stack</h2>

<ul>
  <li><strong>Backend:</strong> Django + Django REST Framework</li>
  <li><strong>Database:</strong> PostgreSQL + PostGIS</li>
  <li><strong>Mobile App:</strong> Flutter</li>
  <li><strong>Notifications:</strong> Firebase Cloud Messaging (FCM)</li>
  <li><strong>Infrastructure:</strong> Docker + Docker Compose</li>
</ul>

<hr>

<h2>🚀 Getting Started</h2>

<p>
The project is containerized with Docker to make local setup simpler and more consistent across development environments.
</p>

<h3>Prerequisites</h3>
<ul>
  <li>Git</li>
  <li>Docker</li>
  <li>Docker Compose</li>
</ul>

<h3>Local Setup</h3>

<pre>
git clone https://github.com/ShimonNavon/rescue-alert-system.git
cd rescue-alert-system
cp .env.example .env
docker compose up --build
</pre>

<h3>Run Migrations</h3>

<pre>
docker compose exec backend python manage.py migrate
</pre>

<h3>Backend URL</h3>

<pre>
http://127.0.0.1:8000
</pre>

<hr>

<h2>🤝 Contributing</h2>

<p>
Contributions are welcome. If you want to improve the system, fix bugs, add features, or adapt it for your own organization, feel free to open an issue or submit a pull request.
</p>

<p>
There is also a WhatsApp group for active developers who want to help build the project.
</p>

<hr>

<h2>📚 Documentation</h2>

<p>
For deeper technical and project documentation, see the project Wiki.
</p>

<hr>

<h2>📄 License</h2>

<p>
This project is licensed under the MIT License.
</p>
<!-- test webhook -->
