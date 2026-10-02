//
//   AppError.swift
//   NomadMap
//
//   Created by Lucie Grunenberger on 02/07/2026.
//

import Foundation

enum AppError: LocalizedError, Equatable {
    
    // Erreurs techniques / Réseau
    case badURL
    case serverError
    case decodingError
    case unknown
    case tokenIssue
    case databaseError
    
    // Formulaires locaux (Front)
    case allFieldsEmpty
    case passwordMismatch
    
    // Authentification & Compte (Back)
    case emailNotValid
    case emailTaken
    case usernameTaken
    case passwordTooWeak
    case wrongCredentials
    case userNotFound
    
    // Entités & Métier (Back)
    case albumNotFound
    case saveNotFound
    case shopItemNotFound
    case userReportingNotFound
    case participationNotFound
    case unauthorizedAction
    case mediaUploadFailed
    case invalidBody
    case genericBackendError
    
    var errorDescription: String? {
        switch self {
        case .badURL:
            return NSLocalizedString("ERROR_BAD_URL", comment: "L'adresse du serveur est incorrecte.")
        case .serverError:
            return NSLocalizedString("ERROR_SERVER_DOWN", comment: "Le serveur rencontre un problème.")
        case .decodingError:
            return NSLocalizedString("ERROR_DECODING_FAILED", comment: "Erreur de traitement des données.")
        case .unknown:
            return NSLocalizedString("ERROR_UNKNOWN", comment: "Une erreur inconnue est survenue.")
        case .tokenIssue:
            return NSLocalizedString("ERROR_TOKEN_ISSUE", comment: "Problème de token de session.")
        case .databaseError:
            return NSLocalizedString("ERROR_DATABASE_DRIVER_UNSUPPORTED", comment: "Erreur interne de base de données.")
            
        case .allFieldsEmpty:
            return NSLocalizedString("ERROR_ALL_FIELDS_EMPTY", comment: "Veuillez remplir tous les champs.")
        case .passwordMismatch:
            return NSLocalizedString("ERROR_PASSWORD_MISMATCH", comment: "Les mots de passe ne correspondent pas.")
            
        case .emailNotValid:
            return NSLocalizedString("ERROR_INVALID_EMAIL", comment: "Veuillez entrer une adresse email valide.")
        case .emailTaken:
            return NSLocalizedString("ERROR_EMAIL_TAKEN", comment: "Cette adresse email est déjà utilisée.")
        case .usernameTaken:
            return NSLocalizedString("ERROR_USERNAME_TAKEN", comment: "Ce nom d'utilisateur est déjà pris.")
        case .passwordTooWeak:
            return NSLocalizedString("ERROR_INVALID_PASSWORD_STRUCTURE", comment: "Le mot de passe est trop faible.")
        case .wrongCredentials:
            return NSLocalizedString("ERROR_WRONG_CREDENTIALS", comment: "Email ou mot de passe incorrect.")
        case .userNotFound:
            return NSLocalizedString("ERROR_USER_NOT_FOUND", comment: "Utilisateur introuvable.")
            
        case .albumNotFound:
            return NSLocalizedString("ERROR_ALBUM_NOT_FOUND", comment: "Cet album n'existe plus.")
        case .saveNotFound:
            return NSLocalizedString("ERROR_SAVE_NOT_FOUND", comment: "Sauvegarde introuvable.")
        case .shopItemNotFound:
            return NSLocalizedString("ERROR_SHOP_ITEM_NOT_FOUND", comment: "Article de boutique introuvable.")
        case .userReportingNotFound:
            return NSLocalizedString("ERROR_USER_REPORTING_NOT_FOUND", comment: "Signalement introuvable.")
        case .participationNotFound:
            return NSLocalizedString("ERROR_PARTICIPATION_NOT_FOUND", comment: "Participation introuvable.")
            
        case .unauthorizedAction:
            return NSLocalizedString("ERROR_UNAUTHORIZED", comment: "Action non autorisée.")
        case .mediaUploadFailed:
            return NSLocalizedString("ERROR_FILE_UPLOAD_FAILED", comment: "Impossible d'envoyer le fichier.")
        case .invalidBody:
            return NSLocalizedString("ERROR_INVALID_BODY", comment: "Données de requête invalides.")
        case .genericBackendError:
            return NSLocalizedString("ERROR_GENERIC_BACKEND", comment: "Une erreur est survenue sur le serveur.")
        }
    }
    
    init(fromBackendReason reason: String) {
        switch reason {
            // Authentification & Validation
        case "INVALID_EMAIL": self = .emailNotValid
        case "EMAIL_TAKEN", "ERROR_EMAIL_TAKEN": self = .emailTaken
        case "USERNAME_TAKEN", "ERROR_USERNAME_TAKEN", "409": self = .usernameTaken
        case "INVALID_PASSWORD_STRUCTURE", "ERROR_INVALID_PASSWORD_STRUCTURE": self = .passwordTooWeak
        case "WRONG_CREDENTIALS", "ERROR_INCORRECT_PASSWORD": self = .wrongCredentials
        case "ERROR_UNKNOWN_USER", "ERROR_USER_NOT_FOUND": self = .userNotFound
            
            // Entités introuvables
        case "ALBUM_NOT_FOUND", "ERROR_INVALID_ALBUM_ID": self = .albumNotFound
        case "ERROR_SAVE_NOT_FOUND", "ERROR_INVALID_SAVE_ID": self = .saveNotFound
        case "ERROR_SHOP_ITEM_NOT_FOUND", "ERROR_INVALID_SHOP_ITEM_ID": self = .shopItemNotFound
        case "ERROR_USER_REPORTING_NOT_FOUND", "ERROR_INVALID_USER_REPORTING_ID": self = .userReportingNotFound
        case "ERROR_PARTICIPATION_NOT_FOUND", "ERROR_INVALID_PARTICIPATION_ID": self = .participationNotFound
            
            // Droits et formats
        case "UNAUTHORIZED", "ERROR_UNAUTHORIZED_PROFILE_MODIFICATION": self = .unauthorizedAction
        case "ERROR_INVALID_BODY": self = .invalidBody
        case "ERROR_DATABASE_DRIVER_UNSUPPORTED": self = .databaseError
            
            // Uploads & Échecs génériques d'écriture
        case "UPLOAD_FAILED", "ERROR_FILE_UPLOAD_FAILED": self = .mediaUploadFailed
            
            // Fallbacks d'erreurs génériques du Back
        case let str where str.contains("FAILED"): self = .genericBackendError
            
        default:
            self = .unknown
        }
        
    }
}

struct BackendError: Codable {
    let error: Bool
    let reason: String
}
