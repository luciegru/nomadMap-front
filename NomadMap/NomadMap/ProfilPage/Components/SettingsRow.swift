//
//  SettingRow.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 29/06/2026.
//

import SwiftUI

struct SettingsRow: View {
    let icon: String
    let color: String
    let title: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundStyle(Color(color))
                .frame(width: 32, height: 32)
                .background(Color(color).opacity(0.2))
                .cornerRadius(20)
            Text(title)
                .foregroundStyle(.white)
                .font(.system(size: 17))
            Spacer()
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
    }
}

//#Preview {
//    SettingsRow()
//}
