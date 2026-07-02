//
//  AppError.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 02/07/2026.
//


import Foundation

enum AppError: LocalizedError, Equatable {

    case badURL
    case serverError
    case decodingError
    case unknown
    case tokenIssue
    
    case allFieldsEmpty
    case passwordMismatch
    
    case emailNotValid
    case emailTaken
    case usernameTaken
    case passwordTooWeak
    case wrongCredentials
    
    case albumNotFound
    case unauthorizedAction
    
    case mediaUploadFailed


    var errorDescription: String? {
        switch self {
        case .badURL: return NSLocalizedString("L'adresse du serveur est incorrecte.", comment: "")
        case .serverError: return NSLocalizedString("Le serveur rencontre un problème. Réessaye plus tard.", comment: "")
        case .decodingError: return NSLocalizedString("Erreur de traitement des données.", comment: "")
        case .unknown: return NSLocalizedString("Une erreur inconnue est survenue.", comment: "")
        case .tokenIssue: return NSLocalizedString("Un problème de token est survenu. Veuillez vous reconnecter.", comment: "")
        
        case .allFieldsEmpty: return NSLocalizedString("Veuillez remplir tous les champs.", comment: "")
        case .passwordMismatch: return NSLocalizedString("Les mots de passe ne correspondent pas.", comment: "")
        
        case .emailNotValid: return NSLocalizedString("Veuillez entrer une adresse email valide.", comment: "")
        case .emailTaken: return NSLocalizedString("Cette adresse email est déjà utilisée.", comment: "")
        case .usernameTaken: return NSLocalizedString("Ce nom d'utilisateur est déjà pris.", comment: "")
        case .passwordTooWeak: return NSLocalizedString("Le mot de passe est trop faible.", comment: "")
        case .wrongCredentials: return NSLocalizedString("Email ou mot de passe incorrect.", comment: "")
        
        case .albumNotFound: return NSLocalizedString("Cet album n'existe plus ou a été supprimé.", comment: "")
        case .unauthorizedAction: return NSLocalizedString("Tu n'as pas la permission de faire ça.", comment: "")
        case .mediaUploadFailed: return NSLocalizedString("Impossible d'envoyer la photo.", comment: "")
        }
    }


    init(fromBackendReason reason: String) {
        switch reason {

        case "INVALID_EMAIL": self = .emailNotValid
        case "EMAIL_TAKEN": self = .emailTaken
        case "USERNAME_TAKEN", "409": self = .usernameTaken
        case "INVALID_PASSWORD_STRUCTURE": self = .passwordTooWeak
        case "WRONG_CREDENTIALS": self = .wrongCredentials
        
        case "ALBUM_NOT_FOUND": self = .albumNotFound
        case "UNAUTHORIZED": self = .unauthorizedAction
        
        case "UPLOAD_FAILED": self = .mediaUploadFailed
            
        default: self = .unknown
        }
    }
}

struct BackendError: Codable {
    let error: Bool
    let reason: String
}
