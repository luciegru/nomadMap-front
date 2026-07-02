//
//  Participation.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 30/06/2026.
//

import Foundation

struct Participation: Codable, Identifiable, Equatable {
    var id: UUID
    var userId: UUID
    var albumId: UUID
    var permission: Int
    var QRCode: String?
    var shareLink: String?
}

enum UserRole {
    case owner
    case participant
    case viewer
}

enum AlbumInteraction {
    case openComments
    case openShare
    case openEdit
    case openReport
}

struct IsLiked: Codable {
    var isLiked: Bool
}


