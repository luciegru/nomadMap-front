//
//  Album.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 15/05/2026.
//

import Foundation

struct Album: Codable, Identifiable, Equatable, Hashable {
    var id: UUID
    var userId: UUID
    var title: String
    var description: String?
    var continent: String?
    var country: String?
    var town: String?
    var latitude: Double
    var longitude: Double
    var coverPicture: String?
    var creationDate: Date
    var journeyStartDate: Date
    var journeyEndDate: Date?
    var visibility: Int
    var medias: [Media]?
    
    
    
    var displayLocation: String {
            if let town = town, !town.isEmpty {
                return town
            } else if let country = country, !country.isEmpty {
                return country
            } else {
                return continent ?? ""
            }
        }
}
