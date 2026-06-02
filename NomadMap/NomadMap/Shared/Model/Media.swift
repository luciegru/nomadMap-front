//
//  Media.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 28/05/2026.
//

import Foundation

struct Media: Codable, Identifiable, Equatable {
    var id: UUID
    var userId: UUID
    var albumId: UUID
    var date: Date
    var location: String?
    var latitude: Double?
    var longitude: Double?
    var mediaHQ: String
    var lowQualityThumbnail: String
    var note: String?
}
