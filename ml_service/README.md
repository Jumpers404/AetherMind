# Keystroke ML Microservice

Standalone FastAPI service for keystroke-based emotion prediction.

## Structure

```text
ml_service/
├── app/
│   ├── __init__.py
│   ├── keystroke_api.py
│   ├── model_loader.py
│   └── schemas.py
├── data/
│   └── keystroke_dataset.csv  # place training dataset here
├── model/
│   └── keystroke_model.pkl
├── train/
│   └── train_keystroke_model.py
├── requirements.txt
├── render.yaml
└── README.md
```

## Install

```bash
pip install -r requirements.txt
```

## Train model

Place dataset at `ml_service/data/keystroke_dataset.csv` and run:

```bash
python train/train_keystroke_model.py
```

Optional custom dataset path:

```bash
python train/train_keystroke_model.py --dataset path/to/keystroke_dataset.csv
```

## Run locally

```bash
uvicorn app.keystroke_api:app --reload --host 127.0.0.1 --port 8000
```

## API

- `GET /health`
- `POST /predict`

Request body:

```json
{
  "typing_speed": 6.13,
  "avg_pause": 0.57,
  "max_pause": 1.24,
  "backspace_count": 13,
  "total_time": 48.45,
  "keystroke_count": 297
}
```

Response:

```json
{
  "emotion": "anxiety",
  "confidence": 0.94
}
```

## Deploy (Render)

`render.yaml` is included for direct deployment.
