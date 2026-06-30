//
//  Level.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 29/06/2026.
//

import Foundation

struct Level: Codable, Identifiable, Equatable {
    var id: UUID
    var name: String
    var point: Int
}
