# ============================
# Stage 1 — Build dependencies
# ============================
FROM python:3.9 as builder

WORKDIR /app

COPY requirements.txt .

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
    && pip install --no-cache-dir -r requirements.txt \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# ============================
# Stage 2 — Final minimal image
# ============================
FROM python:3.9-slim

WORKDIR /app

# Copy installed Python packages from builder
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copy project files
COPY . /app

EXPOSE 8000

# Example command (change based on your framework)
# CMD ["python", "app.py"]
