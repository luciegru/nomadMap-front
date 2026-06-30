//
//  BadgeItemView.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 29/06/2026.
//

import SwiftUI

struct BadgeItemView: View {
    let badgePicture: String
    let isUnlocked: Bool
    
    var body: some View {
        AsyncImage(url: URL(string: badgePicture)) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: 110, height: 100)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 110, height: 100)
                    .opacity(isUnlocked ? 1.0 : 0.1)
            case .failure:
                Image(systemName: "photo.badge.exclamationmark")
                    .foregroundColor(.gray)
                    .frame(width: 110, height: 100)
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: 110, height: 100)
        .clipped()
    }
}


//#Preview {
//    BadgeItemView()
//}
