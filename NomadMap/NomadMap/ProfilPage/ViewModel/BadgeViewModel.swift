//
//  BadgeViewModel.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 08/06/2026.
//

import Foundation
import Observation
import KeychainAccess
import _PhotosUI_SwiftUI

@Observable
class BadgeViewModel {
    
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "com.nomadMap.app")
    
    var myBadges: [Badge] = []
    var allBadges: [Badge] = []
    
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
    
    
    
    func getCurrentUserBadges() async throws {
        guard let token = loginVM.token else { throw AppError.tokenIssue}
        guard let url = URL(string: "http://localhost:8080/badge/user") else { throw AppError.badURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)
        try NetworkHelper.validateResponse(data: data, response: response)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedBadges = try decoder.decode([Badge].self, from: data)
        
        await MainActor.run {
            self.myBadges = decodedBadges
        }
    }

    func getAllBadges() async throws {
        guard let token = loginVM.token else {
            throw AppError.tokenIssue }
        guard let url = URL(string: "http://localhost:8080/badge") else {
            throw AppError.badURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try NetworkHelper.validateResponse(data: data, response: response)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedBadges = try decoder.decode([Badge].self, from: data)
        
        await MainActor.run {
            self.allBadges = decodedBadges
        }

    }
}
        
