//
//  LevelViewModel.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 29/06/2026.
//

import Foundation
import Observation
import KeychainAccess
import _PhotosUI_SwiftUI

@Observable
class LevelViewModel {
    
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "com.nomadMap.app")
    
    var currentUserLevel: Level? = nil
    var allLevels: [Level] = []
    var targetLevel: Level? = nil
    
    private var loginVM: LoginViewModel = LoginViewModel()
    
    init(){
    }
    
    init(loginVM: LoginViewModel) {
        self.loginVM = loginVM
    }


    var token: String? {
        didSet {
            if let token = token {
                try? keychain.set(token, key: "authToken")
            } else {
                try? keychain.remove("authToken")
            }
        }
    }
    
    
    
    func getCurrentUserLevel() async throws {
        guard let token = loginVM.token else { throw AppError.tokenIssue }
        guard let url = URL(string: "http://localhost:8080/level/current") else { throw AppError.badURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        try NetworkHelper.validateResponse(data: data, response: response)
//        let jsonString = String(data: data, encoding: .utf8)
//        print("current:  ", jsonString ?? "No JSON")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedLevel = try decoder.decode(Level.self, from: data)
        
        await MainActor.run {
            self.currentUserLevel = decodedLevel
        }
    }

    func getTargetLevel() async throws {
        guard let token = loginVM.token else { throw AppError.tokenIssue }
        guard let url = URL(string: "http://localhost:8080/level/target") else { throw AppError.badURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        try NetworkHelper.validateResponse(data: data, response: response)
//        let jsonString = String(data: data, encoding: .utf8)
//        print("target:  ", jsonString ?? "No JSON")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedTargetLevel = try decoder.decode(Level.self, from: data)
        
        await MainActor.run {
            self.targetLevel = decodedTargetLevel
        }
    }


    func getAllLevels() async throws {
        guard let token = loginVM.token else {
            throw AppError.tokenIssue }
        guard let url = URL(string: "http://localhost:8080/level") else {
            throw AppError.badURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try NetworkHelper.validateResponse(data: data, response: response)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedLevels = try decoder.decode([Level].self, from: data)
        
        await MainActor.run {
            self.allLevels = decodedLevels
        }

    }
}
        
