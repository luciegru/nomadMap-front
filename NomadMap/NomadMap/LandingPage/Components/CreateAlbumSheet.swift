//
//  CreateAlbumSheet.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 03/07/2026.
//


import SwiftUI

struct CreateAlbumSheet: View {
    
    @Environment(LoginViewModel.self) private var loginVM
    @Environment(AlbumViewModel.self) private var albumVM
    @Environment(OnboardingViewModel.self) private var OBViewModel
    
    @Bindable var createAlbumVM: CreateAlbumViewModel
    @State private var mediaVM = MediaViewModel()
    
    @Binding var showCreateAlbum: Bool
    @Binding var showAlert: Bool
    @Binding var alertMessage: String
    
    var body: some View {
        VStack {
            Text("CREATE_ALBUM")
                .font(Font.system(size: 30, weight: .bold))
                .customGradient()
                .padding(.top, 20)
            
            CreateAlbumForm(
                albumName: $createAlbumVM.albumName,
                albumDescription: $createAlbumVM.albumDescription,
                date: $createAlbumVM.date,
                destinationName: $createAlbumVM.destinationName,
                continent: $createAlbumVM.continent,
                town: $createAlbumVM.town,
                latitude: $createAlbumVM.latitude,
                longitude: $createAlbumVM.longitude,
                country: $createAlbumVM.country,
                albumPictures: $createAlbumVM.albumPictures,
                publicAlbum: $createAlbumVM.publicAlbum
            )
            
            Button(action: {
                Task {
                    do {
                        try await albumVM.createAlbum(with: createAlbumVM.toPayload(userId: loginVM.currentUser?.id.uuidString ?? UUID().uuidString))
                        
                        await withTaskGroup(of: Void.self) { group in
                            let maxConcurrentUploads = 3
                            var activeUploads = 0
                            
                            for media in createAlbumVM.albumPictures {
                                if activeUploads >= maxConcurrentUploads {
                                    await group.next()
                                    activeUploads -= 1
                                }
                                activeUploads += 1
                                group.addTask {
                                    do {
                                        let metadata = await UploadService.getMetadata(from: media)
                                        let finalHdUrl = try await UploadService.uploadImage(media)
                                        let finalThumbnailUrl = try await UploadService.uploadThumbnail(media)
                                        
                                        try await mediaVM.createMedia(with: [
                                            "userId": loginVM.currentUser?.id.uuidString ?? UUID().uuidString,
                                            "albumId": albumVM.lastCreatedAlbum?.id.uuidString ?? "",
                                            "latitude": metadata.latitude ?? 0.0,
                                            "longitude": metadata.longitude ?? 0.0,
                                            "mediaHQ": finalHdUrl,
                                            "lowQualityThumbnail": finalThumbnailUrl,
                                            "size": metadata.fileSize ?? 0
                                        ])
                                    } catch {}
                                }
                            }
                            while activeUploads > 0 {
                                await group.next()
                                activeUploads -= 1
                            }
                        }
                        
                        showCreateAlbum = false
                        createAlbumVM.reset()
                        
                        try await Task.sleep(nanoseconds: 3_000_000_000)
                        try await albumVM.getCurrentUserAlbums()
                        try await albumVM.getSharedAlbums()
                        
                    } catch let error as AppError {
                        showAlert = true
                        alertMessage = error.errorDescription ?? ""
                    } catch {
                        alertMessage = "Impossible de charger les données de l'album. Vérifie ta connexion."
                        showAlert = true
                    }
                }
            }, label: {
                CustomGradientButton(
                    text: "CREATE",
                    muted: !createAlbumVM.isValid,
                    width: 150
                )
                .opacity(createAlbumVM.isValid ? 1 : 0.5)
            })
        }
        .background(Color.black1)
    }
}
