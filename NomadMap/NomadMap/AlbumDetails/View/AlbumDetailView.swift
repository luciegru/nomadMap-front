//
//  AlbumDetailView.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 30/06/2026.
//

import SwiftUI

struct AlbumDetailView: View {
    public var album: Album
    @Environment(ParticipationViewModel.self) private var participationVM
    @Environment(LoginViewModel.self) private var loginVM
    @Environment(AlbumViewModel.self) private var albumVM
    @State private var showComments = false
    @State private var showShare = false
    @State private var showEdit = false
    @State private var showReport = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    
    var userRole: UserRole {
        guard let currentId = loginVM.currentUser?.id else { return .viewer }
        if currentId == album.userId { return .owner }
        if participationVM.participations.contains(where: { $0.id == currentId }) { return .participant }
        return .viewer
    }
    
    
    
    var body: some View {
        NavigationStack(){
            GeometryReader { geo in
                
                ZStack{
                    
                    AsyncImage(url: URL(string: album.coverPicture ?? album.medias?.first?.mediaHQ ?? "")) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .opacity(0.4)
                            .background(Color("black_1"))
                    } placeholder: {
                        ProgressView()
                            .frame(width: 110, height: 100)
                    }
                    .id(album.coverPicture)
                    .frame(width: geo.size.width, height: geo.size.height)
                    
                    .ignoresSafeArea()
                    .clipped()
                    
                    //TODO: manage errors
                    
                    VStack(alignment: .leading){
                        VisibilityComponent(isPublic: album.visibility == 0 ? false : true)
                            .padding(.leading, 170)
                        Spacer()
                        Text(album.title)
                            .font(Font.system(size: 24, weight: .semibold))
                            .foregroundStyle(Color.white)
                        Text(album.journeyStartDate.formatted(.dateTime.day().month().year()))
                            .font(Font.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.white)
                        
                        Spacer()
                        HStack{
                            Image(systemName: "location.circle.fill")
                                .foregroundStyle(Color("green_1"))
                                .font(Font.system(size: 16,weight: .semibold))
                            Text((album.town ?? album.country) ?? album.continent ?? "")
                                .foregroundStyle(Color("green_1"))
                                .font(Font.system(size: 16, weight: .semibold))
                        }
                        Spacer()
                        HStack{
                            let maxVisible = 6
                            let visible = participationVM.participations.sorted { $0.id == album.userId && $1.id != album.userId }.prefix(maxVisible)
                            let overflow = participationVM.participations.count - maxVisible
                            
                            ForEach(Array(visible)) { participant in
                                ParticipantAvatarView(participant: participant, isOwner: album.userId == participant.id)
                                
                                //TODO: change the stack in button to open the modal
                                
                                //TODO: when creatipng a new album, create a relation with the status "1" between me and the album
                                
                                
                            }
                            
                            if overflow > 0 {
                                Button(action:{
                                    //TODO: open modal
                                }, label:{
                                    Circle()
                                        .customGradient()
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Text("+\(overflow)")
                                                .foregroundStyle(Color.white)
                                                .font(.system(size: 24, weight: .bold))
                                        )
                                        .padding(.horizontal, -15)
                                })
                                
                            }
                        }.padding(10)
                            .frame(maxWidth: .infinity)
                        Spacer()
                        Text(album.description ?? "")
                            .foregroundStyle(Color.white)
                            .font(Font.system(size: 16))
                            .padding(20)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color("purple_1").opacity(0.3))
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color("purple_1"), lineWidth: 1)
                            )
                        Spacer()
                        HStack{
                            if let medias = album.medias, !medias.isEmpty{
                                ForEach(medias.shuffled().prefix(4)){ media in
                                    AsyncImage(url: URL(string: media.mediaHQ)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        ProgressView()
                                            .frame(width: 30, height: 30)
                                    }
                                    .id(media.id)
                                    .frame(width: 65, height: 65)
                                    .cornerRadius(15)
                                }
                                
                            }
                            Spacer()
                            Button(action:{
                                //TODO: create action
                            }, label:{
                                Image(systemName: "chevron.right")
                                    .customGradient()
                                    .font(.system(size: 50))
                            })
                        }
                        .frame(maxWidth: .infinity)
                        .padding(15)
                        .background(Color("orange_1").opacity(0.3))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color("orange_1"), lineWidth: 1)
                        )
                        
                        if let interactions = albumVM.albumInteractions {
                            InteractionView(
                                album: album,
                                role: userRole,
                                interactions: interactions,
                                onAction: { action in
                                    switch action {
                                    case .openComments: showComments = true
                                    case .openShare: showShare = true
                                    case .openEdit: showEdit = true
                                    case .openReport: showReport = true
                                    }
                                }
                            ).environment(participationVM)
                        }
                        
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 60)
                    .frame(width: geo.size.width, height: geo.size.height)
                    
                }
                .ignoresSafeArea()
            }
            .ignoresSafeArea()
            .alert("Oops 🙃", isPresented: $showAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text(alertMessage)
            })
            
            
            
        }.task{
            do{
                try await participationVM.getParticipationsByAlbumId(albumId: album.id.uuidString)
                
                
                try await albumVM.getAlbumInteraction(id: album.id.uuidString)
            } catch let error as AppError {
                showAlert = true
                alertMessage = error.errorDescription ?? ""
            } catch {
                alertMessage = "Impossible de charger les données de l'album. Vérifie ta connexion."
                showAlert = true
            }
            
        }
    }
}

#Preview {
    AlbumDetailView(album: Album(
        id: UUID(uuidString: "0897E1C8-9708-45D0-AB98-57EB6EB73D8B")!,
        userId: UUID(uuidString: "8AAA6F2D-5053-4AED-B1DB-6B95EA149966")!,
        title: "Voyage au Japon",
        description: "Un super séjour à Tokyo et Kyoto",
        continent: "Asie",
        country: "Japon",
        town: "Tokyo",
        latitude: 35.6762,
        longitude: 139.6503,
        coverPicture: nil,
        creationDate: Date(),
        journeyStartDate: Date(),
        journeyEndDate: Date(),
        visibility: 1,
        medias: [
            Media(
                id: UUID(uuidString: "03698100-022E-4860-BC14-857621F1F37E")!,
                userId: UUID(uuidString: "8AAA6F2D-5053-4AED-B1DB-6B95EA149966")!,
                albumId: UUID(uuidString: "0897E1C8-9708-45D0-AB98-57EB6EB73D8B")!,
                date: Date(),
                location: nil,
                latitude: 63.5314,
                longitude: -19.5112,
                mediaHQ: "http://localhost:8080/uploads/AAAF3472-89EA-44E4-81B8-B03683E22298.jpg",
                lowQualityThumbnail: "http://localhost:8080/uploads/806D2662-E18B-4CE8-A2E3-A0D2F5E90473.jpg",
                note: nil
            ),
            Media(
                id: UUID(uuidString: "8AAA6F2D-5053-4AED-B1DB-6B95EA149966")!,
                userId: UUID(uuidString: "D2B38425-BAF5-4765-864F-E8A10A10CF0D")!,
                albumId: UUID(uuidString: "0897E1C8-9708-45D0-AB98-57EB6EB73D8B")!,
                date: Date(),
                location: nil,
                latitude: 37.76007833333333,
                longitude: -122.50956666666667,
                mediaHQ: "http://localhost:8080/uploads/DD0F4CE7-C0A5-4785-9BCE-5CD770460005.jpg",
                lowQualityThumbnail: "http://localhost:8080/uploads/6C972907-EF34-4135-8500-62DE735302BB.jpg",
                note: nil
            ),
            Media(
                id: UUID(uuidString: "F71FEC03-AE3E-4CF0-AEEE-97B93CB3CDFA")!,
                userId: UUID(uuidString: "8AAA6F2D-5053-4AED-B1DB-6B95EA149966")!,
                albumId: UUID(uuidString: "0897E1C8-9708-45D0-AB98-57EB6EB73D8B")!,
                date: Date(),
                location: nil,
                latitude: 38.0374445,
                longitude: -122.80317833333334,
                mediaHQ: "http://localhost:8080/uploads/ED03DBC9-34EC-4DFD-84AF-21A57326986B.jpg",
                lowQualityThumbnail: "http://localhost:8080/uploads/17582F2A-526D-481D-B012-93F7C35E794F.jpg",
                note: nil
            )
        ]
    )).environment(LoginViewModel())
        .environment(AlbumViewModel())
        .environment(ParticipationViewModel())
}

