import os
import uuid
from datetime import date
from fastapi import FastAPI, Depends, HTTPException, File, UploadFile
from fastapi.staticfiles import StaticFiles
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.core.database import get_db, engine, Base
from app.models.models import User, Food, DailyLog
from app.schemas.schemas import UserCreate, UserRead, LogCreate, DailySummary
from app.service.nutrition import calculate_user_targets, calculate_log_macros
from app.service.vision import detect_food_from_image

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Makroji API")

os.makedirs("uploads", exist_ok=True)
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

@app.get("/")
def read_root():
    return {"message": "Makroji API is running!"}

@app.post("/users/", response_model=UserRead)
def register_user(user: UserCreate, db: Session = Depends(get_db)):
    t_cal, t_prot, t_carb, t_fat = calculate_user_targets(
        user.age, user.gender, user.weight_kg, user.height_cm, user.activity_level
    )
    
    new_user = User(
        **user.model_dump(),
        target_calories=t_cal,
        target_protein=t_prot,
        target_carbs=t_carb,
        target_fat=t_fat
    )
    
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

@app.post("/logs/")
def create_meal_log(log: LogCreate, db: Session = Depends(get_db)):
    # Validate the user
    user = db.query(User).filter(User.id == log.user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    # Validate the food
    food = db.query(Food).filter(Food.id == log.food_id).first()
    if not food:
        raise HTTPException(status_code=404, detail="Food not found")
        
    # Calculate calories and macros mathematically
    macros = calculate_log_macros(
        log.amount_grams,
        food.calories_100g,
        food.protein_100g,
        food.carbs_100g,
        food.fat_100g
    )
    
    # Create log entry
    new_log = DailyLog(
        user_id=log.user_id,
        food_id=log.food_id,
        amount_grams=log.amount_grams,
        meal_type=log.meal_type,
        calories=macros["calories"],
        protein=macros["protein"],
        carbs=macros["carbs"],
        fat=macros["fat"]
    )
    
    db.add(new_log)
    db.commit()
    db.refresh(new_log)
    
    return {"message": "Meal logged successfully", "log": new_log}

@app.get("/users/{user_id}/summary", response_model=DailySummary)
def get_daily_summary(user_id: int, target_date: date = None, db: Session = Depends(get_db)):
    # Validate the user
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
        
    # Use today's date if no date parameter is passed
    if target_date is None:
        target_date = date.today()
        
    # Fetch today's logs for the user
    daily_logs = db.query(DailyLog).filter(
        DailyLog.user_id == user_id, 
        func.date(DailyLog.date) == target_date
    ).all()
    
    # Calculate sum of consumed macros
    consumed_calories = sum(log.calories for log in daily_logs)
    consumed_protein = sum(log.protein for log in daily_logs)
    consumed_carbs = sum(log.carbs for log in daily_logs)
    consumed_fat = sum(log.fat for log in daily_logs)
    
    # Calculate remaining targets (target - consumed)
    return DailySummary(
        consumed_calories=consumed_calories,
        consumed_protein=consumed_protein,
        consumed_carbs=consumed_carbs,
        consumed_fat=consumed_fat,
        remaining_calories=user.target_calories - consumed_calories,
        remaining_protein=user.target_protein - consumed_protein,
        remaining_carbs=user.target_carbs - consumed_carbs,
        remaining_fat=user.target_fat - consumed_fat
    )

@app.post("/images/upload")
async def upload_image(file: UploadFile = File(...)):
    allowed_extensions = {".jpg", ".jpeg", ".png"}
    ext = os.path.splitext(file.filename)[1].lower()
    
    if ext not in allowed_extensions:
        raise HTTPException(status_code=400, detail="Only .jpg, .jpeg, and .png formats are allowed.")
        
    unique_filename = f"{uuid.uuid4()}{ext}"
    file_path = os.path.join("uploads", unique_filename)
    
    with open(file_path, "wb") as buffer:
        content = await file.read()
        buffer.write(content)
        
    # YOLO26 (v8) ile görsel analizi
    detected_items = detect_food_from_image(file_path)
        
    return {
        "message": "Image uploaded successfully", 
        "filename": unique_filename, 
        "url": f"/uploads/{unique_filename}",
        "detected_foods": detected_items
    }