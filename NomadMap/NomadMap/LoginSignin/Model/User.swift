//
//  User.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 28/04/2026.
//

import Foundation

struct User: Codable, Identifiable, Equatable {
    var id: UUID
    var levelId: UUID
    var name: String
    var firstName: String
    var email: String
    var profilPicture: String?
    var coverPicture: String?
    var signupDate: Date
    var userName: String
    var biography: String?
    var ownedStorage: Double
    var usedStorage: Double
    var point: Int
    var subscriptionType: Int
    var accountStatus: Int
}




