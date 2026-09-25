# Project 2 – Django + PostgreSQL with Docker Compose, Deployed by Jenkins

A Django web server and a PostgreSQL database defined in a single **docker-compose.yml**, deployed automatically through a **Jenkins Pipeline** pulled from **GitHub**.
Reference: https://docs.docker.com/samples/django/

## Tech Stack
Docker Compose · Jenkins · GitHub · Django 5 · PostgreSQL 16

## Project Structure
```
django-postgres-compose-jenkins/
├── Dockerfile            # Builds the Django image
├── docker-compose.yml    # Launches django (web) + postgres (db)
├── entrypoint.sh         # Waits for DB, runs migrations, starts server
├── requirements.txt
├── manage.py
├── composeexample/       # Django project (settings, urls, views)
├── Jenkinsfile           # Pipeline: Checkout -> Deploy -> Verify
└── scripts/
    ├── deploy.sh         # docker compose down + up --build
    └── verify.sh         # Health check on /health (also checks DB)
```

## Services
| Service | Container | Image | Port |
|---|---|---|---|
| web (Django) | `django-web` | `django-web` (built from Dockerfile) | 8000 |
| db (Postgres) | `postgres-db` | `postgres:16` | internal only |

The `db` service has a healthcheck, and `web` starts only after Postgres is healthy. Data is stored in the named volume `postgres_data`, so it survives redeployments.

## Prerequisites (on the Jenkins server)
```bash
sudo apt update && sudo apt install -y docker.io docker-compose-v2 curl
sudo systemctl enable --now docker
docker compose version          # verify Compose is installed

# Allow Jenkins to use Docker, then restart Jenkins
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```
If `docker-compose-v2` isn't available in your distro, install the Compose plugin from Docker's official repo (`docker-compose-plugin`). The deploy script works with both `docker compose` and `docker-compose`.

Open port **8000** in the server firewall / cloud security group.

## Run Locally (without Jenkins)
```bash
docker compose up -d --build
docker compose ps
# open http://localhost:8000
docker compose down            # stop (add -v to also delete DB data)
```

Optional – create an admin user:
```bash
docker exec -it django-web python manage.py createsuperuser
# then open http://localhost:8000/admin
```

## Create the Jenkins Pipeline Job
1. Jenkins Dashboard → **New Item** → name `django-compose-deploy` → **Pipeline** → OK.
2. **Pipeline → Definition:** Pipeline script from SCM.
3. **SCM:** Git → **Repository URL:** `https://github.com/<your-username>/django-postgres-compose-jenkins.git`
4. **Branch:** `*/main` → **Script Path:** `Jenkinsfile` → **Save**.
5. Click **Build Now** and check the **Console Output**.

## Test the Application in Browser
- Home: `http://<SERVER-IP>:8000` – shows the container ID and the connected PostgreSQL version.
- Health: `http://<SERVER-IP>:8000/health` → `{"status": "UP", "database": "UP"}`
- Admin: `http://<SERVER-IP>:8000/admin`

## Configuration
Database credentials default to `postgres/postgres`. To change them, create a `.env` file next to `docker-compose.yml` (it is git-ignored):
```
POSTGRES_DB=appdb
POSTGRES_USER=appuser
POSTGRES_PASSWORD=StrongPassword123
```

## Troubleshooting
| Problem | Fix |
|---|---|
| `permission denied ... docker.sock` | `sudo usermod -aG docker jenkins && sudo systemctl restart jenkins` |
| `docker compose: command not found` | Install `docker-compose-v2` / `docker-compose-plugin` |
| Web container keeps restarting | `docker logs django-web` – usually DB credentials mismatch; run `docker compose down -v` to reset DB |
| Page not opening from browser | Open port 8000 in firewall / security group |

> Note: this uses Django's development server, which is fine for a learning project. For production, switch to Gunicorn behind Nginx and set `DJANGO_DEBUG=False`.
