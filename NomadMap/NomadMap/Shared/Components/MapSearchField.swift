//
//  LocationSearchField.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 13/05/2026.
//


import SwiftUI
import MapKit

struct MapSearchField: View {
    var width: CGFloat?
    @State private var vm = LocationSearchViewModel()
    @Environment(AlbumViewModel.self) private var albumVM
    
    var onLocationSelected: (SelectedLocation) -> Void
    var onAlbumSelected: (Album) -> Void
    
    private var albumResults: (myAlbums: [Album], publicAlbums: [Album]) {
        albumVM.searchAlbums(query: vm.searchText)
    }
    
    private var hasResults: Bool {
        !vm.suggestions.isEmpty || !albumResults.myAlbums.isEmpty || !albumResults.publicAlbums.isEmpty
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .customGradient()
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
            .frame(width: width, alignment: .center)
            .frame(maxWidth: width == nil ? .infinity : nil)
            .cornerRadius(10)
            
            // Résultats
            if hasResults && !vm.searchText.isEmpty {
                ScrollView {
                    VStack(spacing: 0) {
                        
                        if !vm.suggestions.isEmpty {
                            SectionHeader(title: "LIEUX", icon: "location.fill")
                            ForEach(vm.suggestions.prefix(5), id: \.self) { suggestion in
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
                                            .foregroundStyle(.white)
                                            .font(.system(size: 14, weight: .medium))
                                        if !suggestion.subtitle.isEmpty {
                                            Text(suggestion.subtitle)
                                                .foregroundStyle(Color.gray)
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
                        
                        if !albumResults.myAlbums.isEmpty {
                            SectionHeader(title: "MES ALBUMS", icon: "book.fill")
                            ForEach(albumResults.myAlbums.prefix(5)) { album in
                                Button {
                                    onAlbumSelected(album)
                                    vm.searchText = ""
                                } label: {
                                    AlbumSearchRow(album: album, isPublic: false)
                                }
                                if album != albumResults.myAlbums.last {
                                    Divider().background(Color.gray.opacity(0.3))
                                }
                            }
                        }
                        
                        if !albumResults.publicAlbums.isEmpty {
                            SectionHeader(title: "ALBUMS PUBLICS", icon: "globe")
                            ForEach(albumResults.publicAlbums.prefix(5)) { album in
                                Button {
                                    onAlbumSelected(album)
                                    vm.searchText = ""
                                } label: {
                                    AlbumSearchRow(album: album, isPublic: true)
                                }
                                if album != albumResults.publicAlbums.last {
                                    Divider().background(Color.gray.opacity(0.3))
                                }
                            }
                        }
                    }
                    .background(Color("black_1"))
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.5), radius: 10)
                }
                .frame(width: width, alignment: .center)
                .frame(maxWidth: width == nil ? .infinity : nil)
                .frame(maxHeight: 350)
            }
        }
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .customGradient()
            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.gray)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color("black_1").opacity(0.8))
    }
}

struct AlbumSearchRow: View {
    let album: Album
    let isPublic: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            AsyncImage(url: URL(string: album.coverPicture ?? album.medias?.first?.mediaHQ ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.3)
            }
            .frame(width: 40, height: 40)
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(album.title)
                    .foregroundStyle(.white)
                    .font(.system(size: 14, weight: .medium))
                Text((album.town ?? album.country) ?? album.continent ?? "")
                    .foregroundStyle(Color.gray)
                    .font(.system(size: 12))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}
