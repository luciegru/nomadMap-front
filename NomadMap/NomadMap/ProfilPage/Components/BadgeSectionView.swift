//
//  BadgeSectionView.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 29/06/2026.
//

import SwiftUI

struct BadgeSectionView: View {
    
    @Environment(BadgeViewModel.self) private var badgeVM

    var body: some View {
        VStack{
            HStack{
                Text("🏆")
                Text("BADGES")
                    .foregroundStyle(Color.white)
                    .font(Font.system(size: 24))
                Spacer()
                HStack{
                    Text("\(badgeVM.myBadges.count)/\(badgeVM.allBadges.count)")
                        .foregroundStyle(Color.white)
                        .font(Font.system(size: 18))
                        .padding(.horizontal, 15)
                        .padding(.vertical, 2)
                }.background(Color("red_1").opacity(0.2))
                    .cornerRadius(5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color("red_1"), lineWidth: 1)
                    )
                
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(badgeVM.allBadges, id: \.id) { badge in
                        let isUnlocked = badgeVM.myBadges.contains(where: { $0.id == badge.id })
                        
                        BadgeItemView(badgePicture: badge.picture, isUnlocked: isUnlocked)
                            .id(badge.id)
                    }
                }
            }
            
        }
    }
}

//#Preview {
//    BadgeSectionView()
//}
