//
//  VisibilityComponent.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 30/06/2026.
//

import SwiftUI

struct VisibilityComponent: View {
    var isPublic: Bool
    var body: some View {
        HStack{
            Image(systemName: isPublic ? "eye" : "eye.slash")
                .foregroundStyle(isPublic ? Color("red_1") : Color("purple_1"))
                .padding(.leading, 10)
                .padding(.vertical, 10)
            
            Text(isPublic ? "PUBLIC_ALBUM" : "PRIVATE_ALBUM")
                .font(Font.system(size: 16, weight: .bold))
                .foregroundStyle(Color.white)
                .padding(.trailing, 10)
        } .background(isPublic ? Color("red_1").opacity(0.3) : Color("purple_1").opacity(0.3))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isPublic ? Color("red_1") : Color("purple_1"), lineWidth: 1)
            )

        


    }
}

#Preview {
    VisibilityComponent(isPublic: false)
}
