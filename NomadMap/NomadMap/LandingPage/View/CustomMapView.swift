//
//  CustomMapView.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 02/06/2026.
//

import SwiftUI
import MapKit

struct CustomMapView: UIViewRepresentable {
    var albums: [Album]
    @Binding var position: MapCameraPosition
    var onAlbumTap: (Album) -> Void
    var onClusterTap: (CLLocationCoordinate2D) -> Void
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.mapType = .hybrid
        mapView.pointOfInterestFilter = .excludingAll
        mapView.register(AlbumAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(ClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
        if #available(iOS 16.0, *) {
            mapView.preferredConfiguration = MKHybridMapConfiguration(elevationStyle: .realistic)}
        
        mapView.backgroundColor = .clear
        mapView.layer.backgroundColor = UIColor.clear.cgColor
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let currentAnnotations = uiView.annotations.compactMap { $0 as? AlbumAnnotation }
        
        let currentIds = currentAnnotations.map { $0.album.id.uuidString + ($0.album.coverPicture ?? "") }
        let newIds = albums.map { $0.id.uuidString + ($0.coverPicture ?? "") }
        
        if currentIds != newIds {
            uiView.removeAnnotations(uiView.annotations)
            
            var newAnnotations: [AlbumAnnotation] = []
            let groupedAlbums = Dictionary(grouping: albums) { "\($0.latitude),\($0.longitude)" }
            
            for (_, albumsAtLocation) in groupedAlbums {
                let count = albumsAtLocation.count
                
                for (index, album) in albumsAtLocation.enumerated() {
                    let annotation = AlbumAnnotation(album: album)
                    
                    if count > 1 {
                        let angle = (Double(index) * 2 * .pi) / Double(count)
                        let radius = 0.0003
                        annotation.customCoordinate = CLLocationCoordinate2D(
                            latitude: album.latitude + (radius * sin(angle)),
                            longitude: album.longitude + (radius * cos(angle))
                        )
                    }
                    newAnnotations.append(annotation)
                }
            }
            
            uiView.addAnnotations(newAnnotations)
        }
        
        if let camera = position.camera {
            let mapCamera = MKMapCamera(
                lookingAtCenter: camera.centerCoordinate,
                fromEyeCoordinate: camera.centerCoordinate,
                eyeAltitude: camera.distance
            )
            uiView.setCamera(mapCamera, animated: true)
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: CustomMapView
        
        init(_ parent: CustomMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            mapView.deselectAnnotation(view.annotation, animated: true)
            
            if let albumAnno = view.annotation as? AlbumAnnotation {
                parent.onAlbumTap(albumAnno.album)
            }
            else if let clusterAnno = view.annotation as? MKClusterAnnotation {
                parent.onClusterTap(clusterAnno.coordinate)
            }
        }    }
}

class AlbumAnnotation: NSObject, MKAnnotation {
    let album: Album
    
    var customCoordinate: CLLocationCoordinate2D?
    
    var coordinate: CLLocationCoordinate2D {
        return customCoordinate ?? CLLocationCoordinate2D(latitude: album.latitude, longitude: album.longitude)
    }
    var title: String? { album.title }
    
    init(album: Album) {
        self.album = album
    }
}

class AlbumAnnotationView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        didSet {
            guard let albumAnno = annotation as? AlbumAnnotation else { return }
            
            clusteringIdentifier = "albumCluster"
            collisionMode = .circle
            displayPriority = .required
            let customView = VStack(alignment: .leading) {
                AlbumCard(album: albumAnno.album)
            }
            
            let hostingController = UIHostingController(rootView: customView)
            hostingController.view.backgroundColor = .clear
            hostingController.view.frame = CGRect(x: -30, y: -80, width: 72, height: 50)
            
            subviews.forEach { $0.removeFromSuperview() }
            addSubview(hostingController.view)
        }
    }
}

class ClusterAnnotationView: MKAnnotationView {
    override var annotation: MKAnnotation? {
        
        didSet {
            
            displayPriority = .defaultHigh
            
            guard let clusterAnno = annotation as? MKClusterAnnotation else { return }
            
            let count = clusterAnno.memberAnnotations.count
            
            let clusterView = ClusterCard(count: count)
            
            let hostingController = UIHostingController(rootView: clusterView)
            hostingController.view.backgroundColor = .clear
            hostingController.view.frame = CGRect(x: -30, y: -80, width: 40, height: 40)
            
            subviews.forEach { $0.removeFromSuperview() }
            addSubview(hostingController.view)
        }
    }
}
