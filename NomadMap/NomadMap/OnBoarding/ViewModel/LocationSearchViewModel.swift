//
//  LocationSearchViewModel.swift
//  NomadMap
//
//  Created by Lucie Grunenberger  on 13/05/2026.
//


import MapKit
import Combine

@Observable
class LocationSearchViewModel: NSObject, MKLocalSearchCompleterDelegate {
    var searchText = "" {
        didSet {
            if searchText.isEmpty {
                suggestions = []
            } else {
                completer.queryFragment = searchText
            }
        }
    }
    var suggestions: [MKLocalSearchCompletion] = []
    var selectedLocation: SelectedLocation?
    
    private var completer = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = [.address, .pointOfInterest]
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        suggestions = completer.results
    }
    
    func selectLocation(_ completion: MKLocalSearchCompletion) async {
        let request = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: request)
        
        guard let response = try? await search.start(),
              let item = response.mapItems.first else { return }
        
        // TODO: migrate when Apple provides proper iOS 26 API
        let placemark = item.placemark
        let coordinate = placemark.coordinate
        let locality = placemark.locality
        let country = placemark.country
        let countryCode = placemark.countryCode

        selectedLocation = SelectedLocation(
            name: completion.title,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            town: item.placemark.locality,
            country: item.placemark.country,
            continent: continentFrom(countryCode: item.placemark.countryCode)
        )
        
        searchText = completion.title
        suggestions = []
    }
    private func continentFrom(countryCode: String?) -> String? {
        guard let code = countryCode else { return nil }
        
        let continents: [String: [String]] = [
            "Europe": ["FR", "DE", "IT", "ES", "PT", "GB", "NL", "BE", "CH", "AT", "SE", "NO", "DK", "FI", "PL", "CZ", "RO", "GR", "HU", "IE"],
            "North America": ["US", "CA", "MX"],
            "South America": ["BR", "AR", "CO", "CL", "PE", "VE", "EC", "BO", "PY", "UY"],
            "Asia": ["CN", "JP", "IN", "KR", "TH", "VN", "ID", "MY", "SG", "PH", "TR", "SA", "AE", "IL"],
            "Africa": ["ZA", "NG", "KE", "EG", "MA", "TN", "GH", "ET", "TZ"],
            "Oceania": ["AU", "NZ", "FJ", "PG"],
            "Antarctica": ["AQ"]
        ]
        
        return continents.first { $0.value.contains(code) }?.key
    }}


struct SelectedLocation {
    var name: String
    var latitude: Double
    var longitude: Double
    var town: String?
    var country: String?
    var continent: String?
}
