from sqlalchemy import Column, Integer, String, Float, DateTime, Boolean, ForeignKey, Date
from sqlalchemy.sql import func
from app.core.database import Base 

class User(Base):
    __tablename__ = "users"
    id = Column("user_id", Integer, primary_key=True, index=True)
    full_name = Column(String(100))
    age = Column(Integer)
    gender = Column(String(10))
    height_cm = Column(Float)
    weight_kg = Column("current_weight_kg", Float)
    activity_level = Column(String(20))
    target_calories = Column(Integer)
    target_protein = Column("target_protein_g", Integer)
    target_carbs = Column("target_carbs_g", Integer)
    target_fat = Column("target_fat_g", Integer)
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

class DailyLog(Base):
    __tablename__ = "daily_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column("user_id", Integer, ForeignKey("users.user_id"))
    food_id = Column(Integer, ForeignKey("foods.id"))
    amount_grams = Column(Float)
    meal_type = Column(String(50)) # breakfast, lunch, dinner, snack vb.
    
    # Auto-calculated macros
    calories = Column(Float)
    protein = Column(Float)
    carbs = Column(Float)
    fat = Column(Float)
    
    date = Column(Date, server_default=func.current_date())
    created_at = Column(DateTime(timezone=True), server_default=func.now())