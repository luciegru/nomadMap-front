//
//  MapTopBarView.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 03/07/2026.
//

import SwiftUI

struct MapTopBarView: View {
    
    @Environment(LoginViewModel.self) private var loginVM
    @Environment(AlbumViewModel.self) private var albumVM
    
    @Binding var showPublicAlbums: Bool
    var onCreateAlbum: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            NavigationLink(destination: {
                ProfilPage().environment(loginVM).environment(albumVM)
            }, label: {
                CustomGradientSquareButton(image: "person.fill", muted: false)
            })
            
            Spacer()
            
            HStack {
                Button(action: {
                    if showPublicAlbums { showPublicAlbums.toggle() }
                }, label: {
                    if showPublicAlbums {
                        Text("MY_ALBUM")
                            .foregroundStyle(Color.white)
                            .frame(width: 114)
                    } else {
                        CustomGradientButton(text: "MY_ALBUM", muted: false, height: 30, width: 114)
                    }
                })
                Button(action: {
                    if !showPublicAlbums { showPublicAlbums.toggle() }
                }, label: {
                    if !showPublicAlbums {
                        Text("PUBLIC_ALBUM")
                            .foregroundStyle(Color.white)
                            .frame(width: 114)
                    } else {
                        CustomGradientButton(text: "PUBLIC_ALBUM", muted: false, height: 30, width: 114)
                    }
                })
            }
            .frame(width: 235)
            .background(Color.gray.opacity(0.4))
            .cornerRadius(10)
            
            Spacer()
            
            Button(action: onCreateAlbum, label: {
                CustomGradientSquareButton(image: "plus", muted: false)
            })
        }
        .frame(width: 370)
    }
}
