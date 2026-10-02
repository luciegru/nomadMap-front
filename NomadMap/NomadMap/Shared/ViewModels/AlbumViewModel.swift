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
    
    var myAlbums: [Album] = []
    var sharedAlbums: [Album] = []
    var lastCreatedAlbum: Album? = nil
    var mySavedAlbums: [Album] = []
    var albumInteractions: Interaction? = nil
    var album: Album? = nil
    
    private var loginVM: LoginViewModel = LoginViewModel()
    
    init(){
    }
    init(loginVM: LoginViewModel) {
        self.loginVM = loginVM
    }
    
    
    
    //    var user: User? = nil
    @MainActor
    func addMedias(_ newMedias: [Media]) {
        guard var current = album else { return }
        let existing = Set((current.medias ?? []).map(\.id))
        current.medias = (current.medias ?? []) + newMedias.filter { !existing.contains($0.id) }
        album = current
    }

    @MainActor
    func removeMedia(id: UUID) {
        guard var current = album else { return }
        current.medias?.removeAll { $0.id == id }
        album = current
    }

    @MainActor
    func updateMedia(_ media: Media) {
        guard var current = album,
              let i = current.medias?.firstIndex(where: { $0.id == media.id }) else { return }
        current.medias?[i] = media
        album = current
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
    
    func createAlbum(with fields: [String: Any]) async throws {
        
        guard let token = loginVM.token else { throw AppError.tokenIssue }
        guard let url = URL(string: "http://localhost:8080/album")
        else { throw AppError.badURL }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: fields)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        try NetworkHelper.validateResponse(data: data, response: response)
        //                            let jsonString = String(data: data, encoding: .utf8)
        //                            print(jsonString ?? "No JSON")
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let newAlbum = try decoder.decode(Album.self, from: data)
        await MainActor.run {
            self.myAlbums.append(newAlbum)
            self.lastCreatedAlbum = newAlbum
            
        }
    }
    
    func updateAlbum(with fields: [String: Any], id: String) async throws {
        
        guard let token = loginVM.token else { throw AppError.tokenIssue }
        guard let url = URL(string: "http://localhost:8080/album/\(id)")
        else { throw AppError.badURL }
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONSerialization.data(withJSONObject: fields)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try NetworkHelper.validateResponse(data: data, response: response)
        //        let jsonString = String(data: data, encoding: .utf8)
        //        print(jsonString ?? "No JSON")
        
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let updatedAlbum = try decoder.decode(Album.self, from: data)
        
        await MainActor.run {
            if let index = self.myAlbums.firstIndex(where: { $0.id == updatedAlbum.id }) {
                self.myAlbums[index] = updatedAlbum
                
            }
            
            
        }
        
    }
    
    func getCurrentUserAlbums() async throws {
        guard let token = loginVM.token else { throw AppError.tokenIssue }
        guard let url = URL(string: "http://localhost:8080/album/current") else { throw AppError.badURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try NetworkHelper.validateResponse(data: data, response: response)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedAlbums = try decoder.decode([Album].self, from: data)
        
        await MainActor.run {
            self.myAlbums = decodedAlbums
        }
    }
    
    func getCurrentUserSavedAlbums() async throws {
        guard let token = loginVM.token else { throw AppError.tokenIssue }
        guard let url = URL(string: "http://localhost:8080/save/current") else { throw AppError.badURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try NetworkHelper.validateResponse(data: data, response: response)
        //                let jsonString = String(data: data, encoding: .utf8)
        //                print("target:  ", jsonString ?? "No JSON")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedAlbums = try decoder.decode([Album].self, from: data)
        
        await MainActor.run {
            self.mySavedAlbums = decodedAlbums
        }
    }
    
    
    func getSharedAlbums() async throws {
        guard let token = loginVM.token else {
            throw AppError.tokenIssue }
        guard let url = URL(string: "http://localhost:8080/album/shared") else {
            throw AppError.badURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try NetworkHelper.validateResponse(data: data, response: response)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedAlbums = try decoder.decode([Album].self, from: data)
        
        await MainActor.run {
            self.sharedAlbums = decodedAlbums
        }
        
    }
    
    func searchAlbums(query: String) -> (myAlbums: [Album], publicAlbums: [Album]) {
        guard !query.isEmpty else { return ([], []) }
        let q = query.lowercased()
        let my = myAlbums.filter {
            $0.title.lowercased().contains(q) ||
            ($0.town?.lowercased().contains(q) ?? false) ||
            ($0.country?.lowercased().contains(q) ?? false)
        }
        let pub = sharedAlbums.filter {
            $0.title.lowercased().contains(q) ||
            ($0.town?.lowercased().contains(q) ?? false) ||
            ($0.country?.lowercased().contains(q) ?? false)
        }
        return (my, pub)
    }
    
    func getAlbumInteraction(id: String) async throws{
        guard let token = loginVM.token else {
            throw AppError.tokenIssue }
        guard let url = URL(string: "http://localhost:8080/album/\(id)/interactions") else {
            throw AppError.badURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try NetworkHelper.validateResponse(data: data, response: response)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decodedInteractions = try decoder.decode(Interaction.self, from: data)
        
        await MainActor.run {
            self.albumInteractions = decodedInteractions
        }
        
        
    }
    
    func getAlbumById(id: String) async throws{
        guard let token = loginVM.token else {
            throw AppError.tokenIssue }
        guard let url = URL(string: "http://localhost:8080/album/\(id)") else {
            throw AppError.badURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        try NetworkHelper.validateResponse(data: data, response: response)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let album = try decoder.decode(Album.self, from: data)
        
        await MainActor.run {
            self.album = album
        }
        
        
    }

}

