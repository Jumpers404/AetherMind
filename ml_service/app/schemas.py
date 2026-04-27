"""Pydantic schemas for ML endpoints

Defines the input and output models used by the FastAPI application. Keep
these stable as the mobile app expects the exact JSON keys.
"""

from pydantic import BaseModel


class KeystrokeInput(BaseModel):
    typing_speed: float
    avg_pause: float
    max_pause: float
    backspace_count: int
    total_time: float
    keystroke_count: int


class TextInput(BaseModel):
    text: str


class PredictionResponse(BaseModel):
    emotion: str
    confidence: float
