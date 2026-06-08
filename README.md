# KAMKA DevOps Intern Assessment

Three-tier Todo app with Docker, FastAPI, PostgreSQL, monitoring, and CI/CD.

## Quick Start

```bash
git clone https://github.com/mariem-jls/kamka-devops-intern
cd kamka-devops-intern
cp .env.example .env
docker compose up --build
```

## Services

| Service | URL |
|----------|----------|
| Frontend | http://localhost:8080 |
| API | http://localhost:8000 |
| API Docs (Swagger) | http://localhost:8000/docs |
| Monitoring (Uptime Kuma) | http://localhost:3001 |
| pgAdmin | http://localhost:5050 |

pgAdmin credentials: `root@gmail.com / root`

## Production API (live)

```text
https://kamka-devops-intern.onrender.com
https://kamka-devops-intern.onrender.com/docs
```

Note: free tier — cold start may take 30-60 seconds on first request.

## Secrets

Copy `.env.example` to `.env` and fill in your values:

```env
POSTGRES_DB=todos
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_password_here
```

Never commit `.env` — it is gitignored.

CI/CD uses `GITHUB_TOKEN` automatically — no manual secret needed.

## CI/CD Pipeline

GitHub Actions (`.github/workflows/ci-cd.yml`) — 3 stages:

```text
lint → build-and-push → deploy
```

- lint: flake8 on `api/main.py`
- build-and-push: builds Docker images and pushes to GHCR
- deploy: runs on main branch only

Images available at:

```text
ghcr.io/mariem-jls/kamka-devops-intern/kamka-api:latest
ghcr.io/mariem-jls/kamka-devops-intern/kamka-frontend:latest
```

## Bash Script

```bash
./scripts/deploy.sh deploy    # Build and start the stack
./scripts/deploy.sh status    # Check running containers
./scripts/deploy.sh rollback  # Restart without rebuild
./scripts/deploy.sh backup    # Backup PostgreSQL to ./backups/
```

## Project Structure

```text
kamka-devops-intern/
├── api/
│   ├── Dockerfile
│   ├── main.py
│   └── requirements.txt
├── frontend/
│   ├── Dockerfile
│   ├── index.html
│   ├── style.css
│   └── app.js
├── scripts/
│   └── deploy.sh
├── .github/
│   └── workflows/
│       └── ci-cd.yml
├── docker-compose.yml
├── .env.example
└── README.md
```
