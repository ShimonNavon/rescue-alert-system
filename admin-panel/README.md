# Rescue Alert — Admin Panel

Web-based dispatcher/operator dashboard for [rescue-alert-system](https://github.com/ShimonNavon/rescue-alert-system). Allows dispatchers to create alerts, monitor volunteers on a live map, manage groups, and coordinate responses in real time.

## Tech Stack

- **React 19** + **TypeScript**
- **Vite** (build tool)
- **React Router** (client-side routing)
- **Leaflet** + **React Leaflet** (interactive maps)
- **Lucide React** (icons)

## Views

| Route | Description |
|-------|-------------|
| `/` | Login |
| `/events-table` | Alerts / events list |
| `/situation` | Situation overview dashboard |
| `/chat` | Group messaging |
| `/geography` | Live map of volunteers and incidents |
| `/ptt` | Push-to-talk panel |

## Authentication

The panel uses Django session cookies, not Firebase. The login form posts to
`/api/auth/session/login/`; only staff accounts can sign in. All API calls are
same-origin and include cookies automatically. The production build is served by nginx,
which also proxies `/api/`, `/admin/`, and `/static/` to Django.

## Data

The alerts table, situation table, and geography map read live data from
`/api/alerts/` and `/api/user/`. Chat/PTT views and the “new event” modal are still
mock/not wired.

## Local Development

### Prerequisites

- Node.js 20+
- A running backend at `http://localhost:8004` (Docker Compose exposes it there)

### Setup

```bash
npm install
npm run dev
```

`.env.development` already points `VITE_API_BASE_URL` at
`http://localhost:8004/api/`. The dev server runs at `http://localhost:5173`.

Create a staff user in the backend if you do not have one:
`docker compose exec backend python manage.py createsuperuser`.

### Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `VITE_API_BASE_URL` | Base URL of the Django REST API | `http://localhost:8000/api/` |

### Available Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Start development server |
| `npm run build` | Type-check and build for production |
| `npm run preview` | Preview the production build locally |
| `npm run lint` | Run ESLint |
| `npm test` | Run Vitest component tests |

## Running with Docker Compose

To run the full stack (database + backend + admin panel) together, use the `docker-compose.yml` at the repository root:

```bash
cd ..
docker compose --profile dev up --build
```

The admin panel will be available at `http://localhost:5173`.

## License

MIT
