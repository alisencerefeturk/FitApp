//
//  NetworkManager.swift
//  MakrojiApp
//

import Foundation
import UIKit

// MARK: - NetworkManager
/// FastAPI backend'ine tüm HTTP isteklerini yöneten merkezi singleton.
/// Simulator'da baseURL = 127.0.0.1, gerçek cihazda Mac'in yerel IP'si olmalı.
final class NetworkManager {

    static let shared = NetworkManager()

    // ⚠️ Gerçek iPhone/iPad ile test ederken bu satırı Mac'in yerel IP'siyle güncelle:
    // örn. "http://192.168.1.42:8000"
    private let baseURL = "http://172.20.10.3:8000"

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        self.session = URLSession(configuration: config)
    }

    // MARK: - GET /users/{user_id}/summary
    /// Kullanıcının günlük makro özetini çeker.
    func fetchUserSummary(userID: Int) async throws -> UserSummary {
        guard let url = URL(string: "\(baseURL)/users/\(userID)/summary") else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        return try JSONDecoder().decode(UserSummary.self, from: data)
    }

    // MARK: - POST /images/upload
    /// Kameradan alınan görseli multipart/form-data olarak backend'e gönderir.
    func uploadImage(_ image: UIImage) async throws -> ImageUploadResponse {
        guard let url = URL(string: "\(baseURL)/images/upload") else {
            throw NetworkError.invalidURL
        }
        guard let imageData = image.jpegData(compressionQuality: 0.85) else {
            throw NetworkError.encodingFailed
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append(
            "Content-Disposition: form-data; name=\"file\"; filename=\"meal.jpg\"\r\n"
                .data(using: .utf8)!
        )
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        return try JSONDecoder().decode(ImageUploadResponse.self, from: data)
    }

    // MARK: - Yardımcı
    private func validateResponse(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.serverError(statusCode: http.statusCode)
        }
    }
}

// MARK: - NetworkError
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case encodingFailed
    case serverError(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:             return "Geçersiz URL."
        case .invalidResponse:        return "Sunucudan geçerli bir yanıt alınamadı."
        case .encodingFailed:         return "Görsel kodlanamadı."
        case .serverError(let code):  return "Sunucu hatası: HTTP \(code)"
        }
    }
}
