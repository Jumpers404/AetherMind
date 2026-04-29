"""FastAPI ML microservice

Exposes two primary endpoints:
- POST /predict        -> keystroke-based prediction (KeystrokeInput)
- POST /predict/text   -> text-based prediction (TextInput)

The API returns the stable contract `PredictionResponse` with keys:
 - emotion: str
 - confidence: float

Notes:
 - Keystroke model is loaded via joblib; missing model file yields 500.
 - Text prediction delegates to the transformer-based helper in
     `text_emotion.py` and returns a normalized label + confidence.
"""

import numpy as np
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from .model_loader import get_model
from .schemas import KeystrokeInput, PredictionResponse, TextInput
from .text_emotion import analyze_text_emotion


def _extract_confidence(model, data: np.ndarray, prediction: str) -> float:
    if hasattr(model, "predict_proba"):
        probabilities = model.predict_proba(data)[0]
        if hasattr(model, "classes_"):
            class_labels = model.classes_
            try:
                label_index = list(class_labels).index(prediction)
                return float(probabilities[label_index])
            except ValueError:
                pass
        return float(np.max(probabilities))

    if hasattr(model, "decision_function"):
        scores = np.asarray(model.decision_function(data), dtype=np.float32)
        if scores.ndim == 1:
            # Binary case -> logistic transform.
            prob_pos = float(1.0 / (1.0 + np.exp(-scores[0])))
            if hasattr(model, "classes_") and len(model.classes_) == 2:
                return prob_pos if prediction == model.classes_[1] else 1.0 - prob_pos
            return max(prob_pos, 1.0 - prob_pos)

        # Multiclass case -> softmax transform.
        row = scores[0]
        row = row - np.max(row)
        exp_scores = np.exp(row)
        probs = exp_scores / np.sum(exp_scores)
        if hasattr(model, "classes_"):
            class_labels = model.classes_
            try:
                label_index = list(class_labels).index(prediction)
                return float(probs[label_index])
            except ValueError:
                pass
        return float(np.max(probs))

    # Conservative fallback when probability-like interfaces are unavailable.
    return 1.0

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
            ],
            dtype=np.float32,
        )

        prediction = model.predict(data)[0]
        confidence = _extract_confidence(model, data, prediction)

        return PredictionResponse(emotion=str(prediction), confidence=confidence)
    except FileNotFoundError as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
    except Exception as exc:
        import traceback
        traceback.print_exc()
        raise exc


@app.post("/predict/text", response_model=PredictionResponse)
def predict_text(payload: TextInput) -> PredictionResponse:
    try:
        result = analyze_text_emotion(payload.text)
        return PredictionResponse(
            emotion=str(result.get("emotion", "neutral")),
            confidence=float(result.get("confidence", 0.0)),
        )
    except Exception as exc:
        import traceback
        traceback.print_exc()
        raise exc
