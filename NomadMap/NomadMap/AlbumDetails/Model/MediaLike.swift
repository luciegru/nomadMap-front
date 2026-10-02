//
//  MediaLike.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 02/09/2026.
//

import Foundation

struct MediaLike: Codable {
    let id: UUID
    let userId: UUID
    let mediaId: UUID
    let date: Date
}

