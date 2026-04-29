FROM python:3.10-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8010 \
    CUDA_VISIBLE_DEVICES="" \
    PYTHONPATH=/app/ml_service

WORKDIR /app

COPY ml_service/requirements.txt .

RUN pip install --no-cache-dir \
    --extra-index-url https://download.pytorch.org/whl/cpu \
    -r requirements.txt

COPY . .

EXPOSE 8010

CMD ["uvicorn", "app.keystroke_api:app", "--host", "0.0.0.0", "--port", "8010"]