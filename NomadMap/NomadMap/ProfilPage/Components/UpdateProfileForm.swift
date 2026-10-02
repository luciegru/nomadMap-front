//
//  UpdateProfileForm.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 12/08/2026.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct UpdateProfileForm: View {
    
    @State var currentUser: User
    @State private var coverPicture: PhotosPickerItem?
    @State private var profilPicture : PhotosPickerItem?
    @State private var OBViewModel = OnboardingViewModel()
    @State private var bio: String = ""
    @Environment(LoginViewModel.self) private var loginVM
    @Binding var showUpdateProfil: Bool
    
    init(currentUser: User, showUpdateProfil: Binding<Bool>) {
        self.currentUser = currentUser
        self._bio = State(initialValue: currentUser.biography ?? "")
        self._showUpdateProfil = showUpdateProfil
    }
    
    var body: some View {
        
        VStack{
            
            Text("U_UPDATE_PROFILE")
                .font(.largeTitle)
                .bold()
                .customGradient()
                .transition(.move(edge: .leading).combined(with: .opacity))
            

            
            PhotosPicker(selection: $coverPicture) {
                if let image = OBViewModel.coverImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 300, height: 150)
                        .clipped()
                        .cornerRadius(20)
                        .shadow(radius: 10)
                } else if let coverPic = currentUser.coverPicture {
                    AsyncImage(url: URL(string:coverPic)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 300, height: 150)
                    .clipped()
                    .cornerRadius(20)
                    .shadow(radius: 10)
                } else {
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 300, height: 150)
                            .foregroundStyle(Color.gray)
                            .shadow(radius: 10)
                        Image(systemName: "square.and.arrow.down")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .customGradient()
                        
                    }
                    
                }
            }.onChange(of: coverPicture) { oldValue, newValue in
                OBViewModel.loadCoverImage(from: newValue)
            }
            
            
            PhotosPicker(selection: $profilPicture) {
                if let image = OBViewModel.profileImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                } else if let profilPic = currentUser.profilPicture {
                    AsyncImage(url: URL(string:profilPic)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .shadow(radius: 10)
                    } placeholder: {
                        ProgressView()
                    }
                    
                } else {
                    ZStack{
                        Circle()
                            .frame(width: 120, height: 120)
                            .foregroundStyle(Color.gray)
                            .shadow(radius: 10)
                        Image(systemName: "square.and.arrow.down")
                            .resizable()
                            .scaledToFit()
                            .customGradient()
                            .frame(width: 50, height: 50)
                    }
                }
            }
            .onChange(of: profilPicture) { oldValue, newValue in
                OBViewModel.loadProfileImage(from: newValue)
            }
            .padding(.top, -50)
            
            Text(currentUser.userName)
                .foregroundStyle(Color.gray)
            
            
            CustomTextField(label: "", placeholder: "PLACEHOLDER_BIOGRAPHY", binding:$bio, secure: false, isHeightFixed: false)
            
            Button(action: {
                Task{
                    do {
                        try await loginVM.updateProfile(id: currentUser.id, profilePhoto: profilPicture, coverPhoto: coverPicture, fields: ["biography": bio])
                        showUpdateProfil = false
                    } catch {
                        print("❌ updateProfile error:", error)
                    }
                }
            }, label: {
                CustomGradientButton(text:"UPDATE", muted: false)
            }).padding(.horizontal, 50)
                .padding(.vertical, 40)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(Color.black1)
        
    }
}


//#Preview {
//    UpdateProfileForm()
//}
