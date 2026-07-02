//
//  ProfilPage.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 05/06/2026.
//

import SwiftUI
import UIKit

struct ProfilPage: View {
    
    @Environment(LoginViewModel.self) private var loginVM
    @Environment(AlbumViewModel.self) private var albumVM
    @State var badgeVM = BadgeViewModel()
    @State var levelVM = LevelViewModel()
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                AsyncImage(url: URL(string: loginVM.currentUser?.coverPicture ?? "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 220)
                .clipped()
                
                
                
                ScrollView {
                    
                    AsyncImage(url: URL(string: loginVM.currentUser?.profilPicture ?? "")) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Circle().fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color("black_1"), lineWidth: 4))
                    .offset(y: 140)
                    .zIndex(1)
                    
                    
                    VStack(spacing: 0) {
                        
                        VStack(spacing: 0) {
                            Text("@\(loginVM.currentUser?.userName ?? "")")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color("orange_1"))
                                .padding(.top, 80)
                                .padding(.bottom, 10)
                            
                            Text(loginVM.currentUser?.biography ?? "")
                                .foregroundStyle(Color.white)
                            
                            VStack {
                                BadgeSectionView().environment(badgeVM)
                                
                                SectionWithProgressBar(title: "LEVEL", currentIntText: "\(loginVM.currentUser?.point ?? 0) points", subtitleText: levelVM.currentUserLevel?.name ?? "", color: "orange_1", target: "🎯 \(levelVM.targetLevel?.point ?? 0)", maxValue: levelVM.targetLevel?.point ?? 0, currentValue: levelVM.currentUserLevel?.point ?? 0)
                                
                                HStack {
                                    DashboardCards(imageName: "airplane.up.right", stat: loginVM.dashboardInfos?.numberOfTravels ?? 0, label: "TRAVELS")
                                    Spacer()
                                    DashboardCards(imageName: "globe", stat: loginVM.dashboardInfos?.numberOfTowns ?? 0, label: "TOWNS")
                                    Spacer()
                                    DashboardCards(imageName: "photo", stat: loginVM.dashboardInfos?.numberOfPictures ?? 0, label: "PICTURES")
                                }
                                
                                VStack {
                                    HStack {
                                        Text("📔 SAVED ALBUMS")
                                            .foregroundStyle(Color.white)
                                            .font(Font.system(size: 24))
                                        Spacer()
                                    }
                                    ScrollView(.horizontal) {
                                        HStack {
                                            ForEach(albumVM.mySavedAlbums) { album in
                                                AlbumCard(album: album)
                                            }
                                        }
                                    }
                                }.padding(.vertical, 25)
                                
                                SectionWithProgressBar(title: "STORAGE_STATUS", currentIntText: "\(String(loginVM.currentUser?.usedStorage ?? 0))GB", subtitleText: "💾Max \(String(loginVM.currentUser?.ownedStorage ?? 0))", color: "red_1", maxValue: Int(loginVM.currentUser?.ownedStorage ?? 0), currentValue: Int(loginVM.currentUser?.usedStorage ?? 0))
                                
                                
                                Button(action:{}, label:{
                                    CustomGradientButton(text: "UPDATE_PROFILE", muted: false)
                                })
                                
                                VStack(spacing: 0) {
                                    
                                    Button(action: { }) {
                                        SettingsRow(icon: "bell.fill", color: "orange_1", title: "Notifications")
                                    }
                                    Divider()
                                        .background(Color("gray_1"))
                                    Button(action: { }) {
                                        SettingsRow(icon: "lock.fill", color: "red_1", title: "Sécurité")
                                    }
                                    Divider()
                                        .background(Color("gray_1"))
                                    Button(action: { }) {
                                        SettingsRow(icon: "questionmark.circle.fill", color: "green_1", title: "Aide et support")
                                    }
                                }
                                .background(Color("black_1"))
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color("gray_1"), lineWidth: 1)
                                )
                                .padding(.vertical, 25)
                                
                                Button(action:{}, label:{
                                    CustomGradientButton(text: "DISCONNECT", muted: false)
                                })
                                
                                Button(action:{}, label:{
                                    Text("DELETE_ACCOUNT")
                                        .font(Font.system(size: 18, weight: .semibold))
                                        .foregroundStyle(Color("red_1"))
                                })
                                .padding(.top, 25)
                                .padding(.bottom, 80)

                                
                            }.padding(.horizontal, 20)
                        }
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .background(Color("black_1"))
                        .cornerRadius(30)
                        .offset(y: 80)
                    }


//TODO: Create all the levels
//TODO: clean the storage logic 
                }
            }
            .alert("Oops 🙃", isPresented: $showAlert, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text(alertMessage)
            })

            .background(Color("black_1"))
            .ignoresSafeArea(edges: .top)
            
            .task {
                do {
                    async let userLoad = loginVM.getCurrentUser()
                    async let allBadgesLoad = badgeVM.getAllBadges()
                    async let myBadgesLoad = badgeVM.getCurrentUserBadges()
                    async let currentUserLevel = levelVM.getCurrentUserLevel()
                    async let targetLevel = levelVM.getTargetLevel()
                    async let dashboardLoad = loginVM.getDashboardInfos()
                    async let savedAlbumsLoad = albumVM.getCurrentUserSavedAlbums()
                    
                    let _ = try await (userLoad, allBadgesLoad, myBadgesLoad, currentUserLevel, targetLevel, dashboardLoad, savedAlbumsLoad)
                } catch let error as AppError {
                                showAlert = true
                                alertMessage = error.errorDescription ?? ""
                            } catch {
                                alertMessage = "Impossible de charger les données de l'album. Vérifie ta connexion."
                                showAlert = true
                            }
                                        }
        }
    }
}

#Preview {
    ProfilPage().environment(LoginViewModel()).environment(AlbumViewModel())
}
