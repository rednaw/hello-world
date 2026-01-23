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
RUN pip install flask
WORKDIR /app

# Create a simple hello world app
RUN echo 'from flask import Flask\n\
app = Flask(__name__)\n\
@app.route("/")\n\
def hello():\n\
    return "Hello from Docker Registry! Registry is working! 🎉 Version 0.0.3"\n\
if __name__ == "__main__":\n\
    app.run(host="0.0.0.0", port=5000)' > app.py

EXPOSE 5000

CMD ["python", "app.py"]
