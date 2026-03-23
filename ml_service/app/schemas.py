from pydantic import BaseModel


class KeystrokeInput(BaseModel):
    typing_speed: float
    avg_pause: float
    max_pause: float
    backspace_count: int
    total_time: float
    keystroke_count: int


class PredictionResponse(BaseModel):
    emotion: str
    confidence: float
