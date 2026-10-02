//
//  CreateAlbumViewModel.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 03/07/2026.
//

import SwiftUI
import PhotosUI
import Observation

@Observable
class CreateAlbumViewModel {
    var albumName: String = ""
    var albumDescription: String = ""
    var date: Date = Date()
    var destinationName: String = ""
    var continent: String = ""
    var town: String = ""
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var country: String = ""
    var albumPictures: [PhotosPickerItem] = []
    var publicAlbum: Bool = false
    
    var isValid: Bool {
        !albumName.isEmpty && !destinationName.isEmpty
    }
    
    func reset() {
        albumName = ""
        albumDescription = ""
        date = Date()
        destinationName = ""
        continent = ""
        town = ""
        latitude = 0.0
        longitude = 0.0
        country = ""
        albumPictures = []
        publicAlbum = false
    }
    
    func toPayload(userId: String) -> [String: Any] {
        return [
            "userId": userId,
            "title": albumName,
            "description": albumDescription,
            "continent": continent,
            "country": country,
            "town": town,
            "latitude": latitude,
            "longitude": longitude,
            "journeyStartDate": ISO8601DateFormatter().string(from: date),
            "visibility": publicAlbum ? 1 : 0,
        ]
    }
}
