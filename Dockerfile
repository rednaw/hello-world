FROM python:3.11-slim

# ---- Application setup ----
WORKDIR /app
RUN pip install --no-cache-dir flask
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]

# ---- Infrastructure setup  ----
  ARG IMAGE_TITLE="rednaw/hello-world"
  ARG IMAGE_DESCRIPTION="unset"
  ARG IMAGE_REVISION="unset"
  ARG IMAGE_CREATED="unset"
  ARG IMAGE_SOURCE="unset"
  
  LABEL \
    org.opencontainers.image.title=$IMAGE_TITLE \
    org.opencontainers.image.description=$IMAGE_DESCRIPTION \
    org.opencontainers.image.revision=$IMAGE_REVISION \
    org.opencontainers.image.created=$IMAGE_CREATED \
    org.opencontainers.image.source=$IMAGE_SOURCE
  