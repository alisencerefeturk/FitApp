from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class UserCreate(BaseModel):
    full_name: str
    age: int
    gender: str # male / female
    height_cm: float
    weight_kg: float
    activity_level: str # sedentary, lightly_active, moderately_active, very_active

class UserRead(UserCreate):
    id: int
    target_calories: int
    target_protein: int
    target_carbs: int
    target_fat: int
    created_at: datetime

    class Config:
        from_attributes = True