from sqlalchemy import Column, Integer, String, Float, DateTime, Boolean
from sqlalchemy.sql import func
from app.core.database import Base 

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    full_name = Column(String(100))
    age = Column(Integer)
    gender = Column(String(10))
    height_cm = Column(Float)
    weight_kg = Column(Float)
    activity_level = Column(String(20))
    target_calories = Column(Integer)
    target_protein = Column(Integer)
    target_carbs = Column(Integer)
    target_fat = Column(Integer)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class Food(Base):
    __tablename__ = "foods"
    id = Column(Integer, primary_key=True, index=True)
    barcode = Column(String(50), unique=True, index=True)
    name = Column(String(255), nullable=False)
    brand = Column(String(100))
    calories_100g = Column(Float)
    protein_100g = Column(Float)
    carbs_100g = Column(Float)
    fat_100g = Column(Float)
    is_verified = Column(Boolean, default=False)