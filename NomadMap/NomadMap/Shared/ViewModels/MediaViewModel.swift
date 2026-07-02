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
    
    func createMedia(with fields: [String: Any]) async throws {
        
        guard let token = loginVM.token else { throw AppError.tokenIssue }
        guard let url = URL(string: "http://localhost:8080/media")
        else { throw AppError.badURL }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: fields)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        try NetworkHelper.validateResponse(data: data, response: response)
        //                                       let jsonString = String(data: data, encoding: .utf8)
        //                                            print(jsonString ?? "No JSON")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let newMedia = try decoder.decode(Media.self, from: data)
        
        await MainActor.run {
            self.medias.append(newMedia)
        }
    }
    
    //    func updateAlbum(with fields: [String: Any], id: String) async throws {
    //
    //   guard let token = loginVM.token else { throw URLError(.userAuthenticationRequired) }
    //        guard let url = URL(string: "http://localhost:8080/album/\(id)")
    //        else {
    //            print("mauvais URL")
    //            return }
    //
    //
    //        var request = URLRequest(url: url)
    //        request.httpMethod = "PATCH"
    //        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    //        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    //        request.httpBody = try JSONSerialization.data(withJSONObject: fields)
    //
    //        let (data, response) = try await URLSession.shared.data(for: request)
    //        //        let jsonString = String(data: data, encoding: .utf8)
    //        //        print(jsonString ?? "No JSON")
    //
    //
    //        let decoder = JSONDecoder()
    //        let formatter = DateFormatter()
    //        decoder.dateDecodingStrategy = .iso8601
    //        let updatedAlbum = try decoder.decode(Album.self, from: data)
    //
    //        await MainActor.run {
    //            if let index = self.albums.firstIndex(where: { $0.id == updatedAlbum.id }) {
    //                self.albums[index] = updatedAlbum
    //
    //            }
    //
    //
    //        }
    //
    //    }
    
}


