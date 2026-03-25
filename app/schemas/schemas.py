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

class LogCreate(BaseModel):
    user_id: int
    food_id: int
    amount_grams: float
    meal_type: str # e.g., breakfast, lunch, dinner, snack

class DailySummary(BaseModel):
    consumed_calories: float
    consumed_protein: float
    consumed_carbs: float
    consumed_fat: float
    remaining_calories: float
    remaining_protein: float
    remaining_carbs: float
    remaining_fat: float