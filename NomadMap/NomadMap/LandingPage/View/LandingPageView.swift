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
    
    @State var albumVM = AlbumViewModel()
    @State var participationVM = ParticipationViewModel()
    @State private var OBViewModel = OnboardingViewModel()
    @State private var createAlbumVM = CreateAlbumViewModel()
    @State private var showPublicAlbums: Bool = false
    @State private var showCreateAlbum: Bool = false
    @State private var selectedAlbum: Album? = nil
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
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
                    
                    position: $position,
                    onAlbumTap: { album in
                        zoomOn(CLLocationCoordinate2D(latitude: album.latitude, longitude: album.longitude), distance: 2_000_000)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.selectedAlbum = album
                        }
                    },
                    onClusterTap: { clusterCoordinate in
                        let currentDistance = position.camera?.distance ?? 25_000_000
                        
                        let newDistance = currentDistance / 5
                        
                        let safeDistance = max(newDistance, 2000)
                        
                        zoomOn(clusterCoordinate, distance: safeDistance)
                    })
                .ignoresSafeArea()
                
                VStack{
                    MapTopBarView(
                        showPublicAlbums: $showPublicAlbums,
                        onCreateAlbum: { showCreateAlbum = true }
                    )
                    .environment(loginVM)
                    .environment(albumVM)
                    
                    Spacer()
                    
                    MapBottomBarView(
                        onSearch: { coordinate in
                            zoomOn(coordinate, distance: 1_000_000)
                        },
                        onReset: {
                            position = .automatic
                            zoomOn(CLLocationCoordinate2D(latitude: 10.0, longitude: 10.0), distance: 35_000_000)
                        },
                        onAlbumSelected: { album in
                            selectedAlbum = album
                        }
                    )
                    .environment(albumVM)
                }
            }
            .alert("Oops 🙃", isPresented: $showAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text(alertMessage)
            })
            .background(Color.black)
            .task {
                do{
                    try await albumVM.getCurrentUserAlbums()
                    try await albumVM.getSharedAlbums()
                } catch let error as AppError {
                    showAlert = true
                    alertMessage = error.errorDescription ?? ""
                } catch {
                    alertMessage = "Impossible de charger les données de l'album. Vérifie ta connexion."
                    showAlert = true
                }
                
            }
            .navigationDestination(item: $selectedAlbum) { album in
                AlbumDetailView(album: album)
                    .environment(loginVM)
                    .environment(albumVM)
                    .environment(participationVM)
            }
            
            .sheet(isPresented: $showCreateAlbum) {
                CreateAlbumSheet(
                    createAlbumVM: createAlbumVM,
                    showCreateAlbum: $showCreateAlbum,
                    showAlert: $showAlert,
                    alertMessage: $alertMessage
                )
                .environment(loginVM)
                .environment(albumVM)
                .environment(OBViewModel)
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

