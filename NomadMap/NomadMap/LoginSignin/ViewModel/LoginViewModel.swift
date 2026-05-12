//
//  LoginViewModel.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 28/04/2026.
//

import Foundation
import Observation
import KeychainAccess

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
    
    var errorMessage: LoginError? = nil
    var isAuthenticated: Bool {
        return token != nil && currentUser != nil
    }
    
    
    init() {
        
        token = try? keychain.get("authToken") ?? nil
        
        if let data = try? keychain.getData("currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
        }
    }
    
    
    func login(email: String, password: String) async {
        guard let url = URL(string: "http://localhost:8080/user/login") else { return }

        let body: [String: String] = ["email": email, "password": password]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONEncoder().encode(body)
            
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let decoded = try decoder.decode(LoginResponse.self, from: data)

            await MainActor.run {
                self.token = decoded.token
                self.currentUser = decoded.user
                self.errorMessage = nil
            }
        } catch {
            
            await MainActor.run {
                self.errorMessage = .wrongCredentials
            }
        }
    }
    
    func logout() {
        token = nil
        currentUser = nil
    }
    
    func createUser(name: String, firstName: String, username: String, email: String, password: String) async throws {
        guard let url = URL(string: "http://localhost:8080/user") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let payload = SIgnInCredentials(
            name: name,
            firstName: firstName,
            email: email,
            password: password,
            userName: username
        )

        request.httpBody = try JSONEncoder().encode(payload)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }

        
        switch httpResponse.statusCode {
        case 200, 201:
            await login(email: email, password: password)
            
        case 409:
            await MainActor.run { self.errorMessage = .usernameTaken }
            throw LoginError.usernameTaken
            
        case 400:
            if let backendError = try? JSONDecoder().decode(BackendError.self, from: data) {
                await MainActor.run {
                    switch backendError.reason {
                    case "INVALID_PASSWORD_STRUCTURE":
                        self.errorMessage = .passwordtooweak
                    case "INVALID_EMAIL":
                        self.errorMessage = .emailNotValid
                    case "EMAIL_TAKEN":
                        self.errorMessage = .emailTaken
                    default:
                        self.errorMessage = .unknown
                    }
                }
            }
            throw LoginError.unknown
            
        default:
            await MainActor.run { self.errorMessage = .unknown }
            throw URLError(.badServerResponse)
        }
    }
    //    func updateCurrentUser(with fields: [String: Any]) async throws {
    //
    //        guard let token = token else { throw URLError(.userAuthenticationRequired) }
    //        guard let url = URL(string: "http://localhost:8080/user/") else { throw URLError(.badURL) }
    //
    //
    //        var request = URLRequest(url: url)
    //        request.httpMethod = "PATCH"
    //        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    //        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    //        request.httpBody = try JSONSerialization.data(withJSONObject: fields)
    //
    //        let (data, response) = try await URLSession.shared.data(for: request)
    ////        let jsonString = String(data: data, encoding: .utf8)
    ////        print(jsonString ?? "No JSON")
    //
    //
    //        let decoder = JSONDecoder()
    //        let formatter = DateFormatter()
    //        formatter.dateFormat = "yyyy/MM/dd"
    //        decoder.dateDecodingStrategy = .formatted(formatter)
    //        let updatedUser = try decoder.decode(User.self, from: data)
    ////        print(updatedUser)
    //
    //        await MainActor.run {
    //            self.currentUser = updatedUser
    //        }
    //
    //    }
    //
    //}
    //
    
//    extension Notification.Name {
//        static let didLogin = Notification.Name("didLogin")
//    }
}

