//
//  Login.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 28/04/2026.
//

import Foundation


struct LoginResponse: Codable {
    let token: String
    let user: User
}

