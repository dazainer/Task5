# FastAPI DevOps Task

A small FastAPI application for practicing deployment on an Ubuntu AWS server.

The app is intentionally simple so it can be tested locally first, then deployed later behind Nginx and managed with systemd.

## Endpoints

- `GET /` returns a welcome and status message.
- `GET /health` returns a simple health check response.
- `GET /docs` opens the automatic FastAPI Swagger UI.

## Project Structure

```text
.
├── app
│   ├── __init__.py
│   └── main.py
├── requirements.txt
├── update.sh
├── README.md
└── .gitignore
```

## Local Setup

Create and activate a virtual environment:

```bash
python3 -m venv venv
source venv/bin/activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Run the application locally:

```bash
uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
```

Open the app in your browser:

```text
http://127.0.0.1:8000
```

## Test With curl

```bash
curl http://127.0.0.1:8000/
curl http://127.0.0.1:8000/health
```

## Deployment Notes

This project can later be cloned on an Ubuntu server under a path such as:

```text
/var/www/fastapi-task
/home/ubuntu/apps/fastapi-task
```

For server deployment behind Nginx, the app can be run with Uvicorn on local
port `8000`:

```bash
uvicorn app.main:app --host 127.0.0.1 --port 8000
```

## Server Update Script

After the project is deployed on the server and the `fastapi-task` systemd
service exists, run:

```bash
./update.sh
```

The script pulls the latest code from GitHub, installs dependencies, restarts
the `fastapi-task` service, checks `/health`, and writes logs to
`logs/update.log`.

HTTPS is intentionally not included yet.
