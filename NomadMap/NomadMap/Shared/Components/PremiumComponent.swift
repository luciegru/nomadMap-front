//
//  PremiumComponent.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 02/06/2026.
//

import SwiftUI

struct PremiumComponent: View {
    var body: some View {
        ZStack(alignment: .leading){
            RoundedRectangle(cornerRadius: 20)
                .customGradient()
                .opacity(0.3)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(
                            LinearGradient(
                                gradient: Gradient(colors: [Color("red_1"), Color("orange_1")]),
                                startPoint: .bottomTrailing,
                                endPoint: .topLeading
                            ),
                            lineWidth: 2
                        )
                )
                .frame(width: 340, height: 280)
            VStack(alignment:.leading){
                HStack{
                    Text("PREMIUM")
                        .font(Font.system(size: 22, weight: .bold))
                        .foregroundStyle(Color.white)
                    Spacer()

                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundStyle(Color("red_1"))
                            .opacity(0.4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(
                                        Color("red_1"),
                                        lineWidth: 1
                                    )
                            )
                            .frame(width: 150, height: 26)
                        
                        Text("BEST_CHOICE")
                            .foregroundStyle(Color.white)
                    }
                    
                }
                Spacer()
                
                Text("UNLOCK_ADVANTAGES")
                    .foregroundStyle(Color.white)
                
                Spacer()
                
                Text("✅ \(String(localized: "UNLIMITED_STORAGE"))")
                    .foregroundStyle(Color.white)
                    .padding(.vertical, 2)
                Text("✅ \(String(localized: "NO_ADS"))")
                    .foregroundStyle(Color.white)
                    .padding(.vertical, 2)
                
                Text("✅ \(String(localized: "PRIORITY_SUPPORT"))")
                    .foregroundStyle(Color.white)
                    .padding(.vertical, 2)
                
                Text("✅ \(String(localized: "DISCOUNTS_AND_OFFERS"))")
                    .foregroundStyle(Color.white)
                    .padding(.vertical, 2)
                
                Spacer()
                
                HStack{
                    Text("PREMIUM_PRICE")
                        .foregroundStyle(Color.white)
                    
                    Button(action: {},label: {
                        CustomGradientButton(text: "GO_TO_PREMIUM", muted: false)                    })
                }
                
                
                
            }.frame(width: 300, height: 240)
                .padding(.leading, 15)
        }
        
        
    }
}

#Preview {
    PremiumComponent()
}
