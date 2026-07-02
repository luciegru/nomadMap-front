//
//  ParticipantAvatarView.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 01/07/2026.
//

import SwiftUI

struct ParticipantAvatarView: View {
    let participant: User
    let isOwner: Bool
    
    var body: some View {
        Group {
            if let picture = participant.profilPicture, !picture.isEmpty {
                AsyncImage(url: URL(string: picture)) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    ProgressView()
                }
            } else {
                let number = participant.id.uuidString.utf8.reduce(0) { $0 + Int($1) }
                Image("avatar_\(number % 5 + 1)")
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(Circle())
        .overlay(
            Circle().stroke(isOwner ? Color("red_1") : Color("green_1"), lineWidth: isOwner ? 3 : 1)
        )
        .padding(.horizontal, -10)
    }
}
