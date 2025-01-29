//
//  APIManager.swift
//  checkInCharlie
//
//  Created by Robert Lester on 12/5/24.
//

import Foundation

class APIManager {
    static let shared = APIManager()
    private init() {}
    
    let authBaseURL = "http://127.0.0.1:8000"  // Authentication and User Profile API
    
    // MARK: - User Profile Methods
    
    func loginUser(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(authBaseURL)/token") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let bodyString = "username=\(email)&password=\(password)"
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        performRequest(request: request) { (result: Result<TokenResponse, Error>) in
            switch result {
            case .success(let tokenResponse):
                completion(.success(tokenResponse.access_token))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func registerUser(email: String, password: String, fullName: String?, phoneNumber: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(authBaseURL)/register") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        var body: [String: Any] = [
            "email": email,
            "password": password
        ]
        if let fullName = fullName { body["full_name"] = fullName }
        if let phoneNumber = phoneNumber { body["phone_number"] = phoneNumber }
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        performRequest(request: request) { (result: Result<UserProfile, Error>) in
            switch result {
            case .success(_):
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchUserProfile(token: String, completion: @escaping (Result<UserProfile, Error>) -> Void) {
        guard let url = URL(string: "\(authBaseURL)/profile") else {
            completion(.failure(APIError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        performRequest(request: request, completion: completion)
    }
    
    // MARK: - User Management Methods
    
    func fetchAllUsers(token: String, completion: @escaping (Result<[UserProfile], Error>) -> Void) {
        guard let url = URL(string: "\(authBaseURL)/users") else { // Adjust the endpoint as per your API
            completion(.failure(APIError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        performRequest(request: request, completion: completion)
    }
    
    // MARK: - Generic Request Performer
    
    private func performRequest<T: Decodable>(request: URLRequest, completion: @escaping (Result<T, Error>) -> Void) {
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Error handling
            if let error = error {
                completion(.failure(error))
                return
            }
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("Response body:", responseString)
            }
            
            // Response validation
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(APIError.serverError(statusCode: httpResponse.statusCode)))
                return
            }
            
            // Data decoding
            guard let data = data else {
                completion(.failure(APIError.noData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(T.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(APIError.decodingError(error)))
            }
        }.resume()
    }
    
    // MARK: - Error Handling
    
    enum APIError: Error {
        case invalidURL
        case serverError(statusCode: Int)
        case noData
        case decodingError(Error)
    }
}

// MARK: - Data Models

struct TokenResponse: Decodable {
    let access_token: String
    let token_type: String
}

struct UserProfile: Codable, Identifiable {
    let id: Int
    let email: String
    let full_name: String?
    let phone_number: String?
}

