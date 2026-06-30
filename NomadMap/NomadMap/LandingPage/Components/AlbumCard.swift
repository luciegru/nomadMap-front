//
//  AlbumCard.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 03/06/2026.
//

import SwiftUI

struct AlbumCard: View {
    @State var album: Album

    var body: some View {
        ZStack{
            AsyncImage(url: URL(string: album.coverPicture ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .background(Color.black)
                    .opacity(0.5)
                    .frame(width: 110, height: 100)
            } placeholder: {
                ProgressView()
                    .frame(width: 110, height: 100)
            }.frame(width: 110, height: 100)
                .id(album.coverPicture)            
            VStack(alignment: .leading){
                HStack(alignment: .center){
                    Text(album.town ?? (album.country ?? (album.continent ?? "")))
                        .foregroundStyle(Color.white)
                        .font(Font.system(size: 11, weight: .bold))
                    Spacer()
                    Text(album.journeyStartDate.formatted(.dateTime.day(.twoDigits).month(.twoDigits).year(.defaultDigits)))
                        .font(Font.system(size: 9))
                        .foregroundStyle(Color.white)
                }.padding(.horizontal, 5)
                    .padding(.top, 15)

                
                Text(album.title)
                    .font(Font.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 5)
                
                Spacer()
                

            }
        }.frame(width: 110, height: 100)
            .glassEffect(
                .clear.tint(Color.black.opacity(0.19)).interactive(),
                in: CustomCardShape()
            )
            .clipShape(CustomCardShape())
            .overlay(
                CustomCardShape()
                    .stroke(
                        Color(album.visibility == 1 ? "purple_1" : "green_1"),
                        lineWidth: 2
                    )
                )
            .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        
    }
}

#Preview {
    AlbumCard(album: Album(
        id: UUID(),
        userId: UUID(),
        title: "Mon super voyage dans les îles",
        town: "Paris",
        latitude: 0.4,
        longitude: 0.4,
        coverPicture: "bg_1",
        creationDate: Date(),
        journeyStartDate: Date(),
        journeyEndDate: Date(),
        visibility: 1
    ))
}
