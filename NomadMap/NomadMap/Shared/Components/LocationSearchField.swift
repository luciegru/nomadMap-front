//
//  LocationSearchField.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 13/05/2026.
//


import SwiftUI
import MapKit

struct LocationSearchField: View {
    @State private var vm = LocationSearchViewModel()
    var onLocationSelected: (SelectedLocation) -> Void
    
    var body: some View {
        VStack(spacing: 0) {

            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.gray)
                TextField("", text: $vm.searchText)
                    .foregroundStyle(.gray)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                if !vm.searchText.isEmpty {
                    Button {
                        vm.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.gray)
                    }
                }
            }
            .padding(12)
            .background(Color("black_1").opacity(0.5))
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
            .cornerRadius(10)
            
            if !vm.suggestions.isEmpty {
                ScrollView{
                    VStack(spacing: 0) {
                        ForEach(vm.suggestions, id: \.self) { suggestion in
                            Button {
                                Task {
                                    await vm.selectLocation(suggestion)
                                    if let location = vm.selectedLocation {
                                        onLocationSelected(location)
                                    }
                                }
                            } label: {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(suggestion.title)
                                        .foregroundStyle(.gray)
                                        .font(.system(size: 14, weight: .medium))
                                    if !suggestion.subtitle.isEmpty {
                                        Text(suggestion.subtitle)
                                            .foregroundStyle(Color.gray.opacity(0.5))
                                            .font(.system(size: 12))
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                            }
                            
                            if suggestion != vm.suggestions.last {
                                Divider().background(Color.gray.opacity(0.3))
                            }
                        }
                    }
                    .background(Color("black_1"))
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.5), radius: 10)
                }.frame(maxHeight: 300)
            }
        }
        .padding(.horizontal, 40)
    }
}

#Preview {
    LocationSearchField { location in
    }
}
