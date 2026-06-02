//
//  Onboarding2.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 12/05/2026.
//

import SwiftUI
import PhotosUI

struct Onboarding2: View {
    @State private var isVisible = false
    @Environment(LoginViewModel.self) private var loginVM
    @State private var OBViewModel = OnboardingViewModel()
    @State private var coverPicture: PhotosPickerItem?
    @State private var profilPicture : PhotosPickerItem?
    @State private var biography: String = ""
    @State private var navigate = false
    private var hasGivenAllRequiredInfos: Bool { OBViewModel.profileImage != nil }
    
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
                            
                            Text("Q_WHO_ARE_YOU \( loginVM.currentUser?.firstName.uppercased() ?? "")")
                                .font(.largeTitle)
                                .bold()
                                .customGradient()
                            
                                .transition(.move(edge: .leading).combined(with: .opacity))
                            
                        }
                        
                        Spacer()
                        
                        Text("ADD_FIRSTS_INFOS")
                            .foregroundStyle(Color.gray)
                            .padding(.horizontal, 30)
                        
                        Spacer()
                        
                        VStack{
                            
                            VStack(spacing: -50){
                                
                                PhotosPicker(selection: $coverPicture) {
                                    
                                    
                                    if let image = OBViewModel.coverImage {
                                        image
                                            .resizable()
                                            .scaledToFill()
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
                                }
                                .onChange(of: coverPicture) { oldValue, newValue in
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
                                
                                
                            }
                            
                            Text(loginVM.currentUser?.userName ?? "")
                                .foregroundStyle(Color.gray)
                            
                            CustomTextField(label: "", placeholder: "PLACEHOLDER_BIOGRAPHY", binding: $biography, secure: false, isHeightFixed: false)
                        }.padding(.bottom, 60)
                        
                        HStack{
                            Spacer()
                            
                            if hasGivenAllRequiredInfos {
                                
                                Button(action: {
                                    
                                    Task{
                                        try await loginVM.updateProfile(id: loginVM.currentUser!.id, profilePhoto: profilPicture, coverPhoto: coverPicture, fields: ["biography" : biography])
                                    }

                                    navigate = true
                                    
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
                OnBoarding3()
                    .environment(loginVM)
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
    Onboarding2()
}

