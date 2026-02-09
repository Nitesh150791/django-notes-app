
FROM python:3.9 as builder

WORKDIR /app

COPY  requirements.txt /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && pip install --no-cache-dir -r requirements.txt

FROM python:3.9-slim

WORKDIR /app

COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY . /app

EXPOSE 8000
