//
//  LandingPageView.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 02/06/2026.
//

import SwiftUI
import MapKit
import _PhotosUI_SwiftUI

struct LandingPageView: View {
    
    @Environment(LoginViewModel.self) private var loginVM
    
    @State var mediaVM = MediaViewModel()
    @State var albumVM = AlbumViewModel()
    @State var mapVM = MapViewModel()
    @State private var refreshTrigger = false
    @State private var showPublicAlbums: Bool = false
    @State private var showCreateAlbum: Bool = false
    @State private var OBViewModel = OnboardingViewModel()
    @State var albumName: String = ""
    @State public var albumDescription: String = ""
    @State public var date: Date = Date()
    @State public var destinationName: String = ""
    @State public var continent: String = ""
    @State public var town: String = ""
    @State public var latitude: Double = 0.0
    @State public var longitude: Double = 0.0
    @State public var country: String = ""
    @State public var albumPictures: [PhotosPickerItem] = []
    @State public var publicAlbum: Bool = false
    
    @State private var position: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: 10.0, longitude: 10.0),
            distance: 35_000_000,
            heading: 0,
            pitch: 0
        )
    )
    
    //TODO: Pagination par coordonnées géographiques pour éviter de faire 15 000 requêtes pour les images
    var body: some View {
        NavigationStack{
            ZStack {
                Image("bg_1")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                CustomMapView(
                    albums: showPublicAlbums ? albumVM.sharedAlbums : albumVM.myAlbums,
                    
                    //TODO: check if de correct albums are displayed (I doubt it)
                    position: $position,
                    onAlbumTap: { album in
                        zoomOn(CLLocationCoordinate2D(latitude: album.latitude, longitude: album.longitude), distance: 2_000_000)
                    },
                    onClusterTap: { clusterCoordinate in
                        let currentDistance = position.camera?.distance ?? 25_000_000
                        
                        let newDistance = currentDistance / 5
                        
                        let safeDistance = max(newDistance, 2000)
                        
                        zoomOn(clusterCoordinate, distance: safeDistance)                    }
                )
                .ignoresSafeArea()
                
                VStack{
                    HStack(alignment: .center){
                        
                        NavigationLink(destination: {
                            ProfilPage().environment(loginVM)
                        }, label: {
                            CustomGradientSquareButton(image:"person.fill", muted: false)
                        })
                        Spacer()
                        HStack{
                            Button(action: {
                                if showPublicAlbums {
                                    showPublicAlbums.toggle()
                                }
                            }, label: {
                                if showPublicAlbums {
                                    Text("MY_ALBUM")
                                        .foregroundStyle(Color.white)
                                        .frame(width: 114)
                                }else{
                                    CustomGradientButton(text: "MY_ALBUM", muted: false, height: 30, width: 114)
                                }
                            })
                            Button(action: {
                                if !showPublicAlbums {
                                    showPublicAlbums.toggle()
                                }
                            }, label: {
                                if !showPublicAlbums {
                                    Text("PUBLIC_ALBUM")
                                        .foregroundStyle(Color.white)
                                        .frame(width: 114)
                                }else{
                                    CustomGradientButton(text: "PUBLIC_ALBUM", muted: false, height: 30, width: 114)
                                }
                            })
                        }.frame(width: 235)
                            .background(Color.gray.opacity(0.4))
                            .cornerRadius(10)
                        
                        Spacer()
                        
                        Button(action:{
                            showCreateAlbum = true
                        }, label: {
                            CustomGradientSquareButton(image:"plus", muted: false)
                        })
                        
                    }.frame(width: 370)
                    
                    Spacer()
                    
                    HStack{
                        
                        LocationSearchField(width: 250) { location in
                            let targetCoordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                            
                            zoomOn(targetCoordinate, distance: 1_000_000)
                        }
                        Button(action: {
                            position = .automatic
                            zoomOn(CLLocationCoordinate2D(latitude: 10.0, longitude: 10.0), distance: 35_000_000)
                            
                        }, label: {
                            GoButton(muted: false)
                        })
                        
                        
                    }
                }
            }
            .background(Color.black)
            .task {
                try? await albumVM.getCurrentUserAlbums()
                try? await albumVM.getSharedAlbums()
            }
            
            .sheet(isPresented: $showCreateAlbum) {
                VStack{
                    Text("CREATE_ALBUM")
                        .font(Font.system(size: 30, weight: .bold))
                        .customGradient()
                        .padding(.top, 20)
                    
                    //TODO: Update CreateAlbumForm to add companions if we want.
                    
                    CreateAlbumForm(albumName: $albumName, albumDescription: $albumDescription, date: $date, destinationName: $destinationName, continent: $continent, town: $town, latitude: $latitude, longitude: $longitude, country: $country, albumPictures: $albumPictures, publicAlbum: $publicAlbum)
                        .environment(OBViewModel)
                    
                    Button(action:{
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
                                    "visibility": publicAlbum ? 1 : 0,
                                ]
                            )
                            
                            var completed = 0.0
                            
                            //TODO: IMPORTANT: refacto de toute la landing
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
                            showCreateAlbum = false
                            
                            try await Task.sleep(nanoseconds: 3_000_000_000)
                            
                            try await albumVM.getCurrentUserAlbums()
                            try await albumVM.getSharedAlbums()
                            
                        }
                    }, label: {
                        if albumName != "" && destinationName != "" {
                            CustomGradientButton(text: "CREATE", muted: false, width: 150)
                        } else {
                            CustomGradientButton(text: "CREATE", muted: true, width: 150)
                                .opacity(0.5)
                        }
                    })
                }
                .background(Color.black1)
                
            }
        }
    }
    private func zoomOn(_ coordinate: CLLocationCoordinate2D, distance: CLLocationDistance) {
        withAnimation(.easeInOut(duration: 1.0)) {
            position = .camera(
                MapCamera(
                    centerCoordinate: coordinate,
                    distance: distance,
                    heading: 0,
                    pitch: 0
                )
            )
        }
    }
}

#Preview {
    LandingPageView().environment(LoginViewModel())
}

