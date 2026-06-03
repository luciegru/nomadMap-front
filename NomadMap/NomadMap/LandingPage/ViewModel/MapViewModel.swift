//
//  MapViewModel.swift
//  NomadMap
//
//  Created by Lucie Grunenberger on 02/06/2026.
//

import Foundation
import MapKit
import CoreLocation
import SwiftUI

@Observable
class MapViewModel {
    
    struct MapItem: Identifiable {
        let id: String
        let latitude: Double
        let longitude: Double
        let albums: [Album]
        
        var isCluster: Bool { albums.count > 1 }
    }
    
    func computeClusters(for albums: [Album], proxy: MapProxy) -> [MapItem] {
        var items: [MapItem] = []
        let clusterRadius: CGFloat = 60.0
        
        for album in albums {
            let coord = CLLocationCoordinate2D(latitude: album.latitude, longitude: album.longitude)
            guard let currentPoint = proxy.convert(coord, to: .local) else { continue }
            
            if let index = items.firstIndex(where: { item in
                let itemCoord = CLLocationCoordinate2D(latitude: item.latitude, longitude: item.longitude)
                
                if itemCoord.latitude == coord.latitude && itemCoord.longitude == coord.longitude {
                    return false
                }
                
                if let itemPoint = proxy.convert(itemCoord, to: .local) {
                    let distance = sqrt(pow(currentPoint.x - itemPoint.x, 2) + pow(currentPoint.y - itemPoint.y, 2))
                    return distance < clusterRadius
                }
                return false
            }) {
                let existing = items[index]
                items[index] = MapItem(
                    id: existing.id,
                    latitude: existing.latitude,
                    longitude: existing.longitude,
                    albums: existing.albums + [album]
                )
            } else {
                items.append(
                    MapItem(
                        id: album.id.uuidString,
                        latitude: album.latitude,
                        longitude: album.longitude,
                        albums: [album]
                    )
                )
            }
        }
        return items
    }
}
