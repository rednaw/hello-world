FROM python:3.11-slim

# ---- Build-time metadata (with safe defaults) ----
ARG IMAGE_TITLE="rednaw/hello-world"
ARG IMAGE_DESCRIPTION="Hello World Flask app"
ARG IMAGE_REVISION="dev"
ARG IMAGE_CREATED="unknown"
ARG IMAGE_SOURCE="unknown"

# ---- OCI labels written into image config ----
LABEL \
  org.opencontainers.image.title=$IMAGE_TITLE \
  org.opencontainers.image.description=$IMAGE_DESCRIPTION \
  org.opencontainers.image.revision=$IMAGE_REVISION \
  org.opencontainers.image.created=$IMAGE_CREATED \
  org.opencontainers.image.source=$IMAGE_SOURCE

# ---- Application setup ----
WORKDIR /app

# Install dependencies
RUN pip install --no-cache-dir flask

# Copy application code
COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
