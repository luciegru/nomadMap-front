//
//  EditModale.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 29/09/2026.
//

import SwiftUI

struct EditModale: View {
    @State var note: String = ""
    var media: Media
    @Environment(\.dismiss) private var dismiss
    @Environment(MediaViewModel.self) private var mediaVM
    @Environment(AlbumViewModel.self) private var albumVM
    
    var body: some View {
        
        
        VStack {
            Text(note == "" ? "ADD_A_NOTE" : "EDIT_A_NOTE")
                .font(.largeTitle)
                .bold()
                .customGradient()
            Spacer()
            CustomTextField(
                label: "",
                placeholder: LocalizedStringKey(note),
                binding: $note,
                secure: false,
                isHeightFixed: false
            )
            
            Spacer()
            
            HStack {
                Button(action: {
                    Task {
                        do {
                            let updated = try await mediaVM.updateMedia(idMedia: media.id.uuidString, note: note)
                            albumVM.updateMedia(updated)
                            dismiss()
                        } catch {
                            print("update note error: \(error)")
                            // TODO: alerte d'erreur
                        }
                    }
                }, label: {
                    CustomGradientButton(text: "VALIDATE", muted: false, height: 50, width: 120)
                })
                Spacer()
                
                Button(action :{
                    dismiss()
                }, label: {
                    CustomGradientButton(text: "CANCEL", muted: true, height: 50, width: 120)
                })
            }.padding(.horizontal, 50)
            
            
            
            
        }
        .padding(.vertical, 60)
        .ignoresSafeArea()
        .frame(width: .infinity, height: .infinity)
        .background(Color("black_1"))
        .onAppear(){
            note = media.note ?? ""
        }
    }
}

#Preview {
    EditModale(note: "String", media: Media(id: UUID(), userId: UUID(), albumId: UUID(), date: Date(), mediaHQ: "String", lowQualityThumbnail: "String")).environment(MediaViewModel()).environment(AlbumViewModel())
}
