//
//  UploadService.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 13/05/2026.
//


import SwiftUI
import PhotosUI
import Photos
import ImageIO


struct UploadService {
    static func uploadThumbnail(_ photoItem: PhotosPickerItem) async throws -> String {
        guard let imageData = try await photoItem.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: imageData),
              let compressedData = uiImage.jpegData(compressionQuality: 0.3) else {
            throw URLError(.badServerResponse)
        }
        
        return try await uploadData(compressedData)
    }
    
    static func uploadImage(_ photoItem: PhotosPickerItem) async throws -> String {
        guard let imageData = try await photoItem.loadTransferable(type: Data.self) else {
            throw URLError(.badServerResponse)
        }
        return try await uploadData(imageData)
    }
    
    private static func uploadData(_ imageData: Data) async throws -> String {
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: "http://127.0.0.1:8080/upload")!)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
            }
            
            let json = try JSONDecoder().decode([String: String].self, from: data)
            guard let url = json["url"] else {
                throw URLError(.badServerResponse)
            }
            
            return url
            
        } catch {
            throw error
        }
    }
    
    static func getMetadata(from item: PhotosPickerItem) async -> (latitude: Double?, longitude: Double?, fileSize: Int?)  {
        
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            return (nil, nil, nil)
        }
        
        let poidsEnOctets = data.count
        let poidsEnMo = Int((Double(poidsEnOctets) / (1024.0 * 1024.0)).rounded(.up))
        
        
        var latitude: Double? = nil
        var longitude: Double? = nil
        
        if let imageSource = CGImageSourceCreateWithData(data as CFData, nil),
           let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [String: Any],
           let gpsInfo = imageProperties[kCGImagePropertyGPSDictionary as String] as? [String: Any] {
            
            if let lat = gpsInfo[kCGImagePropertyGPSLatitude as String] as? Double,
               let latRef = gpsInfo[kCGImagePropertyGPSLatitudeRef as String] as? String {
                latitude = (latRef == "S") ? -lat : lat
            }
            
            if let lon = gpsInfo[kCGImagePropertyGPSLongitude as String] as? Double,
               let lonRef = gpsInfo[kCGImagePropertyGPSLongitudeRef as String] as? String {
                longitude = (lonRef == "W") ? -lon : lon
            }
        } else {
            print("ℹ️ Aucune métadonnée GPS trouvée")
        }
        
        
        return (latitude, longitude, poidsEnMo)
    }
}
