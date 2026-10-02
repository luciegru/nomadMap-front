//
//  MediaView.swift
//  NomadMap
//
//  Created by Lucie Grunenberger on 31/08/2026.
//

import SwiftUI

struct MediaView: View {
    let media: Media
    let role: UserRole
    let ownerId: UUID
    
    @State private var uiImage: UIImage?
    @State private var dominantColor = Color("black_1")
    @State private var showOverlay: Bool = false
    @State private var owner: User? = nil
    @State private var isLiked: Bool = false
    @State private var likeCounts: Int = 0
    @State private var isLoadingOwner: Bool = true
    @State private var showShareSheet: Bool = false
    @State private var showEditModal: Bool = false
    
    @Environment(LoginViewModel.self) private var loginVM
    @Environment(MediaViewModel.self) private var mediaVM
    @Environment(ParticipationViewModel.self) private var participationVM
    @Environment(AlbumViewModel.self) private var albumVM
    
    @Environment(\.dismiss) private var dismiss
    
    private var currentMedia: Media {
        albumVM.album?.medias?.first(where: { $0.id == media.id }) ?? media
    }
    
    var body: some View {
        ZStack {
            dominantColor.opacity(0.3).ignoresSafeArea()
            
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .ignoresSafeArea()
            } else {
                ProgressView()
            }
            
            if showOverlay {
                VStack {
                    Spacer()
                    
                    if let owner {
                        MediaOverlayView(
                            media: currentMedia,
                            role: role,
                            owner: owner,
                            likesCount: likeCounts,
                            isLiked: isLiked
                        ) { action in
                            switch action {
                            case .like:
                                toggleLike()
                            case .comment:
                                print("Comment pressed")
                            case .share:
                                guard uiImage != nil else { return }
                                showShareSheet = true
                            case .report:
                                print("Report pressed")
                            case .delete:
                                Task {
                                    do {
                                        try await mediaVM.deleteMedia(idMedia: currentMedia.id.uuidString)
                                        dismiss()
                                        albumVM.removeMedia(id: currentMedia.id)
                                    } catch {
                                        print("delete error: \(error)")
                                        // TODO: alerte d'erreur
                                    }
                                }
                            case .update:
                                showEditModal.toggle()                            }
                        }
//                        TODO: correct actions
                    } else if isLoadingOwner {
                        ProgressView()
                            .padding(.bottom, 24)
                    }
                }
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("black_1"))
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                showOverlay.toggle()
            }
        }
        .task(id: currentMedia.id) {
            await loadMedia()
        }
        .sheet(isPresented: $showShareSheet) {
            if let uiImage {
                ShareSheet(activityItems: [uiImage, shareCaption])
            }
        }
        .sheet(isPresented: $showEditModal) {
            EditModale(media: currentMedia).environment(mediaVM).environment(albumVM)
        }
    }
    
    private var shareCaption: String {
        if let note = currentMedia.note, !note.isEmpty {
            return note
        }
        if let location = media.location, !location.isEmpty {
            return "Photo prise à \(location) sur NomadMap"
        }
        return "Photo partagée depuis NomadMap"
    }
    
    private func loadMedia() async {
        uiImage = nil
        dominantColor = Color("black_1")
        owner = nil
        isLiked = false
        likeCounts = 0
        isLoadingOwner = true
        
        defer { isLoadingOwner = false }
        
        if let url = URL(string: media.mediaHQ),
           let (data, _) = try? await URLSession.shared.data(from: url),
           let image = UIImage(data: data) {
            uiImage = image
            if let color = image.dominantColor() {
                dominantColor = color
            }
        }
        
        do {
            owner = try await loginVM.getUserById(userId: ownerId)
            
            try await participationVM.getMediaLikeStatus(mediaId: currentMedia.id.uuidString)
            isLiked = participationVM.isMediaLiked
            
            try await participationVM.getMediaLike(mediaId: currentMedia.id.uuidString)
            likeCounts = participationVM.mediaLikes.count
        }  catch is CancellationError {
            return
        } catch let error as URLError where error.code == .cancelled {
            return
        } catch {
            print("MediaView loadMedia error: \(error)")
        }
    }
//    TODO: error alerts
    
    private func toggleLike() {
        let previousLiked = isLiked
        let previousCount = likeCounts
        
        isLiked.toggle()
        likeCounts += isLiked ? 1 : -1
        
        Task {
            do {
                try await participationVM.toggleMediaLike(mediaId: currentMedia.id.uuidString)
            } catch {
                await MainActor.run {
                    isLiked = previousLiked
                    likeCounts = previousCount
                }
                print("toggleLike error: \(error)")
            }
        }
    }
}

#Preview {
    MediaView(
        media: Media(
            id: UUID(uuidString: "03698100-022E-4860-BC14-857621F1F37E")!,
            userId: UUID(uuidString: "8AAA6F2D-5053-4AED-B1DB-6B95EA149966")!,
            albumId: UUID(uuidString: "0897E1C8-9708-45D0-AB98-57EB6EB73D8B")!,
            date: Date(),
            location: "Surf Spot",
            latitude: 63.5314,
            longitude: -19.5112,
            mediaHQ: "http://localhost:8080/uploads/AAAF3472-89EA-44E4-81B8-B03683E22298.jpg",
            lowQualityThumbnail: "http://localhost:8080/uploads/806D2662-E18B-4CE8-A2E3-A0D2F5E90473.jpg",
            note: "Dernière vague de la journée, immortalisée par Sandra !"
        ),
        role: .viewer,
        ownerId: UUID()
    )
    .environment(LoginViewModel())
    .environment(ParticipationViewModel())
    .environment(MediaViewModel())
    .environment(AlbumViewModel())
}
