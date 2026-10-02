//
//  MediaViewModel.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 28/05/2026.
//

import Foundation
import Observation
import KeychainAccess
import _PhotosUI_SwiftUI

@Observable
class MediaViewModel {
    
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "com.nomadMap.app")
    
    
    var medias: [Media] = []
    
    private var loginVM: LoginViewModel = LoginViewModel()
    
    init(){
    }
    init(loginVM: LoginViewModel) {
        self.loginVM = loginVM
    }
    
    
    
    //    var user: User? = nil
    
    var token: String? {
        didSet {
            if let token = token {
                try? keychain.set(token, key: "authToken")
            } else {
                try? keychain.remove("authToken")
            }
        }
    }
    
    @discardableResult
    func createMedia(with fields: [String: Any]) async throws -> Media {
        guard let token = loginVM.token else { throw AppError.tokenIssue }
        guard let url = URL(string: "http://localhost:8080/media") else { throw AppError.badURL }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: fields)

        let (data, response) = try await URLSession.shared.data(for: request)
        try NetworkHelper.validateResponse(data: data, response: response)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Media.self, from: data)
    }
    
    
    func deleteMedia(idMedia: String) async throws {
        guard let token = loginVM.token else { throw AppError.tokenIssue }

        guard let url = URL(string: "http://localhost:8080/media/\(idMedia)")
        else { throw AppError.badURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 || httpResponse.statusCode == 204 else {
            throw URLError(.badServerResponse)
        }
    }
    
    
    func updateMedia(idMedia: String, note: String) async throws -> Media {
        guard let token = loginVM.token else { throw AppError.tokenIssue }
        
        guard let url = URL(string: "http://localhost:8080/media/\(idMedia)")
        else { throw AppError.badURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: ["note": note])
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try NetworkHelper.validateResponse(data: data, response: response)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Media.self, from: data)
    }

        
    
}


