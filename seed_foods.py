import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from sqlalchemy.exc import IntegrityError
from app.core.database import SessionLocal, engine
from app.models.models import Base, Food

def seed_data():
    Base.metadata.create_all(bind=engine)
    
    foods = [
        {"barcode": "10001", "name": "Chicken Breast (Raw)", "brand": "Generic", "calories_100g": 120.0, "protein_100g": 22.5, "carbs_100g": 0.0, "fat_100g": 2.6, "is_verified": True},
        {"barcode": "10002", "name": "Oatmeal", "brand": "Quaker", "calories_100g": 389.0, "protein_100g": 16.9, "carbs_100g": 66.3, "fat_100g": 6.9, "is_verified": True},
        {"barcode": "10003", "name": "Whole Egg", "brand": "Generic", "calories_100g": 155.0, "protein_100g": 13.0, "carbs_100g": 1.1, "fat_100g": 11.0, "is_verified": True},
        {"barcode": "10004", "name": "Cottage Cheese (Low Fat)", "brand": "Generic", "calories_100g": 98.0, "protein_100g": 11.0, "carbs_100g": 3.4, "fat_100g": 4.3, "is_verified": True},
        {"barcode": "10005", "name": "White Rice (Dry)", "brand": "Generic", "calories_100g": 365.0, "protein_100g": 7.1, "carbs_100g": 80.0, "fat_100g": 0.7, "is_verified": True},
        {"barcode": "10006", "name": "Broccoli (Raw)", "brand": "Generic", "calories_100g": 34.0, "protein_100g": 2.8, "carbs_100g": 6.6, "fat_100g": 0.4, "is_verified": True},
        {"barcode": "10007", "name": "Almonds", "brand": "Generic", "calories_100g": 579.0, "protein_100g": 21.2, "carbs_100g": 21.6, "fat_100g": 49.9, "is_verified": True},
        {"barcode": "10008", "name": "Sweet Potato (Raw)", "brand": "Generic", "calories_100g": 86.0, "protein_100g": 1.6, "carbs_100g": 20.1, "fat_100g": 0.1, "is_verified": True},
        {"barcode": "10009", "name": "Tuna in Water (Drained)", "brand": "Generic", "calories_100g": 116.0, "protein_100g": 25.5, "carbs_100g": 0.0, "fat_100g": 0.8, "is_verified": True},
        {"barcode": "10010", "name": "Greek Yogurt (0% Fat)", "brand": "Generic", "calories_100g": 59.0, "protein_100g": 10.0, "carbs_100g": 3.6, "fat_100g": 0.4, "is_verified": True},
        {"barcode": "10011", "name": "Peanut Butter (Natural)", "brand": "Generic", "calories_100g": 588.0, "protein_100g": 25.0, "carbs_100g": 20.0, "fat_100g": 50.0, "is_verified": True},
        {"barcode": "10012", "name": "Salmon (Raw)", "brand": "Generic", "calories_100g": 208.0, "protein_100g": 20.0, "carbs_100g": 0.0, "fat_100g": 13.0, "is_verified": True},
        {"barcode": "10013", "name": "Black Beans (Canned)", "brand": "Generic", "calories_100g": 91.0, "protein_100g": 5.5, "carbs_100g": 16.5, "fat_100g": 0.3, "is_verified": True},
        {"barcode": "10014", "name": "Olive Oil (Extra Virgin)", "brand": "Generic", "calories_100g": 884.0, "protein_100g": 0.0, "carbs_100g": 0.0, "fat_100g": 100.0, "is_verified": True},
        {"barcode": "10015", "name": "Whey Protein Isolate", "brand": "Optimum Nutrition", "calories_100g": 371.0, "protein_100g": 82.0, "carbs_100g": 5.0, "fat_100g": 1.0, "is_verified": True},
    ]

    db = SessionLocal()
    
    try:
        for food_data in foods:
            existing_food = db.query(Food).filter(
                (Food.barcode == food_data["barcode"]) | (Food.name == food_data["name"])
            ).first()
            
            if not existing_food:
                new_food = Food(**food_data)
                db.add(new_food)
                print(f"Eklendi: {food_data['name']}")
            else:
                print(f"Atlandı (Zaten mevcut): {food_data['name']}")
                
        db.commit()
        print("Veritabanına 15 adet örnek gıda başarıyla eklendi!")
    except Exception as e:
        db.rollback()
        print(f"Bir hata oluştu: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    seed_data()
