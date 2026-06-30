//
//  DashboardCards.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 29/06/2026.
//

import SwiftUI

struct DashboardCards: View {
    var imageName: String
    var stat: Int
    var label: LocalizedStringKey
    
    var body: some View {
        VStack{
            Image(systemName: imageName)
                .foregroundStyle(Color("green_1"))
                .font(Font.system(size: 32, weight: .bold))
                .padding(.top, 15)
                .padding(.horizontal, 35)
            Text(String(stat))
                .foregroundStyle(Color("green_1"))
                .font(Font.system(size: 32, weight: .bold))
                .padding(.vertical, 5)
            Text(label)
                .foregroundStyle(Color.white)
                .font(Font.system(size: 18))
                .padding(.bottom, 15)
            
            
        }.background(Color("green_1").opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("green_1"), lineWidth: 1)
            )
            .padding(.vertical, 25)
    }
}

//#Preview {
//    DashboardCards()
//}
