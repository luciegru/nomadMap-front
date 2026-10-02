//
//  GalleryView.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 31/08/2026.
//

import SwiftUI
import PhotosUI

struct GalleryView: View {
    @Environment(LoginViewModel.self) private var loginVM
    @Environment(AlbumViewModel.self) private var albumVM
    @Environment(ParticipationViewModel.self) private var participationVM
    @Environment(\.dismiss) private var dismiss

    
    @State private var mediaVM = MediaViewModel()
    @State private var albumPictures: [PhotosPickerItem] = []
    @State private var isUploading = false
    
    let role: UserRole
    let albumId: UUID

    private var medias: [Media] {
        guard albumVM.album?.id == albumId else { return [] }
        return albumVM.album?.medias ?? []
    }
    
    var body: some View {
            VStack {
                HStack {
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(Color.white)
                            .font(.system(size: 20, weight: .semibold))
                    }.padding(.trailing, 10)
                    
                    Text("GALLERY")
                        .font(Font.title.bold())
                        .foregroundStyle(Color.white)
                    
                    Spacer()
                    
                    if role == .owner || role == .participant {
                        PhotosPicker(selection: $albumPictures, maxSelectionCount: 30) {
                            CustomGradientButton(text: "ADD_MEDIAS", muted: isUploading, height: 40, width: 140)
                        }
                        .disabled(isUploading)
                        .onChange(of: albumPictures) {
                            guard !albumPictures.isEmpty else { return }
                            let items = albumPictures
                            let userId = loginVM.currentUser?.id.uuidString ?? ""
                            let albumIdString = albumId.uuidString
                            let vm = mediaVM

                            Task {
                                isUploading = true
                                var created: [Media] = []

                                await withTaskGroup(of: Media?.self) { group in
                                    var running = 0
                                    for item in items {
                                        if running >= 3, let result = await group.next() {
                                            if let m = result { created.append(m) }
                                            running -= 1
                                        }
                                        running += 1
                                        group.addTask {
                                            do {
                                                let metadata = await UploadService.getMetadata(from: item)
                                                let hd = try await UploadService.uploadImage(item)
                                                let thumb = try await UploadService.uploadThumbnail(item)
                                                return try await vm.createMedia(with: [
                                                    "userId": userId,
                                                    "albumId": albumIdString,
                                                    "latitude": metadata.latitude ?? 0.0,
                                                    "longitude": metadata.longitude ?? 0.0,
                                                    "mediaHQ": hd,
                                                    "lowQualityThumbnail": thumb,
                                                    "size": metadata.fileSize ?? 0
                                                ])
                                            } catch {
                                                print("Erreur d'upload image: \(error)")
                                                return nil
                                            }
                                        }
                                    }
                                    for await result in group {
                                        if let m = result { created.append(m) }
                                    }
                                }

                                albumVM.addMedias(created)
                                albumPictures = []
                                isUploading = false
                            }
                        }                    }
                }
                .padding(.top, 67)
                .padding(.horizontal, 25)
                //            TODO: when handling album views, in the back change the function to check if this album has already be seen by this user, otherwise I can see 68 times my album and be rewarded for it
                
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.fixed(120)),
                            GridItem(.fixed(120)),
                            GridItem(.fixed(120))
                        ],
                        alignment: .center,
                        spacing: 20
                    ) {
                        ForEach(Array(medias.enumerated()), id: \.element.id) { index, media in
                            NavigationLink(
                                destination:
                                    MediaGalleryView(role: role, albumId: albumId, initialIndex: index)
                                    .ignoresSafeArea()
                                    .environment(loginVM)
                                    .environment(albumVM)
                                    .environment(participationVM)
                                    .environment(mediaVM)                            ) {
                                    AsyncImage(url: URL(string: media.lowQualityThumbnail)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 110, height: 110)
                                            .clipShape(RoundedRectangle(cornerRadius: 20))
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                        }
                    }
                    .padding(.top, 30)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("black_1"))
            .ignoresSafeArea()
            .toolbar(.hidden, for: .navigationBar)
        
    }
}
#Preview {
    GalleryView(
        role: .owner, albumId: UUID()
    ).environment(LoginViewModel()).environment(AlbumViewModel()).environment(ParticipationViewModel())
}

