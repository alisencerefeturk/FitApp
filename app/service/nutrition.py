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

def calculate_log_macros(amount_grams: float, cal_100: float, pro_100: float, carb_100: float, fat_100: float):
    """
    Calculates the net calories and macros for a given amount of food based on its 100g values.
    """
    ratio = amount_grams / 100.0
    return {
        "calories": cal_100 * ratio,
        "protein": pro_100 * ratio,
        "carbs": carb_100 * ratio,
        "fat": fat_100 * ratio
    }