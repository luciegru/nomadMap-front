//
//  InteractionView.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 01/07/2026.
//

import SwiftUI

struct InteractionView: View {
    
    let album: Album
    let role: UserRole
    let interactions: Interaction
    var onAction: (AlbumInteraction) -> Void
    
    @State private var isSaved: Bool = false
    @State private var likesCount: Int = 0
    @State private var savesCount: Int = 0
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    @Environment(ParticipationViewModel.self) private var participationVM
    
    var body: some View {
        HStack(spacing: 0) {
            
            if role == .viewer {
                InteractionButton(
                    icon: "heart",
                    color: "red_1",
                    count: nil,
                    isActive: participationVM.isLiked,
                    action: {
                        Task{
                            try? await participationVM.toggleLike(albumId: album.id.uuidString)
                            likesCount += participationVM.isLiked ? 1 : -1
                            
                        }
                    }
                )
            } else {
                InteractionButton(
                    icon: "heart",
                    color: "red_1",
                    count: likesCount,
                    isActive: false,
                    action: nil
                )
            }
            
            Spacer()
            
            InteractionButton(
                icon: "bubble.left",
                color: "green_1",
                count: role == .viewer ? nil : interactions.comments.count,
                isActive: false,
                action: { onAction(.openComments) }
            )
            
            Spacer()
            
            InteractionButton(
                icon: "arrowshape.turn.up.right",
                color: "orange_1",
                count: nil,
                isActive: false,
                action: { onAction(.openShare) }
            )
            
            Spacer()
            
            if role == .viewer {
                InteractionButton(
                    icon: "bookmark",
                    color: "purple_1",
                    count: nil,
                    isActive: isSaved,
                    action: { isSaved.toggle() }
                )
            } else {
                InteractionButton(
                    icon: "bookmark",
                    color: "purple_1",
                    count: savesCount,
                    isActive: false,
                    action: nil
                )
            }
            
            Spacer()
            
            if role == .owner {
                InteractionButton(
                    icon: "pencil",
                    color: "red_1",
                    count: nil,
                    isActive: false,
                    action: { onAction(.openEdit) }
                )
            } else if role == .viewer {
                InteractionButton(
                    icon: "exclamationmark.triangle.fill",
                    color: "red_1",
                    count: nil,
                    isActive: false,
                    action: { onAction(.openReport) }
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
        .background(Color("black_1").opacity(0.6))
        .cornerRadius(20)
        .onAppear {
            isSaved = interactions.isSaved
            
            savesCount = interactions.saves.count
        }
        .task {
            do{
            try? await participationVM.getLikeStatus(albumId: album.id.uuidString)
            likesCount = interactions.likes.count
            } catch let error as AppError {
                            showAlert = true
                            alertMessage = error.errorDescription ?? ""
                        } catch {
                            alertMessage = "Impossible de charger les données de l'album. Vérifie ta connexion."
                            showAlert = true
                        }
                        
        }
        .alert("Oops 🙃", isPresented: $showAlert, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(alertMessage)
        })

    }
}

//#Preview {
//    InteractionView()
//}
