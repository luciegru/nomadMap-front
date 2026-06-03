//
//  AlbumViewModel.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 15/05/2026.
//

import Foundation
import Observation
import KeychainAccess
import _PhotosUI_SwiftUI

@Observable
class AlbumViewModel {
    
    private let keychain = Keychain(service: Bundle.main.bundleIdentifier ?? "com.nomadMap.app")
    
    var albums: [Album] = []
    var lastCreatedAlbum: Album? = nil
    
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
    
    func createAlbum(with fields: [String: Any]) async throws {
        
        guard let token = loginVM.token else { throw URLError(.userAuthenticationRequired) }
        guard let url = URL(string: "http://localhost:8080/album")
        else {
            print("mauvais URL")
            
            return }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: fields)
        } catch {
            return
        }
        
        
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error {
                print("Erreur update:", error)
                return
            }
            if let data = data {
                
                //                            let jsonString = String(data: data, encoding: .utf8)
                //                            print(jsonString ?? "No JSON")
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let newAlbum = try decoder.decode(Album.self, from: data)
                    DispatchQueue.main.async {
                        self.albums.append(newAlbum)
                        self.lastCreatedAlbum = newAlbum
                    }
                } catch {
                    print("❌ [DEBUG DÉCODAGE] dss albumVM L'erreur est : \(error)")
                    
                    // 🚨 AJOUTE CE PRINT ICI pour voir le texte brut du serveur :
                    if let rawJSON = String(data: data, encoding: .utf8) {
                        print("📄 [DEBUG DÉCODAGE] Contenu brut qui a fait planter le décodage : \(rawJSON)")
                    }                }
            }
        }.resume()
        
        
        
        
    }
    
    func updateAlbum(with fields: [String: Any], id: String) async throws {
        
        guard let token = loginVM.token else { throw URLError(.userAuthenticationRequired) }
        guard let url = URL(string: "http://localhost:8080/album/\(id)")
        else {
            print("mauvais URL")
            return }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: fields)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        //        let jsonString = String(data: data, encoding: .utf8)
        //        print(jsonString ?? "No JSON")
        
        
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        decoder.dateDecodingStrategy = .iso8601
        let updatedAlbum = try decoder.decode(Album.self, from: data)
        
        await MainActor.run {
            if let index = self.albums.firstIndex(where: { $0.id == updatedAlbum.id }) {
                self.albums[index] = updatedAlbum
                
            }
            
            
        }
        
    }
    
    func getCurrentUserAlbums() async throws -> [Album] {
        guard let token = loginVM.token else {
            throw URLError(.userAuthenticationRequired) }
        guard let url = URL(string: "http://localhost:8080/album/current") else {
            throw URLError(.badURL) }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
//                let jsonString = String(data: data, encoding: .utf8)
//                print(jsonString ?? "No JSON")
                
                do{
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    let decodedAlbums = try decoder.decode([Album].self, from: data)
                    DispatchQueue.main.async {
                        self.albums = decodedAlbums
                    }
                }
                catch {
                    print("Error decoding: \(error)")
                }
            }
            else if let error {
                print("Error: \(error)")
            }
        }.resume()
        return self.albums
    }
}
        
