//
//  OnBoarding4.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 13/05/2026.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct OnBoarding4: View {
    @State private var isVisible = false
    @State private var albumName: String = ""
    @State private var albumDescription: String = ""
    @State private var date: Date = Date()
    @State private var destinationName: String = ""
    @State private var continent: String = ""
    @State private var town: String = ""
    @State private var latitude: Double = 0.0
    @State private var longitude: Double = 0.0
    @State private var country: String = ""
    @State private var albumPictures: [PhotosPickerItem] = []
    @State private var OBViewModel = OnboardingViewModel()
    @State private var albumVM = AlbumViewModel(loginVM: LoginViewModel())
    @Environment(LoginViewModel.self) private var loginVM
    @State private var mediaVM = MediaViewModel(loginVM: LoginViewModel())
    @State private var publicAlbum: Bool = true
    @State private var navigate: Bool = false
    @State private var uploadProgress: Double = 0
    @State private var isUploading: Bool = false
    
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack{
                    Ellipse()
                        .customGradient()
                        .frame(width: 250, height: 100)
                        .blur(radius: 50)
                        .opacity(0.6)
                    
                    VStack{
                        if isVisible {
                            
                            Text("LETS_START")
                                .font(.largeTitle)
                                .bold()
                                .customGradient()
                                .padding(.horizontal, 30)
                            
                                .transition(.move(edge: .leading).combined(with: .opacity))
                            
                        }
                        
                        Spacer()
                        
                        Text("CREATE_FIRST_ALBUM")
                            .foregroundStyle(Color.gray)
                        
                        Spacer()
                        
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
                                    
                                    LocationSearchField { location in
                                        self.destinationName = location.name
                                        self.town = location.town ?? ""
                                        self.continent = location.continent ?? ""
                                        self.country = location.country ?? ""
                                        self.latitude = location.latitude
                                        self.longitude = location.longitude
                                    }.padding(.horizontal, 40)
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
                                OBViewModel.loadAlbumImages(from: newValue)
                            }
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 4), spacing: 10){
                                
                                ForEach(OBViewModel.albumImages) { albumImage in
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
                        
                        
                        HStack{
                            
                            NavigationLink(destination: {
                                OnBoarding5().environment(loginVM)
                            }, label: {
                                Text("SKIP")
                                    .font(.system(size: 20))
                                    .bold()
                                    .foregroundStyle(Color.gray)
                                    .padding(.leading, 40)
                            })
                            
                            if isUploading {
                                VStack {
                                    ProgressView(value: uploadProgress)
                                        .progressViewStyle(.linear)
                                        .padding(.horizontal, 40)
                                    Text("\(Int(uploadProgress * 100))%")
                                        .foregroundStyle(.white)
                                }
                            }
                            
                            
                            Spacer()
                            if albumName != "" && destinationName != "" {
                                
                                Button(action: {
                                    Task{
                                        
                                        try await albumVM.createAlbum(
                                            with: [
                                                "userId":loginVM.currentUser?.id.uuidString ?? UUID().uuidString,
                                                "title": albumName,
                                                "description": albumDescription,
                                                "continent": continent,
                                                "country": country,
                                                "town": town,
                                                "latitude": latitude,
                                                "longitude": longitude,
                                                "journeyStartDate": ISO8601DateFormatter().string(from: date),
                                                "visibility": publicAlbum ? 1 : 0
                                            ]
                                        )
                                        
                                        isUploading = true
                                        uploadProgress = 0
                                        let total = Double(albumPictures.count)
                                        var completed = 0.0
                                        
                                        
                                        await withTaskGroup(of: Void.self) { group in
                                            let maxConcurrentUploads = 3
                                            var activeUploads = 0
                                            
                                            for media in albumPictures {
                                                if activeUploads >= maxConcurrentUploads {
                                                    await group.next()
                                                    activeUploads -= 1
                                                }
                                                
                                                activeUploads += 1
                                                group.addTask {
                                                    do {
                                                        let metadata = await UploadService.getMetadata(from: media)
                                                        
                                                        let finalHdUrl = try await UploadService.uploadImage(media)
                                                        
                                                        let finalThumbnailUrl = try await UploadService.uploadThumbnail(media)
                                                        
                                                        try await mediaVM.createMedia(with: [
                                                            "userId": loginVM.currentUser?.id.uuidString ??  UUID().uuidString,
                                                            "albumId": albumVM.lastCreatedAlbum?.id.uuidString ?? "",
                                                            "latitude": metadata.latitude ?? 0.0,
                                                            "longitude": metadata.longitude ?? 0.0,
                                                            "mediaHQ": finalHdUrl,
                                                            "lowQualityThumbnail": finalThumbnailUrl,
                                                            "size": metadata.fileSize ?? 0
                                                        ])
                                                        
                                                        await MainActor.run {
                                                            completed += 1
                                                            uploadProgress = completed / total
                                                        }
                                                        
                                                    } catch {
                                                    }
                                                }
                                            }
                                            while activeUploads > 0 {
                                                await group.next()
                                                activeUploads -= 1
                                            }
                                        }
                                        
                                        try await loginVM.getCurrentUser()
                                        
                                        isUploading = false
                                        
                                        navigate = true
                                        
                                    }
                                    
                                }, label: {
                                    GoButton(muted:false)
                                })
                            } else {
                                GoButton(muted:true)
                            }
                            
                        }.padding(.bottom, 60)
                            .padding(.trailing, 30)
                        
                    }.padding(.top, 100)
                }}
            .navigationDestination(isPresented: $navigate) {
                OnBoarding5()
            }
            
            .onAppear {
                withAnimation(.spring(bounce: 0.5)) {
                    isVisible = true
                }
                
            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea()
            
            
        }.navigationBarBackButtonHidden()
    }
}

#Preview {
    OnBoarding4().environment(LoginViewModel())
}
