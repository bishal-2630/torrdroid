# Stage 1: Build Flutter Web
FROM debian:latest AS build-env

RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils libglu1-mesa \
    python3 python3-pip

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"
RUN flutter doctor -v
RUN flutter channel stable
RUN flutter upgrade

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

CMD ["python", "main.py"]
