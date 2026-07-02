//
//  ParticipationViewModel.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 30/06/2026.
//

import Foundation
import Observation
import KeychainAccess

@Observable
class ParticipationViewModel {
    
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "com.nomadMap.app")
    
    var participations: [User] = []
    var isLiked: Bool = false
    var permission: Participation? = nil
    
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
    
    
    
    func getParticipationsByAlbumId(albumId: String) async throws {
        guard let token = loginVM.token else { throw AppError.tokenIssue}
        guard let url = URL(string: "http://localhost:8080/participation/album/\(albumId)") else { throw AppError.badURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try NetworkHelper.validateResponse(data: data, response: response)
        //                let jsonString = String(data: data, encoding: .utf8)
        //                print(jsonString ?? "No JSON")
        //
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedParticipations = try decoder.decode([User].self, from: data)
        
        await MainActor.run {
            self.participations = decodedParticipations
        }
    }
    
    func createParticipation(albumId: String, role: UserRole) async throws {
        guard let token = loginVM.token else { throw AppError.tokenIssue}
        guard let url = URL(string: "http://localhost:8080/participation/\(albumId)/\(role)") else { throw AppError.badURL}
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try NetworkHelper.validateResponse(data: data, response: response)
//        let jsonString = String(data: data, encoding: .utf8)
//        print(jsonString ?? "No JSON")

                
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let decodedResponse = try decoder.decode(Participation.self, from: data)
        
        await MainActor.run {
            self.permission = decodedResponse
        }
    }
    
    func getLikeStatus(albumId: String) async throws {
        guard let token = loginVM.token else {
            throw AppError.tokenIssue }
        guard let url = URL(string: "http://localhost:8080/like/status/\(albumId)") else {
            throw AppError.badURL }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try NetworkHelper.validateResponse(data: data, response: response)
//                        let jsonString = String(data: data, encoding: .utf8)
//                        print(jsonString ?? "No JSON")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedLikeStatus = try decoder.decode(IsLiked.self, from: data)
        
        await MainActor.run {
            self.isLiked = decodedLikeStatus.isLiked
        }
    }

    
    func toggleLike(albumId: String) async throws {
        guard let token = loginVM.token else { throw AppError.tokenIssue }
        guard let url = URL(string: "http://localhost:8080/like/toggle/\(albumId)") else { throw AppError.badURL}
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try NetworkHelper.validateResponse(data: data, response: response)
//        let jsonString = String(data: data, encoding: .utf8)
//        print(jsonString ?? "No JSON")

        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let decodedResponse = try decoder.decode(IsLiked.self, from: data)
        
        await MainActor.run {
            self.isLiked = decodedResponse.isLiked
        }
    }
}

