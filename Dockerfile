# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

# Set root user for permissions
USER root

WORKDIR /app

# Enable web support (in case it's not enabled by default in the image)
RUN flutter config --enable-web

# Copy pubspec.yaml and lock if exists
COPY pubspec.* .
RUN flutter pub get

# Copy the rest of the files (filtered by .dockerignore)
COPY . .

# Build for web using HTML renderer (lighter and faster for generic apps)
# --no-tree-shake-icons is used to avoid issues with some font packages
RUN flutter build web --release --no-tree-shake-icons --web-renderer html

# Stage 2: Serve with FastAPI
FROM python:3.9-slim

WORKDIR /app

# Install Python dependencies
COPY deployment/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend code
COPY deployment/app/main.py .

# Copy Flutter Web Build from Stage 1 to a directory named 'web'
COPY --from=build-env /app/build/web ./web

# Expose port (HF uses 7860)
EXPOSE 7860

# Add environment variable for HF
ENV HF_SPACE=true

# Ensure we run as non-root if required, but root is fine for HF
CMD ["python", "main.py"]
