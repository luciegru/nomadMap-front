//
//  CreateAlbumForm.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 04/06/2026.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct CreateAlbumForm: View {
    
    @Binding var albumName: String
    @Binding var albumDescription: String
    @Binding var date: Date
    @Binding var destinationName: String
    @Binding var continent: String
    @Binding var town: String
    @Binding var latitude: Double
    @Binding var longitude: Double
    @Binding var country: String
    @Binding var albumPictures: [PhotosPickerItem]
    @Binding var publicAlbum: Bool
    
    @Environment(OnboardingViewModel.self) private var OBVM
    @Environment(AlbumViewModel.self) private var albumVM

    
    var body: some View {
        ScrollView {
            VStack(spacing: 15){
                
                CustomTextField(label: "ALBUM_NAME", placeholder: "PLACEHOLDER_ALBUM_NAME", binding: $albumName, secure: false, isHeightFixed: true)
                
                Spacer()
                VStack{
                    CustomTextField(label: "ALBUM_DESCRIPTION", placeholder: "PLACEHOLDER_ALBUM_DESCRIPTION", binding: $albumDescription, secure: false, isHeightFixed: false)
                        .onChange(of: albumDescription) { _, newValue in
                            if newValue.count > 500 {
                                albumDescription = String(newValue.prefix(500))
                            }
                        }
                    HStack{
                        Spacer()
                        Text("\(albumDescription.count)/500")
                            .foregroundStyle(Color.gray)
                            .padding(.trailing, 40)
                    }
                }
                Spacer()
                DatePicker("SELECT_DATE", selection: $date, displayedComponents: .date)
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 40)
                    .colorScheme(.dark)
                    .accentColor(Color("red_1"))
                Spacer()
                VStack{
                    HStack{
                        Text("ALBUM_LOCATION")
                            .foregroundStyle(Color.white)
                        Spacer()
                    }.padding(.leading, 40)
                    
                    MapSearchField(onLocationSelected: { location in
                        self.destinationName = location.name
                        self.town = location.town ?? ""
                        self.continent = location.continent ?? ""
                        self.country = location.country ?? ""
                        self.latitude = location.latitude
                        self.longitude = location.longitude
                    }, onAlbumSelected: { _ in }).environment(albumVM)
                    .padding(.horizontal, 40)
                }
                
            }.padding(.vertical, 40)
            
            PhotosPicker(selection: $albumPictures, maxSelectionCount: 30) {
                
                ZStack{
                    RoundedRectangle(cornerRadius: 20)
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
                        .frame(width: 320, height: 200)
                        .foregroundStyle(Color("orange_1").opacity(0.1))
                        .shadow(radius: 10)
                    
                    
                    VStack{
                        Image(systemName: "square.and.arrow.down")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .customGradient()
                            .padding(.bottom, 10)
                        Text("ADD_IMAGES")
                            .foregroundStyle(Color.white)
                            .padding(.bottom, 10)
                        Text("ADD_IMAGES_DESCRIPTIONS")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.gray)
                            .frame(maxWidth: 290)
                    }
                }
            }
            .onChange(of: albumPictures) { oldValue, newValue in
                OBVM.loadAlbumImages(from: newValue)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 4), spacing: 10){
                
                ForEach(OBVM.albumImages) { albumImage in
                    albumImage.image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipped()
                        .cornerRadius(10)
                }
            }                                        .padding(.horizontal, 40)
                .padding(.vertical, 10)
            
            HStack{
                Button(action:{
                    if(!publicAlbum){
                        publicAlbum.toggle()
                    }
                }, label:{
                    CustomGradientButton(text: "PUBLIC_ALBUM", muted: publicAlbum ? false : true)
                }
                )
                Button(action:{
                    if(publicAlbum){
                        publicAlbum.toggle()
                    }
                }, label:{
                    CustomGradientButton(text: "PRIVATE_ALBUM", muted: publicAlbum ? true : false)
                }
                )
            }.padding(.horizontal, 40)
            
        } .padding(.bottom, 20)
    }
}

//#Preview {
//    CreateAlbumForm()
//}
