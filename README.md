<p align="center"><img src="assets/banner.svg" alt="Rescue Alert System" width="100%"></p>

<h1>🚑 rescue-alert-system</h1>

<p>
A real-time, location-based volunteer alert system for emergency response.
Built as an <strong>MIT open-source project</strong> for Malachim Badrachim (מלאכים בדרכים), a volunteer initiative focused on helping people in urgent situations on the road and beyond.
</p>

<p>
<strong>Anyone is welcome to clone, use, fork, or adapt this project</strong> to build their own rescue alert system.
</p>

<p>
<strong>Project story:</strong> <a href="https://simonhost.navonsimon.com/blog/building-rescue-alert-system">Architecture and product case study</a> ·
<strong>More work:</strong> <a href="https://simonhost.navonsimon.com/work">16 production projects</a>
</p>
<img width="1024" height="1536" alt="83d6579f-71af-462e-b149-25ca4b15de6b" src="https://github.com/user-attachments/assets/be974be4-5087-4399-b31f-2f231d6860a4" />
<img width="1024" height="1536" alt="8d92784f-2e64-414e-9b5f-ee2e6ee6b678" src="https://github.com/user-attachments/assets/09b88947-761c-4447-8f66-fcd1a0bc6ad7" />
<img width="1536" height="1024" alt="ChatGPT Image May 24, 2026, 03_15_59 PM" src="https://github.com/user-attachments/assets/56f93486-e23c-4d2c-998b-fd9ba7a32dcd" />



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
  <li>Push notifications to nearby responders (planned; currently disabled)</li>
  <li>Accept / decline response flow</li>
  <li>Responder tracking and coordination</li>
</ul>

<hr>

<h2>🧠 How It Works</h2>

<ol>
  <li>A dispatcher creates an alert with a location</li>
  <li>The system finds nearby available volunteers</li>
  <li>Alerts are available to dispatchers and API clients; push delivery is planned</li>
  <li>Volunteers can accept or decline the alert</li>
  <li>Responders are tracked and coordinated by the system</li>
</ol>

<hr>

<h2>🛠 Tech Stack</h2>

<ul>
  <li><strong>Backend:</strong> Django + Django REST Framework</li>
  <li><strong>Database:</strong> PostgreSQL + PostGIS</li>
  <li><strong>Admin Panel:</strong> React 19 + TypeScript + Vite (web dispatcher dashboard)</li>
  <li><strong>Mobile App:</strong> Flutter</li>
  <li><strong>Authentication:</strong> Django users + JWT (SimpleJWT); session cookies for the web panel</li>
  <li><strong>Notifications:</strong> in-app records; push delivery is pending a self-hosted ntfy/UnifiedPush setup</li>
  <li><strong>Infrastructure:</strong> Docker Compose locally; Kubernetes on the deployment cluster</li>
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
docker compose --profile dev up --build
</pre>

<p>
The <code>dev</code> profile adds the Vite dev server for the admin panel. Without it (<code>docker compose up --build</code>) only the backend and database start — which is how production runs, since nginx serves the built panel there.
</p>

<h3>Run Migrations</h3>

<p>The container entrypoint already runs <code>migrate</code> and <code>collectstatic</code> on every start. To run them by hand:</p>

<pre>
docker compose exec backend python manage.py migrate
</pre>

<h3>Service URLs</h3>

<ul>
  <li><strong>Backend API:</strong> <code>http://127.0.0.1:8004</code> (gunicorn on port 8000 inside the container)</li>
  <li><strong>Admin Panel:</strong> <code>http://localhost:5173</code> (<code>dev</code> profile only)</li>
  <li><strong>API docs:</strong> <code>http://127.0.0.1:8004/api/docs/</code></li>
</ul>

<hr>

<h2>🧪 Testing</h2>

<p>Run the admin-panel tests/build, mobile analysis/tests, and the live smoke test:</p>

<pre>
./scripts/test_all.sh
</pre>

<p>
Backend tests need Docker and a PostGIS database; run them with
<code>./scripts/test_backend.sh</code> on a Docker host. The live smoke test targets
<code>http://ubuntu03:30093</code> by default; override it with <code>BASE_URL</code>.
</p>

<hr>

<h2>🖥 Admin Panel</h2>

<p>
The <code>admin-panel/</code> folder contains a React + TypeScript web dashboard for dispatchers and operators. It connects to the same Django API and provides views for managing alerts, monitoring volunteer locations on a map, group messaging, and push-to-talk.
</p>

<h3>Run standalone</h3>

<pre>
cd admin-panel
npm install
cp .env.example .env
npm run dev
</pre>

<p>Available at <code>http://localhost:5173</code>. See <a href="admin-panel/README.md">admin-panel/README.md</a> for full documentation.</p>

<h3>Run with Docker Compose</h3>

<p>The admin panel lives behind the <code>dev</code> profile: <code>docker compose --profile dev up --build</code>.</p>

<hr>

<h2>🚢 Production Deployment</h2>

<p>
<strong>Handoff note:</strong> this work lives on the
<code>feat/django-auth-cluster-deploy</code> branch. Merge it into <code>main</code>
before handing off the default branch.
</p>

<p>
The current deployment runs on the Kubernetes cluster in the <code>rescue-alert</code>
namespace: Django backend, PostGIS, and the built admin panel. The panel and API share
one origin at <code>http://ubuntu03:30093/</code> over Tailscale. There is no TLS yet.
</p>

<p>
Cluster-specific pieces: images are built on <code>ubuntu02</code>, pushed to the
registry on <code>ubuntu04</code>, and the backend/admin pods are pinned to
<code>ubuntu04</code> because that registry listens on its loopback. PostgreSQL data
lives on a <code>local-path</code> PVC.
</p>

<h3>Handoff prerequisites</h3>

<ul>
  <li>Tailscale access to <code>ubuntu03</code> and port <code>30093</code>.</li>
  <li>SSH access to <code>ubuntu03</code> for <code>kubectl</code> and to
      <code>ubuntu02</code> for Docker builds.</li>
  <li>The registry tunnel key (<code>~/.ssh/mr-registry</code>) or matching
      <code>REGISTRY_KEY</code>/<code>REGISTRY_HOST</code> values.</li>
  <li><code>deploy/.env.deploy</code>, shared securely — it is not in Git and contains
      the live superuser password, invite code, and database password.</li>
</ul>

<h3>Build and deploy</h3>

<pre>
# On a Docker host (ubuntu02)
./deploy/build.sh &lt;tag&gt;          # build both images
PUSH=1 ./deploy/build.sh &lt;tag&gt;   # build, push, and update the manifest tags

# From a machine with kubectl access to the cluster
cp deploy/.env.example deploy/.env.deploy   # fill in secrets once
./deploy/deploy.sh
</pre>

<p>
<code>deploy/.env.deploy</code> is gitignored and contains the Django secret, database
password, invite code, and initial superuser credentials. Share it securely with the
next operator. Changing <code>POSTGRES_PASSWORD</code> after the database is initialized
does not change the database's actual password.
</p>

<h3>Access and accounts</h3>

<ul>
  <li>Admin panel: <code>http://ubuntu03:30093/</code> (staff accounts only)</li>
  <li>API docs: <code>http://ubuntu03:30093/api/docs/</code></li>
  <li>Token helper: <code>http://ubuntu03:30093/get-token.html</code></li>
  <li>Django admin: <code>http://ubuntu03:30093/admin/</code></li>
</ul>

<p>
Create the first staff user with
<code>kubectl -n rescue-alert exec deploy/backend -- python manage.py createsuperuser</code>.
New API users register with the invite code from the deployment env file.
</p>

<h3>Known limitations</h3>

<ul>
  <li>Push notifications are disabled until the FCM replacement (ntfy/UnifiedPush) is deployed.</li>
  <li>HTTP only over Tailscale; add TLS/ingress before exposing publicly.</li>
  <li>The admin panel's chat/PTT views and the “new event” modal are still mock/not wired.</li>
  <li>An Android APK has not been built here (Android SDK not installed); iOS needs Xcode/CocoaPods.</li>
  <li>Password resets are manual through Django admin; SMTP is not configured.</li>
  <li>There is no CI pipeline yet; run <code>scripts/test_all.sh</code> and
      <code>scripts/test_backend.sh</code> manually.</li>
  <li>The current database contains demo users, groups, and alerts from
      <code>populate_mock_data</code>.</li>
</ul>

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
