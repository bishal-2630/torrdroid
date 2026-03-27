# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

# Set root user for permissions
USER root

# Copy project files
WORKDIR /app
COPY pubspec.yaml .
RUN flutter pub get

COPY . .
RUN flutter build web --release --no-tree-shake-icons

# Stage 2: Serve with FastAPI
FROM python:3.9-slim

WORKDIR /app

# Install Python dependencies
COPY deployment/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend code
COPY deployment/app/main.py .

# Copy Flutter Web Build from Stage 1
COPY --from=build-env /app/build/web ./web

# Expose port
EXPOSE 7860

# Add environment variable for HF
ENV HF_SPACE=true

CMD ["python", "main.py"]
