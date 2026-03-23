from pathlib import Path

import joblib

_model = None


def get_model():
    global _model
    if _model is None:
        model_path = Path(__file__).resolve().parents[1] / "model" / "keystroke_model.pkl"
        if not model_path.exists():
            raise FileNotFoundError(f"Model file not found: {model_path}")
        _model = joblib.load(model_path)
    return _model
