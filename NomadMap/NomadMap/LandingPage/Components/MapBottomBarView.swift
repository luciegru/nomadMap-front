//
//  MapBottomBarView.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 03/07/2026.
//

import SwiftUI
import MapKit

struct MapBottomBarView: View {
    
    var onSearch: (CLLocationCoordinate2D) -> Void
    var onReset: () -> Void
    var onAlbumSelected: (Album) -> Void
    
    var body: some View {
        HStack {
            MapSearchField(width: 250, onLocationSelected: { location in
                let targetCoordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                onSearch(targetCoordinate)
            }, onAlbumSelected: { album in
                onAlbumSelected(album)
            })
            Button(action: onReset, label: {
                GoButton(muted: false)
            })
        }
    }
}
