import numpy as np
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from .model_loader import get_model
from .schemas import KeystrokeInput, PredictionResponse

app = FastAPI(title="Keystroke Emotion API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/predict", response_model=PredictionResponse)
def predict(payload: KeystrokeInput) -> PredictionResponse:
    try:
        model = get_model()

        data = np.array(
            [
                [
                    payload.typing_speed,
                    payload.avg_pause,
                    payload.max_pause,
                    payload.backspace_count,
                    payload.total_time,
                    payload.keystroke_count,
                ]
            ]
        )

        prediction = model.predict(data)[0]

        confidence = 1.0
        if hasattr(model, "predict_proba"):
            probabilities = model.predict_proba(data)[0]
            class_labels = model.classes_
            try:
                label_index = list(class_labels).index(prediction)
                confidence = float(probabilities[label_index])
            except ValueError:
                confidence = float(np.max(probabilities))

        return PredictionResponse(emotion=str(prediction), confidence=confidence)
    except FileNotFoundError as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Prediction failed: {exc}") from exc
