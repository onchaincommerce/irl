//
//  APIService.swift
//  IRLClip
//
//  Created by Aus Heller on 8/18/25.
//

import Foundation

class APIService: ObservableObject {
    private let baseURL = "http://localhost:3000/api"
    
    func createClaim(amount: Double, token: String = "USDC") async throws -> (claimId: String, secret: String, expiry: Int) {
        let url = URL(string: "\(baseURL)/claims")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = CreateClaimRequest(amount: amount, token: token)
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        let claimResponse = try JSONDecoder().decode(CreateClaimResponse.self, from: data)
        return (claimResponse.claimId, claimResponse.secret, claimResponse.expiry)
    }
    
    func getClaim(claimId: String) async throws -> ClaimData {
        let url = URL(string: "\(baseURL)/claims?claimId=\(claimId)")!
        let request = URLRequest(url: url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return try JSONDecoder().decode(ClaimData.self, from: data)
    }
}

// MARK: - Request Models
struct CreateClaimRequest: Codable {
    let amount: Double
    let token: String
}

// MARK: - Response Models
struct CreateClaimResponse: Codable {
    let claimId: String
    let secret: String
    let expiry: Int
    let amount: Double
    let token: String
}

enum APIError: Error {
    case invalidResponse
    case networkError
    case decodingError
}
