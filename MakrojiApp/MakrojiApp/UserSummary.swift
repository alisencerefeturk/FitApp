//
//  UserSummary.swift
//  MakrojiApp
//

import Foundation

/// GET /users/{user_id}/summary endpoint'inden dönen veriyle eşleşen Swift modeli.
/// Backend'deki DailySummary Pydantic şemasını birebir yansıtır.
struct UserSummary: Codable {
    let consumedCalories: Double
    let consumedProtein:  Double
    let consumedCarbs:    Double
    let consumedFat:      Double

    let remainingCalories: Double
    let remainingProtein:  Double
    let remainingCarbs:    Double
    let remainingFat:      Double

    // Backend snake_case ↔ Swift camelCase dönüşümü
    enum CodingKeys: String, CodingKey {
        case consumedCalories  = "consumed_calories"
        case consumedProtein   = "consumed_protein"
        case consumedCarbs     = "consumed_carbs"
        case consumedFat       = "consumed_fat"
        case remainingCalories = "remaining_calories"
        case remainingProtein  = "remaining_protein"
        case remainingCarbs    = "remaining_carbs"
        case remainingFat      = "remaining_fat"
    }
}

/// POST /images/upload endpoint'inden dönen yanıt
struct ImageUploadResponse: Codable {
    let message:        String
    let filename:       String
    let url:            String
    let detectedFoods:  [DetectedFood]

    enum CodingKeys: String, CodingKey {
        case message
        case filename
        case url
        case detectedFoods = "detected_foods"
    }
}

struct DetectedFood: Codable, Identifiable {
    var id: String { name }
    let name:       String
    let confidence: Double?
}
