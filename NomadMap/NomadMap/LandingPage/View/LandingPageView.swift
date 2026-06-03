//
//  LandingPageView.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 02/06/2026.
//

import SwiftUI
import MapKit

struct LandingPageView: View {
    
    @State var albumVM = AlbumViewModel()
    @State var mapVM = MapViewModel()
    @State private var refreshTrigger = false
    @State private var showPublicAlbums: Bool = false
    
    //Center the map
    @State private var position: MapCameraPosition = .camera(
        MapCamera(
            centerCoordinate: CLLocationCoordinate2D(latitude: 10.0, longitude: 10.0),
            distance: 35_000_000,
            heading: 0,
            pitch: 0
        )
    )
    
    var body: some View {
        ZStack {
            Image("bg_1")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            CustomMapView(
                albums: showPublicAlbums ? albumVM.albums.filter { $0.visibility == 1 } : albumVM.albums.filter { $0.visibility == 0 } ,
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
                    CustomGradientSquareButton(image:"person.fill", muted: false)
                    Spacer()
                    HStack{
                        Button(action: {
                        if showPublicAlbums {
                            showPublicAlbums.toggle()
                            }
                        }, label: {
                            if showPublicAlbums {
                                Text("PRIVATE_ALBUM")
                                    .foregroundStyle(Color.white)
                                    .frame(width: 114)
                            }else{
                                CustomGradientButton(text: "PRIVATE_ALBUM", muted: false, height: 30, width: 114)
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
                    
                    
                    CustomGradientSquareButton(image:"plus", muted: false)
                    
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
        .onAppear {
            Task {
                try? await albumVM.getCurrentUserAlbums()
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

