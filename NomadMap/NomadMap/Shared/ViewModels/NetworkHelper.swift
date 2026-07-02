//
//  NetworkHelper.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 02/07/2026.
//

import SwiftUI


import Foundation

struct NetworkHelper {
    static func validateResponse(data: Data, response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.serverError
        }
        
        if (200...299).contains(httpResponse.statusCode) { return }
        
        if let backendError = try? JSONDecoder().decode(BackendError.self, from: data) {
            throw AppError.init(fromBackendReason: backendError.reason)
        }
        
        throw AppError.serverError
    }
}
