"""Model loader and prediction helpers.

Responsibilities:
- Load and cache the keystroke scikit-learn model (joblib) in a thread-safe
  manner using a lock. If the model file is missing a FileNotFoundError is
  raised and propagated as a 500 from the API.
- Load and cache the transformer tokenizer+model used for text emotion
  prediction. The model is loaded into CPU and run with `torch.no_grad()`.
- Normalize some text labels (e.g., 'sad' -> 'sadness') to keep a stable
  emotion vocabulary for clients.

Performance note: The module sets Torch to single-threaded operation to
reduce CPU contention on small host instances. Adjust `torch.set_num_threads`
if you deploy to machines with more cores.
"""

import re
from pathlib import Path
from threading import Lock

import numpy as np
import joblib
import torch
from transformers import AutoModelForSequenceClassification, AutoTokenizer

_model = None
_text_model_components = None

_keystroke_model_lock = Lock()
_text_model_lock = Lock()

_whitespace_re = re.compile(r"\s+")

TEXT_MODEL_DEVICE = torch.device("cpu")

# Optional: reduce CPU contention
torch.set_num_threads(1)
DEFAULT_TEXT_MODEL_NAME = "j-hartmann/emotion-english-distilroberta-base"

LABEL_NORMALIZATION_MAP = {
    "sad": "sadness",
    "joy": "happy",
    "anger": "angry",
    "fear": "anxious",
    "surprise": "surprised",
    "love": "love",
    "neutral": "neutral",
}


def get_model():
    global _model
    if _model is None:
        with _keystroke_model_lock:
            if _model is None:
                model_path = Path(__file__).resolve().parents[1] / "model" / "keystroke_model.pkl"
                if not model_path.exists():
                    raise FileNotFoundError(f"Model file not found: {model_path}")
                _model = joblib.load(model_path)
    return _model


def _normalize_emotion_label(label: str) -> str:
    key = (label or "").strip().lower()
    return LABEL_NORMALIZATION_MAP.get(key, key or "neutral")


def _preprocess_text(raw_text: str) -> str:
    text = (raw_text or "").strip().lower()
    if not text:
        return ""
    return _whitespace_re.sub(" ", text)


def get_text_model_components(model_name: str = DEFAULT_TEXT_MODEL_NAME):
    """
    Returns a globally cached tuple of (tokenizer, model, id_to_label).
    The model is loaded only once per process.
    """
    global _text_model_components
    if _text_model_components is None:
        with _text_model_lock:
            if _text_model_components is None:
                tokenizer = AutoTokenizer.from_pretrained(model_name)
                model = AutoModelForSequenceClassification.from_pretrained(model_name)
                model.to(TEXT_MODEL_DEVICE)
                model.eval()

                id_to_label = {
                    int(idx): _normalize_emotion_label(str(label))
                    for idx, label in model.config.id2label.items()
                }

                _text_model_components = (tokenizer, model, id_to_label)
    return _text_model_components


def predict_text_emotion(raw_text: str) -> dict[str, str | float]:
    """
    Predict text emotion and confidence using cached transformer components.
    Output format is always:
    {
        "emotion": <string>,
        "confidence": <float>
    }
    """
    processed_text = _preprocess_text(raw_text)
    if not processed_text:
        return {"emotion": "neutral", "confidence": 0.0}

    tokenizer, model, id_to_label = get_text_model_components()

    encoded = tokenizer(
        processed_text,
        truncation=True,
        max_length=512,
        return_tensors="pt",
    )
    encoded = {key: value.to(TEXT_MODEL_DEVICE) for key, value in encoded.items()}

    with torch.no_grad():
        logits = model(**encoded).logits

    probs = torch.softmax(logits, dim=-1).detach().cpu().numpy().astype(np.float32)[0]
    best_idx = int(np.argmax(probs))
    emotion = id_to_label.get(best_idx, "neutral")
    confidence = float(probs[best_idx])

    return {"emotion": emotion, "confidence": confidence}
