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

For server deployment, the app can be run with Uvicorn on port `8000`:

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

Nginx, systemd, HTTPS, and update scripts are intentionally not included yet.
