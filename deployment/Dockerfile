FROM python:3.9-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend code
COPY app/main.py .

# Copy Flutter Web Build (we'll copy this after the build finishes)
COPY build/web ./web

# Expose port (HF uses 7860)
EXPOSE 7860

CMD ["python", "main.py"]
