"""Text emotion wrapper

Provides a small, stable wrapper around `predict_text_emotion` exported by
`model_loader`. The wrapper enforces the expected output contract used by
the FastAPI route and centralizes any future post-processing.
"""

from .model_loader import predict_text_emotion


def analyze_text_emotion(raw_text: str) -> dict[str, str | float]:
    """
    Backward-compatible text emotion analysis entrypoint.

    Input:
        raw_text: user text input

    Output format (kept stable for existing API consumers):
        {
            "emotion": <string>,
            "confidence": <float>
        }
    """
    return predict_text_emotion(raw_text)
