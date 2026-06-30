//
//  ClusterCard.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 03/06/2026.
//

import SwiftUI

struct ClusterCard: View {
    @State var count: Int
    
    var body: some View {
        ZStack{
            CustomCardShape()
                .glassEffect(
                    .clear.tint(Color.black.opacity(0.3)).interactive(),
                    in: CustomCardShape()
                )
            VStack(alignment: .leading){
                Text(String(count) + " +")
                    .foregroundStyle(Color.white)
                    .font(Font.title.bold())
                    .padding(.top, 5)
                Spacer()
            }.padding(.horizontal, 5)
            
            
        }.frame(width: 80, height: 70)
            .clipShape(CustomCardShape())
            .overlay(
                CustomCardShape()
                    .stroke(
                        Color("red_1"),
                        lineWidth: 2
                    )
            )
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        
    }
}

#Preview {
    ClusterCard(count: 38)
}
