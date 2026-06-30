//
//  Badge.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 08/06/2026.
//

import Foundation

struct Badge: Codable, Identifiable, Equatable {
    var id: UUID
    var picture: String
    var name: String
}


