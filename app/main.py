from fastapi import FastAPI


app = FastAPI(
    title="FastAPI DevOps Task 5",
    description="A simple FastAPI app for Ubuntu deployment.",
    version="1.0.0",
)


@app.get("/")
def read_root() -> dict[str, str]:
    """Return a small welcome message and status response."""
    return {
        "message": "Welcome to the FastAPI DevOps Task 5 API.",
        "status": "running",
        "docs": "/docs",
        "health": "/health",
    }


@app.get("/health")
def health_check() -> dict[str, str]:
    """Return a basic health check response."""
    return {
        "status": "OK",
        "service": "fastapi-task",
    }
