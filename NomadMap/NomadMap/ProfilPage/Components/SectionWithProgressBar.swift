//
//  SectionWithProgressBar.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 29/06/2026.
//

import SwiftUI

struct SectionWithProgressBar: View {
    var title: LocalizedStringKey
    var currentIntText: String
    var subtitleText: String
    var color: String
    var target: String?
    var maxValue: Int
    var currentValue: Int
    
    
    
    var body: some View {
        VStack{
            HStack{
                Text(title)
                    .font(Font.system(size: 24))
                    .foregroundStyle(Color.white)
                Spacer()
                Text(currentIntText)
                    .font(Font.system(size: 18))
                    .foregroundStyle(Color.white)
                
                
            }.padding(.top, 10)
                .padding(.horizontal, 15)
            
            HStack{
                Text(subtitleText)
                    .font(Font.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(color))
                
                Spacer()
                Text(target ?? "")
                    .font(Font.system(size: 16))
                    .foregroundStyle(Color.white)
                
            }.padding(.horizontal, 15)
            
            ProgressBar(maxValue: maxValue, current: currentValue, width: 325)
                .padding(.top, 15)
                .padding(.bottom, 10)
        }.background(Color(color).opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(color), lineWidth: 1)
            )
            .padding(.vertical, 25)
    }
}

//#Preview {
//    SectionWithProgressBar()
//}
