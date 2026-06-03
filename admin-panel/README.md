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

## Local Development

### Prerequisites

- Node.js 20+
- A running instance of the [rescue-alert-system backend](../backend) (or point `VITE_API_BASE_URL` at a remote server)

### Setup

```bash
# Install dependencies
npm install

# Copy env template and set your API URL
cp .env.example .env

# Start the dev server
npm run dev
```

The app will be available at `http://localhost:5173`.

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

## Running with Docker Compose

To run the full stack (database + backend + admin panel) together, use the `docker-compose.yml` at the repository root:

```bash
cd ..
docker compose up --build
```

The admin panel will be available at `http://localhost:5173`.

## License

MIT
