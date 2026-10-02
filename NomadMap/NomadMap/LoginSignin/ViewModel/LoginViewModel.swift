//
//  LoginViewModel.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 28/04/2026.
//

import Foundation
import Observation
import KeychainAccess
import _PhotosUI_SwiftUI

@Observable
class LoginViewModel {
    
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "com.nomadMap.app")
    
    var token: String? {
        didSet {
            if let token = token {
                try? keychain.set(token, key: "authToken")
            } else {
                try? keychain.remove("authToken")
            }
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    var currentUser: User? {
        didSet {
            if let encoded = try? JSONEncoder().encode(currentUser) {
                try? keychain.set(encoded, key: "currentUser")
            } else {
                try? keychain.remove("currentUser")
            }
        }
    }
    
    
    var user: User?
    var isAuthenticated: Bool {
        return token != nil && currentUser != nil
    }
    
    var dashboardInfos: DashboardDTO? = nil
    
    
    init() {
        token = try? keychain.get("authToken") ?? nil
        
        if let data = try? keychain.getData("currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
        } else {
        }
        
    }
    
    func login(email: String, password: String) async throws {
        guard let url = URL(string: "http://localhost:8080/user/login") else { throw AppError.badURL }
        
        let body: [String: String] = ["email": email, "password": password]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        try NetworkHelper.validateResponse(data: data, response: response)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(LoginResponse.self, from: data)
        
        await MainActor.run {
            self.token = decoded.token
            self.currentUser = decoded.user
        }
    }
    
    func logout() {
        token = nil
        currentUser = nil
    }
    
    func createUser(name: String, firstName: String, username: String, email: String, password: String) async throws {
        guard let url = URL(string: "http://localhost:8080/user") else { throw AppError.badURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let payload = SIgnInCredentials(name: name, firstName: firstName, email: email, password: password, userName: username)
        request.httpBody = try JSONEncoder().encode(payload)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        try NetworkHelper.validateResponse(data: data, response: response)
        
        try await login(email: email, password: password)
    }
    
    func updateProfile(id: UUID, profilePhoto: PhotosPickerItem?, coverPhoto: PhotosPickerItem?, fields: [String: Any]) async throws {
        var fields = fields
        
        async let profileUrl: String? = profilePhoto != nil ? UploadService.uploadImage(profilePhoto!) : nil
        async let coverUrl: String? = coverPhoto != nil ? UploadService.uploadImage(coverPhoto!) : nil
        
        if let url = try await profileUrl { fields["profilPicture"] = url }
        if let url = try await coverUrl { fields["coverPicture"] = url }
        
        try await updateCurrentUser(with: fields, id: id)
    }
    
    func updateCurrentUser(with fields: [String: Any], id: UUID) async throws {
        
        guard let token = token else { throw AppError.tokenIssue }
        guard let url = URL(string: "http://localhost:8080/user/\(id)") else { throw AppError.badURL }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: fields)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try NetworkHelper.validateResponse(data: data, response: response)
        
        
//                let jsonString = String(data: data, encoding: .utf8)
//                print(jsonString ?? "No JSON")
        
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        decoder.dateDecodingStrategy = .iso8601
        let updatedUser = try decoder.decode(User.self, from: data)
        
        await MainActor.run {
            self.currentUser = updatedUser
        }
        
    }
    
    func getCurrentUser() async throws {
        guard let token = token else {throw AppError.tokenIssue }
        guard let url = URL(string: "http://localhost:8080/user/myUser") else { throw AppError.badURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try NetworkHelper.validateResponse(data: data, response: response)
        //                            let jsonString = String(data: data, encoding: .utf8)
        //                            print(jsonString ?? "No JSON")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let decodedUser = try decoder.decode(User.self, from: data)
        
        await MainActor.run {
            self.currentUser = decodedUser
        }
    }
    
    func getUserById(userId: UUID) async throws -> User {
        guard let token = token else { throw AppError.tokenIssue }
        guard let url = URL(string: "http://localhost:8080/user/\(userId)") else { throw AppError.badURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        try NetworkHelper.validateResponse(data: data, response: response)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(User.self, from: data)
    }
    
    
    func getDashboardInfos() async throws {
        guard let token = token else {throw AppError.tokenIssue }
        guard let url = URL(string: "http://localhost:8080/user/dashboard") else { throw AppError.badURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        //                            let jsonString = String(data: data, encoding: .utf8)
        //                            print(jsonString ?? "No JSON")
        let (data, response) = try await URLSession.shared.data(for: request)
        try NetworkHelper.validateResponse(data: data, response: response)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let decodedDashboard = try decoder.decode(DashboardDTO.self, from: data)
        await MainActor.run {
            self.dashboardInfos = decodedDashboard
        }
    }
}





