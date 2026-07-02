//
//  Interaction.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 01/07/2026.
//

import Foundation

struct InteractionComment: Codable, Identifiable, Equatable {
    var id: UUID
    var user: UserLight
    var content: String
    var date: Date
}


struct Interaction: Codable, Equatable {
    var likes: [UserLight]
    var comments: [InteractionComment]
    var saves: [UserLight]
    var isLiked: Bool
    var isSaved: Bool
}

struct UserLight: Codable, Identifiable, Equatable {
    var id: UUID
    var userName: String
    var profilPicture: String?
}

