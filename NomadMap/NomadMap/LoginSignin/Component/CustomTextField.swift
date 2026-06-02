//
//  SecureTextField.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 27/04/2026.
//

import SwiftUI

struct CustomTextField: View {
    var label: LocalizedStringKey
    var placeholder: LocalizedStringKey
    var binding: Binding<String>
    var secure: Bool
    var isHeightFixed: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("black_1").opacity(0.5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color("red_1"), Color("orange_1")]),
                                    startPoint: .bottomTrailing,
                                    endPoint: .topLeading
                                ),
                                lineWidth: 2
                            )
                    )

                // Placeholder
                if binding.wrappedValue.isEmpty {
                    Text(placeholder)
                        .foregroundStyle(Color.gray.opacity(0.5))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 15)
                }

                // Input
                Group {
                    if secure {
                        SecureField("", text: binding)
                    } else if !isHeightFixed {
                        TextField("", text: binding, axis: .vertical)
                            .lineLimit(1...6)
                    } else {
                        TextField("", text: binding)
                    }
                }
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 10)
                .padding(.vertical, 15)
                .foregroundStyle(.white)
                .autocorrectionDisabled()
                .keyboardType(.default)
            }
            .frame(minHeight: 50, maxHeight: isHeightFixed ? 50 : 300)
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 40)
    }
}
