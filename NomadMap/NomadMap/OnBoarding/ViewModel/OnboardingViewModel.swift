//
//  OnboardingViewModel.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 12/05/2026.
//

import Foundation
import SwiftUI
import PhotosUI

@Observable
class OnboardingViewModel {
    var displayedText: String = ""
    var profileImage: Image? = nil
    var coverImage: Image? = nil
    var albumImages: [AlbumImage] = []

    func loadProfileImage(from item: PhotosPickerItem?) {
        Task {
            guard let data = try? await item?.loadTransferable(type: Data.self) else { return }
            guard let uiImage = UIImage(data: data) else { return }
            
            await MainActor.run {
                self.profileImage = Image(uiImage: uiImage)
            }
        }
    }
    
    func loadCoverImage(from item: PhotosPickerItem?) {
        Task {
            guard let data = try? await item?.loadTransferable(type: Data.self) else { return }
            guard let uiImage = UIImage(data: data) else { return }
            
            await MainActor.run {
                self.coverImage = Image(uiImage: uiImage)
            }
        }
    }
    
    func loadAlbumImages(from items: [PhotosPickerItem]) {
        Task {
            var newImages: [AlbumImage] = []
            
            for item in items {
                guard let data = try? await item.loadTransferable(type: Data.self) else { continue }
                guard let uiImage = UIImage(data: data) else { continue }
                newImages.append(AlbumImage(image: Image(uiImage: uiImage)))
            }
            
            await MainActor.run {
                self.albumImages = newImages 
            }
        }
    }

    
    func typeWriterEffect(translationKey: String) async {
        
        let resource = LocalizedStringResource(stringLiteral: translationKey)
        let translatedText = String(localized: resource)
        
        
        displayedText = ""
        
        for character in translatedText {
            displayedText.append(character)
            try? await Task.sleep(nanoseconds: 25_000_000)
        }
    }
    
    
}

struct AlbumImage: Identifiable {
    let id = UUID()
    let image: Image
}



