//
//  OnBoarding4.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 13/05/2026.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct OnBoarding4: View {
    @State private var isVisible = false
    @State private var OBViewModel = OnboardingViewModel()
    @State private var albumVM = AlbumViewModel()
    @Environment(LoginViewModel.self) private var loginVM
    @State private var mediaVM = MediaViewModel()
    @State private var navigate: Bool = false
    @State private var uploadProgress: Double = 0
    @State private var isUploading: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var createAlbumVM = CreateAlbumViewModel()
    
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack{
                    Ellipse()
                        .customGradient()
                        .frame(width: 250, height: 100)
                        .blur(radius: 50)
                        .opacity(0.6)
                    
                    VStack{
                        if isVisible {
                            
                            Text("LETS_START")
                                .font(.largeTitle)
                                .bold()
                                .customGradient()
                                .padding(.horizontal, 30)
                            
                                .transition(.move(edge: .leading).combined(with: .opacity))
                            
                        }
                        
                        Spacer()
                        
                        Text("CREATE_FIRST_ALBUM")
                            .foregroundStyle(Color.gray)
                        
                        Spacer()
                        
                        CreateAlbumForm(albumName: $createAlbumVM.albumName, albumDescription: $createAlbumVM.albumDescription, date: $createAlbumVM.date, destinationName: $createAlbumVM.destinationName, continent: $createAlbumVM.continent, town: $createAlbumVM.town, latitude: $createAlbumVM.latitude, longitude: $createAlbumVM.longitude, country: $createAlbumVM.country, albumPictures: $createAlbumVM.albumPictures, publicAlbum: $createAlbumVM.publicAlbum)
                            .environment(OBViewModel)
                            .environment(albumVM)
                        
                        HStack{
                            
                            NavigationLink(destination: {
                                OnBoarding5().environment(loginVM)
                            }, label: {
                                Text("SKIP")
                                    .font(.system(size: 20))
                                    .bold()
                                    .foregroundStyle(Color.gray)
                                    .padding(.leading, 40)
                            })
                            
                            if isUploading {
                                VStack {
                                    ProgressView(value: uploadProgress)
                                        .progressViewStyle(.linear)
                                        .padding(.horizontal, 40)
                                    Text("\(Int(uploadProgress * 100))%")
                                        .foregroundStyle(.white)
                                }
                            }
                            
                            
                            Spacer()
                            if createAlbumVM.albumName != "" && createAlbumVM.destinationName != "" {
                                
                                Button(action: {
                                    Task{
                                        do{
                                        
                                        try await albumVM.createAlbum(with: createAlbumVM.toPayload(userId: loginVM.currentUser?.id.uuidString ?? UUID().uuidString))
                                        
                                        
                                        isUploading = true
                                        uploadProgress = 0
                                            let total = Double(createAlbumVM.albumPictures.count)
                                        var completed = 0.0
                                        
                                        
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
                                                            "userId": loginVM.currentUser?.id.uuidString ??  UUID().uuidString,
                                                            "albumId": albumVM.lastCreatedAlbum?.id.uuidString ?? "",
                                                            "latitude": metadata.latitude ?? 0.0,
                                                            "longitude": metadata.longitude ?? 0.0,
                                                            "mediaHQ": finalHdUrl,
                                                            "lowQualityThumbnail": finalThumbnailUrl,
                                                            "size": metadata.fileSize ?? 0
                                                        ])
                                                        
                                                        await MainActor.run {
                                                            completed += 1
                                                            uploadProgress = completed / total
                                                        }
                                                        
                                                    } catch {
                                                    }
                                                }
                                            }
                                            while activeUploads > 0 {
                                                await group.next()
                                                activeUploads -= 1
                                            }
                                        }
                                        
                                        try await loginVM.getCurrentUser()
                                        
                                        isUploading = false
                                        
                                        navigate = true
                                        } catch let error as AppError {
                                                        showAlert = true
                                                        alertMessage = error.errorDescription ?? ""
                                                    } catch {
                                                        alertMessage = "Impossible de charger les données de l'album. Vérifie ta connexion."
                                                        showAlert = true
                                                    }
                                                    
                                    }
                                        
                                    
                                }, label: {
                                    GoButton(muted:false)
                                })
                            } else {
                                GoButton(muted:true)
                            }
                            
                        }.padding(.bottom, 60)
                            .padding(.trailing, 30)
                        
                    }.padding(.top, 100)
                }}
            .navigationDestination(isPresented: $navigate) {
                OnBoarding5()
            }
            
            .onAppear {
                withAnimation(.spring(bounce: 0.5)) {
                    isVisible = true
                }
                
            }
            .alert("Oops 🙃", isPresented: $showAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text(alertMessage)
            })

            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
            
            
        }.navigationBarBackButtonHidden()
    }
}

#Preview {
    OnBoarding4().environment(LoginViewModel())
}
