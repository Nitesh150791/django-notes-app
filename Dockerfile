# ============================
# Stage 1 — Build dependencies
# ============================
FROM python:3.9 AS builder

# Prevent Python from writing .pyc files and buffer stdout/stderr
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# Only copy the requirements first to leverage Docker layer caching
COPY requirements.txt .

# Install build deps and Python deps
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
    && pip install --no-cache-dir -r requirements.txt \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ============================
# Stage 2 — Final minimal image
# ============================
FROM python:3.9-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# (Optional) Create non-root user for better security
RUN useradd --create-home --shell /bin/bash appuser

WORKDIR /app

# Copy installed Python packages and any installed console scripts (e.g., uvicorn, gunicorn)
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy project files
COPY . /app

# Set secure permissions
RUN chown -R appuser:appuser /app

# Switch to non-root
USER appuser

EXPOSE 8000

# ===== Choose ONE of the following CMD lines based on your app =====
# Flask (simple)
# CMD ["python", "app.py"]

# Flask (recommended)
# ENV FLASK_APP=app.py
# CMD ["flask", "run", "--host=0.0.0.0", "--port=8000"]

# FastAPI (uvicorn)
# CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]

# Django
# CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]

# Generic script
# CMD ["python", "main.py"]
