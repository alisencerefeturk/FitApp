def calculate_user_targets(age: int, gender: str, weight: float, height: float, activity_level: str):
    if gender.lower() == "erkek":
        bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5
    else:
        bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161

    multipliers = {
        "sedentary": 1.2,
        "light": 1.375,
        "active": 1.55,
        "athlete": 1.725
    }
    tdee = bmr * multipliers.get(activity_level, 1.2)
    
    target_calories = int(tdee - 500)
    
    protein = int(weight * 2.2)
    fat = int((target_calories * 0.25) / 9)
    carbs = int((target_calories - (protein * 4) - (fat * 9)) / 4)
    
    return target_calories, protein, carbs, fat