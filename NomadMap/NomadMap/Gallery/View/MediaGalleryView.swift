//
//  MediaGalleryView.swift
//  NomadMap
//

import SwiftUI

struct MediaGalleryView: View {
    let role: UserRole
    let albumId: UUID
    @State private var selectedIndex: Int
    @State private var scrollPosition: Int?

    @Environment(LoginViewModel.self) private var loginVM
    @Environment(AlbumViewModel.self) private var albumVM
    @Environment(MediaViewModel.self) private var mediaVM
    @Environment(ParticipationViewModel.self) private var participationVM

    private var mediaItems: [Media] {
        guard albumVM.album?.id == albumId else { return [] }
        return albumVM.album?.medias ?? []
    }

    init(role: UserRole, albumId: UUID, initialIndex: Int = 0) {
        self.role = role
        self.albumId = albumId
        self._selectedIndex = State(initialValue: initialIndex)
        self._scrollPosition = State(initialValue: initialIndex)
    }

    private func role(for media: Media) -> UserRole {
        media.userId == loginVM.currentUser?.id ? .owner : .viewer
    }

    var body: some View {
        GeometryReader { geo in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(Array(mediaItems.enumerated()), id: \.element.id) { index, media in
                        MediaView(media: media, role: role(for: media), ownerId: media.userId).environment(loginVM).environment(mediaVM).environment(participationVM).environment(albumVM)
                            .frame(width: geo.size.width, height: geo.size.height)
                            .id(index)
                    }                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $scrollPosition)
            .scrollIndicators(.hidden)
            .onChange(of: scrollPosition) { _, new in
                if let new { selectedIndex = new }
            }
        }
        .ignoresSafeArea()
        .background(Color("black_1"))
    }
}

//#Preview {
//    MediaGalleryView(
//        mediaItems: [
//            Media(
//                id: UUID(uuidString: "03698100-022E-4860-BC14-857621F1F37E")!,
//                userId: UUID(uuidString: "8AAA6F2D-5053-4AED-B1DB-6B95EA149966")!,
//                albumId: UUID(uuidString: "0897E1C8-9708-45D0-AB98-57EB6EB73D8B")!,
//                date: Date(),
//                location: nil,
//                latitude: 63.5314,
//                longitude: -19.5112,
//                mediaHQ: "http://localhost:8080/uploads/AAAF3472-89EA-44E4-81B8-B03683E22298.jpg",
//                lowQualityThumbnail: "http://localhost:8080/uploads/806D2662-E18B-4CE8-A2E3-A0D2F5E90473.jpg",
//                note: "Dernière vague de la journée, immortalisée par Sandra !"
//            ),
//            Media(
//                id: UUID(uuidString: "8AAA6F2D-5053-4AED-B1DB-6B95EA149966")!,
//                userId: UUID(uuidString: "8AAA6F2D-5053-4AED-B1DB-6B95EA149966")!,
//                albumId: UUID(uuidString: "0897E1C8-9708-45D0-AB98-57EB6EB73D8B")!,
//                date: Date().addingTimeInterval(-86400),
//                location: nil,
//                latitude: 37.76007833333333,
//                longitude: -122.50956666666667,
//                mediaHQ: "http://localhost:8080/uploads/DD0F4CE7-C0A5-4785-9BCE-5CD770460005.jpg",
//                lowQualityThumbnail: "http://localhost:8080/uploads/6C972907-EF34-4135-8500-62DE735302BB.jpg",
//                note: nil
//            )
//        ],
//        role: .viewer,
//        ownerId: UUID(uuidString: "8AAA6F2D-5053-4AED-B1DB-6B95EA149966")!,
//        initialIndex: 0
//    )
//    .environment(LoginViewModel())
//    .environment(AlbumViewModel())
//    .environment(ParticipationViewModel())
//    .environment(MediaViewModel())
//}
