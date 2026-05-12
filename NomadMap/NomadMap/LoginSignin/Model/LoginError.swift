//
//  LoginError.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 06/05/2026.
//

import Foundation

enum LoginError: LocalizedError, Equatable {
    case wrongCredentials
    case network
    case server
    case unknown
    case passwordMismatch
    case allFieldsEmpty
    case emailNotValid
    case usernameTaken
    case emailTaken
    case passwordtooweak

    var errorDescription: String? {
        switch self {
        case .wrongCredentials:
            return NSLocalizedString("ERROR_WRONG_MAIL_PASSWORD", comment: "Wrong email or password")
        case .network:
            return NSLocalizedString("ERROR_NETWORK", comment: "Network error")
        case .server:
            return NSLocalizedString("ERROR_SERVER", comment: "Server error")
        case .unknown:
            return NSLocalizedString("ERROR_UNKNOWN", comment: "Unknown error")
        case .passwordMismatch:
            return NSLocalizedString("ERROR_PASSWORD_MISMATCH", comment: "Passwords do not match")
        case .allFieldsEmpty:
            return NSLocalizedString("ERROR_ALL_FIELDS_EMPTY", comment: "Please fill all the fields")
        case .emailNotValid:
            return NSLocalizedString("ERROR_EMAIL_NOT_VALID", comment: "Please enter a valid email")
        case .usernameTaken:
            return NSLocalizedString("ERROR_USERNAME_TAKEN", comment: "Username already taken")
        case .emailTaken:
            return NSLocalizedString("ERROR_EMAIL_TAKEN", comment: "Email already taken")
        case .passwordtooweak:
            return NSLocalizedString("ERROR_PASSWORD_TOO_WEAK", comment: "Password is too weak")
        }
    }
}

struct BackendError: Codable {
    let error: Bool
    let reason: String
}
