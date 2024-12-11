//
//  MapManager.swift
//  N-Vibe
//
//  Created by Issam Abo Alshamlat on 12/10/24.
//

import Foundation
import MapboxMaps
import MapboxDirections

final class MapService {
    private var pointAnnotationManager: PointAnnotationManager?
    
    static func createMapView(frame: CGRect) -> MapView {
        let options = MapInitOptions(resourceOptions: ResourceOptions(accessToken: Constants.accessToken))
        let mapView = MapView(frame: frame, mapInitOptions: options)
        mapView.mapboxMap.style.uri = .streets
        mapView.ornaments.compassView.isHidden = true
        mapView.ornaments.scaleBarView.isHidden = true
        mapView.ornaments.logoView.isHidden = true
        mapView.ornaments.attributionButton.isHidden = true
        
        return mapView
    }
    
    static func addRouteLayer(to mapView: MapView, route: Route) {
        let routeSourceId = "route-source"
        let routeLayerId = "route-layer"
        
        // Remove existing layer and source if they exist
        if mapView.mapboxMap.style.layerExists(withId: routeLayerId) {
            do {
                try mapView.mapboxMap.style.removeLayer(withId: routeLayerId)
                print("Old route layer removed.")
            } catch {
                print("Error removing old route layer: \(error.localizedDescription)")
            }
        }
        
        if mapView.mapboxMap.style.sourceExists(withId: routeSourceId) {
            do {
                try mapView.mapboxMap.style.removeSource(withId: routeSourceId)
                print("Old route source removed.")
            } catch {
                print("Error removing old route source: \(error.localizedDescription)")
            }
        }
        
        // Create a LineString for the route
        guard let coordinates = route.shape?.coordinates, !coordinates.isEmpty else {
            print("No coordinates to draw the route.")
            return
        }
        
        let lineString = LineString(coordinates)
        
        // Create a GeoJSONSource to hold the LineString
        var geoJSONSource = GeoJSONSource()
        geoJSONSource.data = .feature(Feature(geometry: .lineString(lineString)))
        
        // Add the GeoJSONSource to the map
        do {
            try mapView.mapboxMap.style.addSource(geoJSONSource, id: routeSourceId)
            print("GeoJSON source added successfully.")
        } catch {
            print("Error adding GeoJSON source: \(error.localizedDescription)")
            return
        }
        
        // Create a LineLayer to display the route
        var lineLayer = LineLayer(id: routeLayerId)
        lineLayer.source = routeSourceId
        lineLayer.lineColor = .constant(StyleColor(UIColor.red)) // Set the route line color to red
        lineLayer.lineWidth = .constant(4) // Set the line width
        lineLayer.visibility = .constant(.visible)
        
        // Add the LineLayer to the map
        do {
            try mapView.mapboxMap.style.addLayer(lineLayer)
            print("LineLayer added successfully.")
        } catch {
            print("Error adding LineLayer: \(error.localizedDescription)")
            return
        }
        
        // Animate the camera to fit the route or focus on the start point
        if let firstCoordinate = coordinates.first {
            let cameraOptions = CameraOptions(
                center: firstCoordinate, // Focus on the start point of the route
                zoom: 14,                // Adjust zoom level as necessary
                bearing: nil,            // Optional: Set a specific bearing
                pitch: nil               // Optional: Set a specific pitch
            )
            mapView.camera.ease(to: cameraOptions, duration: 2.0) // Smooth animation to the target
        } else {
            print("Failed to retrieve start point for camera animation.")
        }
    }
    
    static func adjustCamera(toFitRoute route: Route, on mapView: MapView) {
        guard let coordinates = route.shape?.coordinates, !coordinates.isEmpty else {
            print("No coordinates to adjust the camera.")
            return
        }
        
        // Animate the camera to fit the route
        if let boundingBox = BoundingBox.from(coordinates: coordinates) {
            let cameraOptions = CameraOptions(
                center: CLLocationCoordinate2D(
                    latitude: (boundingBox.northEast.latitude + boundingBox.southWest.latitude) / 2,
                    longitude: (boundingBox.northEast.longitude + boundingBox.southWest.longitude) / 2),
                zoom: 12 // Adjust zoom level as necessary
            )
            mapView.camera.ease(to: cameraOptions, duration: 2.0)
        }
    }
    
    func addPinsToMap(startCoordinates: CLLocationCoordinate2D?, endCoordinates: CLLocationCoordinate2D?, on mapView: MapView) {
        
        if pointAnnotationManager == nil {
            pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
        }
        
        if let startCoordinates = startCoordinates {
            let startImage = UIImage(named: "start_pin")
            
            var startAnnotation = PointAnnotation(coordinate: startCoordinates)
            startAnnotation.image = startImage.map { .init(image: $0, name: "start_pin") }
            startAnnotation.iconSize = 1.0
            pointAnnotationManager?.annotations = [startAnnotation]
            
            let cameraOptions = CameraOptions(center: startCoordinates, zoom: 14)
            mapView.camera.ease(to: cameraOptions, duration: 2.0)
        }
        
        if let endCoordinates = endCoordinates {
            let endImage = UIImage(systemName: "flag")
            
            var endAnnotation = PointAnnotation(coordinate: endCoordinates)
            endAnnotation.image = endImage.map { .init(image: $0, name: "end-pin") }
            endAnnotation.iconSize = 1.5
            
            pointAnnotationManager?.annotations = [endAnnotation]
            
            let cameraOptions = CameraOptions(center: endCoordinates, zoom: 14)
            mapView.camera.ease(to: cameraOptions, duration: 2.0)
        }
    }
}
