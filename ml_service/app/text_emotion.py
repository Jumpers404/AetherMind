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
