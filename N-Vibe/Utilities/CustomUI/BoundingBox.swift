//
//  BoundingBox.swift
//  N-Vibe
//
//  Created by Issam Abo Alshamlat on 12/10/24.
//

import Foundation
import CoreLocation

struct BoundingBox {
    let northEast: CLLocationCoordinate2D
    let southWest: CLLocationCoordinate2D
    
    static func from(coordinates: [CLLocationCoordinate2D]) -> BoundingBox? {
        guard !coordinates.isEmpty else { return nil }
        
        var minLat = coordinates.first!.latitude
        var maxLat = coordinates.first!.latitude
        var minLon = coordinates.first!.longitude
        var maxLon = coordinates.first!.longitude
        
        for coordinate in coordinates {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }
        
        let northEast = CLLocationCoordinate2D(latitude: maxLat, longitude: maxLon)
        let southWest = CLLocationCoordinate2D(latitude: minLat, longitude: minLon)
        return BoundingBox(northEast: northEast, southWest: southWest)
    }
}
