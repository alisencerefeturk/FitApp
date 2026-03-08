from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db, engine, Base
from app.models.models import User, Food
from app.schemas.schemas import UserCreate, UserRead
from app.service.nutrition import calculate_user_targets

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Makroji API")

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