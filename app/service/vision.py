from ultralytics import YOLO

# Şimdilik yolov8n.pt modelini yükleyip önbellekte tutuyoruz.
model = YOLO("yolov8n.pt")

def detect_food_from_image(image_path: str):
    """
    Görseli YOLO modeli ile analiz edip tespit edilen nesneleri döndürür.
    """
    # Görsel üzerinde tespit işlemi (inference)
    results = model(image_path)
    
    detected_items = []
    
    for result in results:
        for box in result.boxes:
            class_id = int(box.cls[0].item())
            confidence = float(box.conf[0].item())
            class_name = result.names[class_id]
            
            detected_items.append({
                "class_name": class_name,
                "confidence": round(confidence, 2)
            })
            
    return detected_items
