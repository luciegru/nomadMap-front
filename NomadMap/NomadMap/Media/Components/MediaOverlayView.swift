//
//  MediaOverlayView.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 01/09/2026.
//


import SwiftUI

struct MediaOverlayView: View {
    let media: Media
    let role: UserRole
    let owner: User
    let likesCount: Int
    let isLiked: Bool
    
    var onAction: (MediaInteraction) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            
            HStack {
                Spacer()
                
                HStack() {
                    
                    Spacer()
                    
                    InteractionButton(
                        icon: "heart",
                        color: "red_1",
                        count: likesCount,
                        isActive: isLiked,
                        action: { onAction(.like) }
                    )
                    
                    Spacer()
                    
                    InteractionButton(
                        icon: "bubble.left",
                        color: "green_1",
                        count: nil,
                        isActive: false,
                        action: { onAction(.comment) }
                    )
                    
                    Spacer()
                    
                    InteractionButton(
                        icon: "arrowshape.turn.up.right",
                        color: "orange_1",
                        count: nil,
                        isActive: false,
                        action: { onAction(.share) }
                    )
                    
                    if role == .viewer {
                        
                        Spacer()
                        InteractionButton(
                            icon: "flag",
                            color: "purple_1",
                            count: nil,
                            isActive: false,
                            action: { onAction(.report) }
                        )
                    } else if role == .owner {
                        Spacer()
                        InteractionButton(icon: "trash", color: "red_1", count: nil, isActive: false, action: { onAction(.delete) })
                        
                        Spacer()
                        InteractionButton(icon: "pencil", color: "purple_1", count: nil, isActive: false, action: {
                            onAction(.update)
                        })
                    }
                    
                    Spacer()
                }
            }
            
            HStack(spacing: 10) {
                
                AsyncImage(url: URL(string: owner.profilPicture ?? "")){
                    image in
                    
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 1))
                    
                }placeholder: {
                    ProgressView()
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("@\(owner.userName)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text(media.date.formatted(date: .numeric, time: .omitted))
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            
            if let note = media.note, !note.isEmpty {
                Text(note)
                    .font(.system(size: 13))
                    .foregroundStyle(.white)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 10)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 30)
        .background(
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

enum MediaInteraction {
    case like, comment, share, report, delete, update
}
